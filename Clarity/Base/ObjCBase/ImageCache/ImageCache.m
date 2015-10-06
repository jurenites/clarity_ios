//
//  ImageCache.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 12/5/13.
//
//

#import "ImageCache.h"
#import "ImageWrapper.h"
#import "ImageCacheImage.h"
#import "InternalError.h"
#import "ImageCacheRequest.h"
#import "ImageCacheItem.h"
#import "ImageCacheItem_Private.h"

static const int ExpireTreshold = 2;

@interface ImageCache ()
{
    BOOL _collectionViewBehavior;
    BOOL _rebuilding;
    
    NSMutableDictionary *_cache;
    NSInteger _location;
    NSMutableArray *_scrollList;
    
    id<ImageCacheDelegate> __weak _delegate;
}

@end

@implementation ImageCache

- (instancetype)initWithDelegate:(id<ImageCacheDelegate>)delegate
{
    self = [super init];
    if (!self)
        return nil;

    NSParameterAssert(delegate);
    
    _delegate = delegate;
    _cache = [NSMutableDictionary dictionary];
    _scrollList = [NSMutableArray array];

    return self;
}

- (instancetype)initForCollectionViewWithDelegate:(id<ImageCacheDelegate>)delegate
{
    self = [self initWithDelegate:delegate];
    if (!self) {
        return nil;
    }
    
    _collectionViewBehavior = YES;
    return self;
}

- (void)imageFetched:(UIImage *)image forRequest:(ImageCacheRequest *)request
{
    ImageCacheImage *cachedImage = _cache[request.key];
    
    if (!cachedImage) {
        return;
    }
    
    cachedImage.image = image;
    cachedImage.canceler = nil;
    
    NSSet *imageIndexes = [cachedImage getIndexesCopy];
    
    for (NSNumber *postiton in imageIndexes) {
        NSInteger arrayPosition = postiton.integerValue - _location;
        
        if (arrayPosition >= (NSInteger)_scrollList.count) {
            [[InternalError errorWithDescr:@"[ImageCache imageFetched]: inconsistency"] raise];
        }
        
        NSMutableArray *dupItems = _scrollList[arrayPosition][request.key];
        
        if (!dupItems) {
            [[InternalError errorWithDescr:@"[ImageCache imageFetched]: inconsistency"] raise];
        }
        
        for (ImageCacheItem *scrollItem in dupItems) {
            scrollItem.image = image;
            
            [_delegate imageCache:self
                       imageReady:image
                        cacheItem:scrollItem.request
                          atIndex:postiton.integerValue];
        }
    }
}

- (void)imageFetchFailedForItem:(ImageCacheRequest *)item
{
    ImageCacheImage *cachedImage = _cache[item.key];
    
    if (!cachedImage) {
        return;
    }

    cachedImage.canceler = nil;
}

- (ApiCanceler *)runRequestWithItemRequest:(ImageCacheRequest *)request
{
    ImageCache * __weak weakSelf = self;

    void (^OnSuccess)(UIImage*) = ^(UIImage *image) {
        [weakSelf imageFetched:image forRequest:request];
    };

    void (^OnError)(NSError*) = ^(NSError *error) {
        [weakSelf imageFetchFailedForItem:request];
    };

    return [_delegate imageCache:self
                 runNetOpForItem:request
                       onSuccess:OnSuccess
                         onError:OnError];
}

- (ImageCacheItem *)requestImage:(ImageCacheRequest *)request
                      atPosition:(NSInteger)position
                      otherCache:(NSDictionary *)otherCache
{
    ImageCacheImage *cachedImage = _cache[request.key];
    
    if (!cachedImage && otherCache) {
        cachedImage = otherCache[request.key];
        
        if (cachedImage) {
            _cache[request.key] = cachedImage;
        }
    }
    
    
    // Discard expired image
    if (cachedImage && request.updated
        && (!cachedImage.request.updated || [request.updated timeIntervalSinceDate:cachedImage.request.updated] > ExpireTreshold)) {
        cachedImage = nil;
    }
    
    if (!cachedImage) {
        cachedImage = [[ImageCacheImage alloc] initWithRequest:request];
        
        if ([_delegate respondsToSelector:@selector(imageCache:imageForRequest:)]) {
            cachedImage.image = [_delegate imageCache:self imageForRequest:request];
        }
        
        if (!cachedImage.image) {
            cachedImage.canceler = [self runRequestWithItemRequest:request];
        }
        
        _cache[request.key] = cachedImage;
    }
    
    [cachedImage addScrollIndex:position];
    
    ImageCacheItem *item = [ImageCacheItem new];
    item.request = request;
    item.image = cachedImage.image;
    item.cachedImage = cachedImage;
    
    return item;
}

