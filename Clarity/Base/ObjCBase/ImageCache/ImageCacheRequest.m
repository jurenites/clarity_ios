//
//  ImageCacheItem.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 12/5/13.
//
//

#import "ImageCacheRequest.h"

@implementation ImageCacheRequest

- (instancetype)init{
    self = [super init];
    if (!self)
        return nil;
    
    self.key = [NSNull null];
    
    return self;
}

@end
