//
//  ImageCacheImage.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/5/14.
//
//

#import "ImageCacheImage.h"
#import "InternalError.h"

@interface ImageCacheImage ()
{
    NSMutableDictionary *_indexes;
}
@end

@implementation ImageCacheImage

- (instancetype)initWithRequest:(ImageCacheRequest *)item
{
    self = [super init];
    if (!self)
        return nil;
    
    _request = item;
    _indexes = [NSMutableDictionary dictionary];
    
    return self;
}

- (void)addScrollIndex:(NSInteger)pos
{
    NSNumber *count = _indexes[@(pos)];
    
    if (!count) {
        count = @(1);
    } else {
        count = @(count.integerValue + 1);
    }
    
    _indexes[@(pos)] = count;
}

- (void)removeScrollIndex:(NSInteger)pos
{
    NSNumber *count = _indexes[@(pos)];
    
    if (!count) {
        [[InternalError errorWithDescr:@"[ImageCacheImage removeScrollIndex]: inconsistency"] raise];
    }
    
    if (count.integerValue <= 1) {
        [_indexes removeObjectForKey:@(pos)];
    } else {
        _indexes[@(pos)] = @(count.integerValue - 1);
    }
}

- (void)clearIndexes
{
    [_indexes removeAllObjects];
}

- (NSSet *)getIndexesCopy
{
    return [NSSet setWithArray:_indexes.allKeys];
}

- (BOOL)hasPosition:(NSInteger)position
{
    return _indexes[@(position)] != nil;
}

- (BOOL)hasIndexes
{
    return _indexes.count > 0;
}

@end
