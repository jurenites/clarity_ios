//
//  ImageCacheResult.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/5/14.
//
//

#import <Foundation/Foundation.h>
#import "ImageCacheItem.h"

@interface ImageCacheResult : NSObject

- (instancetype)initWithItems:(NSDictionary *)items;

- (void)enumerateWithBlock:(void(^)(ImageCacheRequest *request, UIImage *image, BOOL *stop))block;

@property (readonly, nonatomic) NSInteger count;

@end
