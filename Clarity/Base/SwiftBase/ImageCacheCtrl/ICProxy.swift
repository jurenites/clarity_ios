//
//  ICProxy.swift
//  TRN
//
//  Created by Alexey Klyotzin on 06/02/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

import Foundation

protocol ICDelegateProxy: class
{
    func imageCacheGetRange(cache: ImageCache!) -> ImageCacheRanges!
    func imageCache(cache: ImageCache!, itemsAtIndex index: Int) -> [AnyObject]!
    func imageCache(cache: ImageCache!, imageReady image: UIImage!, cacheItem item: ImageCacheRequest!, atIndex index: Int)
    func imageCache(cache: ImageCache!, runNetOpForItem item: ImageCacheRequest!, onSuccess: ((UIImage!) -> Void)!, onError: ((NSError!) -> Void)!) -> ApiCanceler!
    func imageCache(cache: ImageCache!, reorderRequests requests: NSArray!)
    func imageCacheReloadTable(cache: ImageCache!)
}

class ICProxy: NSObject, ImageCacheDelegate
{
    private weak var _proxy: ICDelegateProxy!
    
    init(proxy: ICDelegateProxy) {
        _proxy = proxy
    }
    
    func imageCacheGetRange(cache: ImageCache!) -> ImageCacheRanges! {
        return _proxy.imageCacheGetRange(cache)
    }
    
    func imageCache(cache: ImageCache!, itemsAtIndex index: Int) -> [AnyObject]! {
        return _proxy.imageCache(cache, itemsAtIndex: index)
    }
    
    func imageCache(cache: ImageCache!, imageReady image: UIImage!, cacheItem item: ImageCacheRequest!, atIndex index: Int) {
        _proxy.imageCache(cache, imageReady: image, cacheItem: item, atIndex: index)
    }
    
    func imageCache(cache: ImageCache!, runNetOpForItem item: ImageCacheRequest!, onSuccess: ((UIImage!) -> Void)!, onError: ((NSError!) -> Void)!) -> ApiCanceler! {
        return _proxy.imageCache(cache, runNetOpForItem: item, onSuccess: onSuccess, onError: onError)
    }
    
    func imageCache(cache: ImageCache!, reorderRequests requests: [AnyObject]!) {
        _proxy.imageCache(cache, reorderRequests: requests)
    }
    
    func imageCacheReloadTable(cache: ImageCache!) {
        _proxy.imageCacheReloadTable(cache)
    }
}