- (NSDictionary *)requestImagesAtPosition:(NSInteger)position otherCache:(NSDictionary *)otherCache
{
    NSArray *requests = [_delegate imageCache:self itemsAtIndex:position];
    NSMutableDictionary *items = [NSMutableDictionary dictionary];
    
    NSAssert(requests, @"");
    
    for (ImageCacheRequest *request in requests) {
        NSMutableArray *dupItems = items[request.key];
        
        if (!dupItems) {
            dupItems = [NSMutableArray array];
            items[request.key] = dupItems;
        }
        
        [dupItems addObject:[self requestImage:request atPosition:position otherCache:otherCache]];
    }
    
    return items;
}

- (NSDictionary *)requestImagesAtPosition:(NSInteger)position
{
    return [self requestImagesAtPosition:position otherCache:nil];
}

- (NSDictionary *)discardImage:(ImageCacheItem *)item
                    atPosition:(NSInteger)position
           discardNetOperation:(BOOL)discardNetOperation
{
    ImageCacheImage *cachedImage = _cache[item.request.key];
    
    if (!cachedImage) {
        NSLog(@"[ImageCache discardImagesForPosition]: inconsistency");
        return nil;
    }
    
    [cachedImage removeScrollIndex:position];
    
    if (![cachedImage hasIndexes]) {
        if (discardNetOperation) {
            [cachedImage.canceler cancel];
            cachedImage.canceler = nil;
        }
        
        NSDictionary *removed = @{item.request.key: cachedImage};
        [_cache removeObjectForKey:item.request.key];
        return removed;
    }
    
    return nil;
}

- (void)discardImagesAtPosition:(NSInteger)position
{
    NSMutableDictionary *scrollPositionItems = _scrollList[position - _location];
    
    for (NSMutableArray *dupItems in scrollPositionItems.allValues) {
        for (ImageCacheItem *item in dupItems) {
            [self discardImage:item atPosition:position discardNetOperation:YES];
        }
    }
}

- (void)updateWithRange:(NSRange)newRange
{
    if ((newRange.location == (NSUInteger)_location) && (newRange.length == _scrollList.count)) {
        return;
    }
    
    const NSInteger newLocation = newRange.location;
    NSMutableArray *newScrollList = [NSMutableArray arrayWithCapacity:newRange.length];
    
    for (NSUInteger i = 0; i < newRange.length; i++) {
        [newScrollList addObject:[NSNull null]];
    }
    
    NSInteger i = 0, j = 0;

    for (; (newLocation + i) < _location && i < (NSInteger)newScrollList.count; i++) {
        newScrollList[i] = [self requestImagesAtPosition:newLocation + i];
    }
    
    for (; (_location + j) < newLocation && j < (NSInteger)_scrollList.count; j++){
        [self discardImagesAtPosition:_location + j];
    }
    
    for (; i < (NSInteger)newScrollList.count && j < (NSInteger)_scrollList.count; i++, j++) {
        newScrollList[i] = _scrollList[j];
    }
    
    for (; i < (NSInteger)newScrollList.count; i++) {
        newScrollList[i] = [self requestImagesAtPosition:newLocation + i];
    }
    
    for (; j < (NSInteger)_scrollList.count; j++) {
        [self discardImagesAtPosition:_location + j];
    }
    
    _scrollList = newScrollList;
    _location = newLocation;
}

- (BOOL)inRange:(NSInteger)index
{
    return index >= _location && index < (_location + (NSInteger)_scrollList.count);
}

- (ImageCacheResult *)getImagesAtIndex:(NSUInteger)position
{
    if (_rebuilding) {
        NSLog(@"Warning! [ImageCache clear] while rebuilding");
    }
    
    if (_collectionViewBehavior) {
        if (![self inRange:position]) {
            NSLog(@"[ImageCache getImagesAtIndex]: out of range");
            return nil;
        }
    } else {
        if (![self inRange:position]) {
            [self update];
            
            if (![self inRange:position]) {
                NSLog(@"[ImageCache getImagesAtIndex]: out of range");
                return nil;
            }
        }
    }
    
    return [[ImageCacheResult alloc] initWithItems:_scrollList[position - _location]];
}

- (UIImage *)imageForRequest:(ImageCacheRequest *)request
{
    ImageCacheImage *cachedImage = _cache[request.key];
    
    return cachedImage.image;
}

- (void)setImage:(UIImage *)image withRequest:(ImageCacheRequest *)request
{
    ImageCacheImage *cachedImage = _cache[request.key];
    
    if (!cachedImage) {
        cachedImage = [[ImageCacheImage alloc] initWithRequest:request];
        _cache[request.key] = cachedImage;
    }
    
    cachedImage.image = image;
    [self imageFetched:image forRequest:request];
}

- (void)setImage:(UIImage *)image forKey:(id<NSObject, NSCopying>)key
{
    ImageCacheImage *cachedImage = _cache[key];
    
    if (!cachedImage) {
        ImageCacheRequest *request = [ImageCacheRequest new];
        
        request.key = key;
        cachedImage = [[ImageCacheImage alloc] initWithRequest:request];
        _cache[request.key] = cachedImage;
    }
    
    cachedImage.image = image;
    [self imageFetched:image forRequest:cachedImage.request];
}

