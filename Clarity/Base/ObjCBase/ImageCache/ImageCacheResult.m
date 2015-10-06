//
//  ImageCacheResult.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/5/14.
//
//

#import "ImageCacheResult.h"

@interface ImageCacheResult ()
{
    NSDictionary *_items;
}
@end

@implementation ImageCacheResult

- (instancetype)initWithItems:(NSDictionary *)items
{
    self = [super init];
    if (!self)
        return nil;
    
    _items = items;
    
    return self;
}

- (void)enumerateWithBlock:(void(^)(ImageCacheRequest *request, UIImage *image, BOOL *stop))block
{
    for (NSMutableArray *dupItems in _items.allValues) {
        for (ImageCacheItem *item in dupItems) {
            BOOL stop = NO;
            
            block(item.request, item.image, &stop);
            if (stop) {
                return;
            }
        }
    }
}

- (NSInteger)count
{
    NSInteger count = 0;
    
    for (NSMutableArray *dupItems in _items.allValues) {
        count += dupItems.count;
    }
    
    return count;
}

@end
