//
//  TableCacheCtrl.swift
//  TRN
//
//  Created by Alexey Klyotzin on 06/02/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

import Foundation
import UIKit

private let UpdateCacheTreshold: CGFloat = 60


class TableCacheCtrl<
    ClassT: CacheCtrlDelegate where ClassT.CacheRequestT: ImageCacheRequest
    >: NSObject, CacheCtrl, ICDelegateProxy
{
    private var _tableView: UITableView
    private var _prevContentOffset: CGFloat = 0
    private var _isActive = false
    private var _section: Int
    private var _cachedScreens: CGFloat = 1.5
    private weak var _delegate: ClassT!
    
    private var _imageCache: ImageCache!
    private var _icProxy: ICProxy!
    
    private var _contentOffsetMonitor: ContentOffsetKVO!
    
    init(_ tableView: UITableView, section: UInt, delegate: ClassT) {
        self._tableView = tableView
        self._section = Int(section)
        self._delegate = delegate
        super.init()
        
        self._icProxy = ICProxy(proxy: self)
        self._imageCache = ImageCache(forCollectionViewWithDelegate: self._icProxy)
        
        let proxyFn: (() -> Void) = {[weak self] in self?.contentOffsetChanged(); return}
        _contentOffsetMonitor = ContentOffsetKVO(object: tableView, onChange: {(val: CGFloat) in
            proxyFn()
        })
    }
    
    var isActive: Bool {
        get {
            return _isActive
        }
        
        set(newIsActive) {
            if !_isActive && newIsActive {
                rebuildImageCache()
                _imageCache.restartRequests()
            } else if _isActive && !newIsActive {
                _imageCache.cancelPendingRequests()
            }
            
            _isActive = newIsActive
        }
    }
    
    var cachedScreens: CGFloat {
        get {return _cachedScreens}
        set(newVal) {_cachedScreens = max(newVal, 1.0)}
    }
    
    func reloadData() {
        if self.isActive {
            rebuildImageCache()
        } else {
            _tableView.reloadData()
        }
    }
    
    func itemsWasAdded() {
        if self.isActive {
            _tableView.reloadData()
            updateImageCache()
        }
    }
    
    func clear() {
        _imageCache.clear()
    }
    
    func memoryWarningReceived() {
        if _tableView.window == nil {
            _imageCache.clear()
        }
    }
    
    func restartRequest() {
        _imageCache.restartRequests()
    }
    
    func imagesAtIndex(index: Int) -> ImageCacheResult {
        return _imageCache.getImagesAtIndex(UInt(index)) ?? ImageCacheResult()
    }
    
    func imageAtIndex(index: Int) -> UIImage? {
        var cachedImage: UIImage?
        
        imagesAtIndex(index).enumerateWithBlock { (req: ImageCacheRequest!, image: UIImage!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            cachedImage = image
            stop.memory = true
        }
        return cachedImage
    }
    
    // MARK: Private
    
    private class func trimVisibleRows(visibleRows: [NSIndexPath], startIndexPath: NSIndexPath) -> [NSIndexPath] {
        if visibleRows.count == 0 {
            return []
        }
        
        let first = visibleRows.first!
        let last = visibleRows.last!
        
        if first.section > startIndexPath.section || last.compare(startIndexPath) == NSComparisonResult.OrderedAscending {
            return []
        }
        
        var firstIndex = 0
        var lastIndex = visibleRows.count - 1
        
        for ; firstIndex < visibleRows.count; firstIndex++ {
            let indexPath = visibleRows[firstIndex]
            let cmpResult = indexPath.compare(startIndexPath)
            
            if (cmpResult == NSComparisonResult.OrderedSame || cmpResult == NSComparisonResult.OrderedDescending) {
                break
            }
        }
        
        if firstIndex >= visibleRows.count {
            return []
        }
        
        for ; lastIndex < visibleRows.count; lastIndex-- {
            let indexPath = visibleRows[lastIndex]
            
            if (indexPath.section == startIndexPath.section) {
                break
            }
        }
        
        if lastIndex >= visibleRows.count || lastIndex < firstIndex {
            return []
        }
        
        
        return [NSIndexPath](visibleRows[firstIndex...lastIndex + 1])
    }
    
    private func getRowHeight(row: Int) -> CGFloat {
        return _tableView.rectForRowAtIndexPath(NSIndexPath(forRow: row, inSection: _section)).size.height
    }
    
    private func getCachingRange() -> ImageCacheRanges {
        let startIndexPath = NSIndexPath(forRow: 0, inSection: _section)
        let cachedSpace = _tableView.frame.size.height * cachedScreens;
        let actualVisibleRows: [NSIndexPath] = CastArray(_tableView.indexPathsForVisibleRows ?? NSArray())
        var visibleRows = TableCacheCtrl.trimVisibleRows(actualVisibleRows, startIndexPath: startIndexPath)
        
        let ranges = ImageCacheRanges()
        let rowsCount = _tableView.numberOfRowsInSection(_section)
        
        if visibleRows.count == 0 {
            let rowsInTb = _tableView.numberOfRowsInSection(startIndexPath.section)
            
            if rowsCount == 0 || rowsInTb == 0 || rowsInTb == NSNotFound {
                return ranges;
            } else if actualVisibleRows.count > 0 && startIndexPath.compare(actualVisibleRows.first!) == NSComparisonResult.OrderedAscending {
                visibleRows = [NSIndexPath(forRow:startIndexPath.row + rowsInTb - 1, inSection:startIndexPath.section)]
            } else {
                visibleRows = [startIndexPath];
            }
        }
        
        // first and last are in table view index space
        let first = visibleRows.first!
        let last = visibleRows.last!
        
        let firstFrame = _tableView.rectForRowAtIndexPath(first)
        let lastFrame = _tableView.rectForRowAtIndexPath(last)
        
        var firstIndex = first.row;
        var lastIndex = last.row;
        
        // firstIndex and lastIndex are in table controller index space
        firstIndex -= startIndexPath.row;
        lastIndex -= startIndexPath.row;
        
        firstIndex = max(0, firstIndex)
        lastIndex = min(rowsCount - 1, lastIndex)
        
        ranges.visibleRange = NSMakeRange(firstIndex, lastIndex - firstIndex + 1);
        
        var upper = _tableView.contentOffset.y - firstFrame.origin.y;
        
        while (upper < cachedSpace && firstIndex > 0) {
            upper += getRowHeight(--firstIndex)
        }
        
        firstIndex = max(firstIndex, 0);
        
        var lower = (lastFrame.origin.y + lastFrame.size.height) - (_tableView.contentOffset.y + _tableView.frame.size.height);
        
        while (lower < cachedSpace && lastIndex < (rowsCount - 1)) {
            lower += getRowHeight(++lastIndex)
        }
        
        lastIndex = min(lastIndex + 1, rowsCount)
        ranges.fullRange = NSMakeRange(firstIndex, (lastIndex > firstIndex) ? (lastIndex - firstIndex) : 0);
        
        return ranges
    }
    
    private func contentOffsetChanged() {
        if self.isActive {
            let contentOffset = _tableView.contentOffset.y;
            
            if abs(contentOffset - _prevContentOffset) > UpdateCacheTreshold {
                _prevContentOffset = contentOffset
                updateImageCache()
            }
        }
    }
    
    private func updateImageCache() {
        _imageCache.update()
    }
    
    private func rebuildImageCache() {
        _imageCache.rebuild()
    }
    
    // MARK: ImageCacheDelegate
    
    func imageCacheGetRange(cache: ImageCache!) -> ImageCacheRanges! {
        return getCachingRange()
    }
    
    func imageCache(cache: ImageCache!, itemsAtIndex index: Int) -> [AnyObject]! {
        return _delegate.cacheCtrl(self, itemsAtIndex: index)
    }
    
    func imageCache(cache: ImageCache!, imageReady image: UIImage!, cacheItem item: ImageCacheRequest!, atIndex index: Int) {
        if self.isActive {
            _delegate.cacheCtrl(self, imageReady: image, forRequest: item as! ClassT.CacheRequestT, atIndex: index)
        }
    }
    
    func imageCache(cache: ImageCache!, runNetOpForItem item: ImageCacheRequest!, onSuccess: ((UIImage!) -> Void)!, onError: ((NSError!) -> Void)!) -> ApiCanceler! {
        let canceler = _delegate.cacheCtrl(self, signalForRequest: item as! ClassT.CacheRequestT)
            .success({(image: UIImage) in onSuccess(image)},
                error: {(error: NSError) in onError(error)})
        
        return ApiCancelerSignal.wrap(canceler)
    }
    
    func imageCache(cache: ImageCache!, reorderRequests requests: NSArray!) {
        var reqIds = [UniqueNumber]()
        
        reqIds.reserveCapacity(requests.count)
        
        for __canceler in requests {
            let canceler = __canceler as! ApiCanceler
            
            if let reqId = (canceler.impl as? ApiCancelerSignal)?.swiftCanceler()?.operationId() as? UniqueNumber {
                reqIds.append(reqId)
            }
        }
        
        ApiRouter.shared().mediaIO.reorderRequests(reqIds)
    }
    
    func imageCacheReloadTable(cache: ImageCache!) {
        _tableView.reloadData()
    }
}