- (void)reorderWithRange:(NSRange)range
{
    if (![_delegate respondsToSelector:@selector(imageCache:reorderRequests:)]) {
        return;
    }
    
    assert((NSInteger)range.location >= _location);
    assert(((NSInteger)range.location + range.length) <= (_location + _scrollList.count));
    
    if ((NSInteger)range.location < _location) {
        return;
    }
    
    NSMutableArray *order = [NSMutableArray array];
    
    const NSUInteger startIndex = range.location - _location;
    const NSUInteger endIndex = startIndex + range.length;
    
    for (NSUInteger i = startIndex; i < endIndex && i < _scrollList.count; i++) {
        NSDictionary *items = _scrollList[i];
        
        for (NSArray *dupItems in items.allValues) {
            for (ImageCacheItem *cacheItem in dupItems) {
                if (cacheItem.cachedImage.canceler) {
                    [order addObject:cacheItem.cachedImage.canceler];
                }
            }
        }
    }
    
    if (order.count) {
        [_delegate imageCache:self reorderRequests:order];
    }
}

- (void)update
{
    if (_rebuilding) {
        NSLog(@"Warning! [ImageCache update] while rebuilding");
        return;
    }
    
    ImageCacheRanges *ranges = [_delegate imageCacheGetRange:self];
    
    [self updateWithRange:ranges.fullRange];
    [self reorderWithRange:ranges.visibleRange];
}

- (void)rebuildWithTableAction:(void(^)())tbAction
{
    if (_collectionViewBehavior) {
        [NSException raise:@"Logic error" format:@"Invalid action in ImageCache"];
    }
    
    for (ImageCacheImage *cachedImage in _cache.allValues) {
        [cachedImage clearIndexes];
    }
    
    [_scrollList removeAllObjects];
    
    tbAction();
    
    [self update];
    
    for (id key in _cache.allKeys) {
        ImageCacheImage *cachedImage = _cache[key];
        
        if (![cachedImage hasIndexes]) {
            [cachedImage.canceler cancel];
            [_cache removeObjectForKey:key];
        }
    }
}

- (void)rebulidWithCollectionStage:(void(^)(CollectionStageComplete onComplete))colectionStage
{
    if (_rebuilding) {
        NSLog(@"Warning! [ImageCache rebulidWithCollectionStage] while rebuilding");
        return;
    }
    
    for (ImageCacheImage *cachedImage in _cache.allValues) {
        [cachedImage clearIndexes];
    }
    
    [_scrollList removeAllObjects];
    
    _rebuilding = YES;
    
    colectionStage(^{
        _rebuilding = NO;
        
        [self update];
        
        for (id key in _cache.allKeys) {
            ImageCacheImage *cachedImage = _cache[key];
            
            if (![cachedImage hasIndexes]) {
                [cachedImage.canceler cancel];
                [_cache removeObjectForKey:key];
            }
        }
    });
}

- (void)rebuild
{
    [self rebuildWithTableAction:^{
        [_delegate imageCacheReloadTable:self];
    }];
}

- (void)rebuildItemAtIndex:(NSInteger)position
{
    if (_rebuilding) {
        NSLog(@"Warning! [ImageCache rebuildItemAtIndex] while rebuilding");
        return;
    }
    
    //if item not in cache yet
    if (![self inRange:position]) {
        return;
    }
    
    const NSInteger arrayIndex = position - _location;
    NSMutableDictionary *currPositionItems = _scrollList[arrayIndex];
    NSMutableDictionary *allUncached = [NSMutableDictionary dictionary];
    
    for (NSMutableArray *dupItems in currPositionItems.allValues) {
        for (ImageCacheItem *item in dupItems) {
            NSDictionary *uncached = [self discardImage:item atPosition:position discardNetOperation:NO];
            
            if (uncached) {
                [allUncached addEntriesFromDictionary:uncached];
            }
        }
    }
    
    _scrollList[arrayIndex] = [self requestImagesAtPosition:position otherCache:allUncached];
}

- (void)clear
{
    if (_rebuilding) {
        NSLog(@"Warning! [ImageCache clear] while rebuilding");
        return;
    }
    
    [_scrollList removeAllObjects];
    [_cache removeAllObjects];
    _location = 0;
}

- (void)cancelPendingRequests
{
    for (ImageCacheImage *cachedImage in _cache.allValues) {
        [cachedImage.canceler cancel];
        cachedImage.canceler = nil;
    }
}

- (void)restartRequests
{
    for (ImageCacheImage *cachedImage in _cache.allValues) {
        if (!cachedImage.image) {
            [cachedImage.canceler cancel];
            cachedImage.canceler = [self runRequestWithItemRequest:cachedImage.request];
        }
    }
}

@end
