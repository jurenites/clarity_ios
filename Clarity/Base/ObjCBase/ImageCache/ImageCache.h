//
//  ImageCache.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 12/5/13.
//
//

#import <Foundation/Foundation.h>
#import "ImageCacheRequest.h"
#import "ImageCacheItem.h"
#import "ImageCacheResult.h"
#import "ApiCanceler.h"
#import "ImageCacheRanges.h"

//----------------------------
@class ImageCache;
@protocol ImageCacheDelegate <NSObject>

@required

- (ImageCacheRanges *)imageCacheGetRange:(ImageCache *)cache;

- (NSArray *)imageCache:(ImageCache *)cache itemsAtIndex:(NSInteger)index;

- (void)imageCache:(ImageCache *)cache
        imageReady:(UIImage *)image
         cacheItem:(ImageCacheRequest *)item
       atIndex:(NSInteger)index;

- (ApiCanceler *)imageCache:(ImageCache *)cache
           runNetOpForItem:(ImageCacheRequest *)item
                 onSuccess:(void(^)(UIImage *))onSuccess
                   onError:(void(^)(NSError *))onError;

- (void)imageCacheReloadTable:(ImageCache *)cache;

@optional
- (void)imageCache:(ImageCache *)cache reorderRequests:(NSArray *)requests;
- (UIImage *)imageCache:(ImageCache *)cache imageForRequest:(ImageCacheRequest *)request;

@end

//-----------------------------------

typedef void(^CollectionStageComplete)();

@interface ImageCache : NSObject

- (instancetype)initWithDelegate:(id<ImageCacheDelegate>)delegate;
- (instancetype)initForCollectionViewWithDelegate:(id<ImageCacheDelegate>)delegate;

- (ImageCacheResult *)getImagesAtIndex:(NSUInteger)index;

- (UIImage *)imageForRequest:(ImageCacheRequest *)request;

- (void)setImage:(UIImage *)image forKey:(id<NSObject, NSCopying>)key;

- (void)update;
- (void)rebuildWithTableAction:(void(^)())tbAction;
- (void)rebuild;

- (void)rebulidWithCollectionStage:(void(^)(CollectionStageComplete onComplete))colectionStage;

- (void)rebuildItemAtIndex:(NSInteger)index;
- (void)clear;

- (void)cancelPendingRequests;
- (void)restartRequests;

@end
