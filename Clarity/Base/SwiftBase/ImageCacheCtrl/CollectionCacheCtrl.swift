//
//  CollectionCacheCtrl.swift
//  Valkyrie
//
//  Created by Alexey Klyotzin on 1/13/15.
//  Copyright (c) 2015 Life Church. All rights reserved.
//

import Foundation
import UIKit

private let UpdateCacheTreshold: CGFloat = 60

class CollectionCacheCtrl<
        ClassT: CacheCtrlDelegate where ClassT.CacheRequestT: ImageCacheRequest
    >: NSObject, CacheCtrl, CollectionFlowLayoutDelegate, ICDelegateProxy
{
    private var _collectionView: UICollectionView
    private var _flowLayout: CollectionFlowLayout
    private var _prevContentOffset: CGFloat = 0
    private var _onLayoutForImageCacheReady: CollectionStageComplete?
    private var _isActive = false
    private var _section: Int
    private var _cachedScreens: CGFloat = 1.5
    private weak var _delegate: ClassT!
    
    private var _imageCache: ImageCache!
    private var _icProxy: ICProxy!
    
    private var _contentOffsetMonitor: ContentOffsetKVO!
    
    init(_ collectionView: UICollectionView, section: UInt, delegate: ClassT) {
        assert(collectionView.collectionViewLayout is CollectionFlowLayout, "collectionView.collectionViewLayout is NOT CollectionFlowLayout")
        
        self._collectionView = collectionView
        self._flowLayout = collectionView.collectionViewLayout as! CollectionFlowLayout
        self._section = Int(section)
        self._delegate = delegate
        super.init()
        
        self._icProxy = ICProxy(proxy: self)
        self._imageCache = ImageCache(forCollectionViewWithDelegate: self._icProxy)
        self._flowLayout.delegate = self
        
        let proxyFn: (() -> Void) = {[weak self] in self?.contentOffsetChanged(); return}
        _contentOffsetMonitor = ContentOffsetKVO(object: collectionView, onChange: {(val: CGFloat) in
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
            _collectionView.reloadData()
        }
    }
    
    func itemsWasAdded() {
        if self.isActive {
            _collectionView.reloadData()
            updateImageCache()
        }
    }
    
    func clear() {
        _imageCache.clear()
    }
    
    func memoryWarningReceived() {
        if _collectionView.window == nil {
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
    
    private func contentOffsetChanged() {
        if self.isActive {
            let isVertical = _flowLayout.scrollDirection == UICollectionViewScrollDirection.Vertical
            let contentOffset = isVertical ? _collectionView.contentOffset.y : _collectionView.contentOffset.x;
            
            if abs(contentOffset - _prevContentOffset) > UpdateCacheTreshold {
                _prevContentOffset = contentOffset
                updateImageCache()
            }
        }
    }
    
    private func updateImageCache() {
        if _flowLayout.isReady {
            _imageCache.update()
        }
    }
    
    private func rebuildImageCache() {
        _imageCache.rebulidWithCollectionStage {(onComplete: CollectionStageComplete!) -> Void in
            self._collectionView.reloadData()
            
            if self._collectionView.numberOfItemsInSection(self._section) > 0 {
                self._onLayoutForImageCacheReady = onComplete
            } else {
                onComplete?()
                self._onLayoutForImageCacheReady = nil
            }
        }
    }
    
    private func normalizeRect(rect: CGRect, forContentSize contentSize: CGSize, isVertical: Bool) -> CGRect {
        var normalized = CGRectZero
        
        if isVertical {
            normalized.origin.x = 0;
            normalized.origin.y = max(rect.origin.y, 0);
            normalized.size.width = _collectionView.width;
            normalized.size.height = max(min(rect.size.height, contentSize.height - normalized.origin.y), 0);
        } else {
            normalized.origin.x = max(rect.origin.x, 0);
            normalized.origin.y = 0;
            normalized.size.width = max(min(rect.size.width, contentSize.width - normalized.origin.x), 0);
            normalized.size.height = _collectionView.height;
        }
        
        return normalized
    }
    
    private func attrsRangeForFirstRect(firstRect: CGRect, lastRect: CGRect) -> (UICollectionViewLayoutAttributes, UICollectionViewLayoutAttributes)? {
        if let firstItems = _flowLayout.layoutAttributesForElementsInRect(firstRect) {
            if let lastItems = _flowLayout.layoutAttributesForElementsInRect(lastRect) {
                if let firstItem = firstItems.first {
                    if let lastItem = lastItems.last {
                        return (firstItem, lastItem)
                    }
                }
//                if firstItems.count > 0 && lastItems.count > 0 {
//                    return (firstItems.first as! UICollectionViewLayoutAttributes, lastItems.last as! UICollectionViewLayoutAttributes)
//                }
            }
        }
        
        return nil
    }
    
    private func rangeForRect(rect: CGRect, isVertical: Bool) -> NSRange {
        let h: CGFloat = 4
        
        var firstRect = CGRectZero
        var lastRect = CGRectZero
        
        if isVertical {
            firstRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, h)
            lastRect = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - h, rect.size.width, h)
            
            if (firstRect.origin.y > lastRect.origin.y) {
                return NSMakeRange(0, 0)
            }
            
        } else {
            firstRect = CGRectMake(rect.origin.x, rect.origin.y, h - 1, rect.size.height)
            lastRect = CGRectMake(rect.origin.x + rect.size.width - h, rect.origin.y, h - 1, rect.size.height)
            
            if (firstRect.origin.x > lastRect.origin.x) {
                return NSMakeRange(0, 0)
            }
        }
        
        if let (first, last) = attrsRangeForFirstRect(firstRect, lastRect: lastRect) {
            let itemsCount = _collectionView.numberOfItemsInSection(_section)
            let location = first.indexPath.item
            let length = last.indexPath.item - location + 1
            
            assert(length >= 0)
            
            return NSMakeRange(max(min(location, itemsCount), 0),
                               max(min(length, itemsCount - location), 0));
        }
        
        return NSMakeRange(0, 0)
    }
    
    private func getCachingRange() -> ImageCacheRanges {
        let ranges = ImageCacheRanges()
        
        if !_flowLayout.isReady {
            return ranges
        }
        
        let isVertical = _flowLayout.scrollDirection == UICollectionViewScrollDirection.Vertical
        
        var contentOffset = _collectionView.contentOffset
        let contentSize = _flowLayout.collectionViewContentSize()
        let viewHeight = _collectionView.height
        let viewWidth = _collectionView.width
        let cachedScreens = self.cachedScreens
        
        var visibleRect = CGRectZero
        var cachedRect = CGRectZero
        
        if isVertical {
            contentOffset.y = max(min(contentOffset.y, contentSize.height - 10), _flowLayout.headerReferenceSize.height)
            visibleRect = CGRectMake(0, contentOffset.y, viewWidth, viewHeight)
        } else {
            contentOffset.x = max(min(contentOffset.x, contentSize.width - 10), _flowLayout.headerReferenceSize.height)
            visibleRect = CGRectMake(contentOffset.x, 0, viewWidth, viewHeight)
        }
        
        visibleRect = normalizeRect(visibleRect, forContentSize: contentSize, isVertical: isVertical)
        
        if (isVertical) {
            cachedRect.origin.y = visibleRect.origin.y - viewHeight * cachedScreens
            cachedRect.size.width = visibleRect.size.width
            cachedRect.size.height = viewHeight + (visibleRect.origin.y - cachedRect.origin.y) + viewHeight * cachedScreens
        } else {
            cachedRect.origin.x = visibleRect.origin.x - viewWidth * cachedScreens
            cachedRect.size.width = viewWidth + (visibleRect.origin.x - cachedRect.origin.x) + viewWidth * cachedScreens
            cachedRect.size.height = visibleRect.size.height
        }
        
        cachedRect = normalizeRect(cachedRect, forContentSize: contentSize, isVertical: isVertical)
        
        ranges.visibleRange = rangeForRect(visibleRect, isVertical: isVertical)
        ranges.fullRange = rangeForRect(cachedRect, isVertical: isVertical)
        
        return ranges
    }
    
    // MARK: CollectionFlowLayoutDelegate
    
    func flowLayoutIsReady(layout: CollectionFlowLayout) {
        if _onLayoutForImageCacheReady != nil {
            _onLayoutForImageCacheReady?()
            _onLayoutForImageCacheReady = nil
        } else if isActive {
            _imageCache.update()
        }
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
    }
}

