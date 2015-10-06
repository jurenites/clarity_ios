//
//  FileCacheRequest.m
//  Brabble-iOSClient
//
//  Created by Alexey on 2/14/14.
//
//

#import "FileCacheRequest.h"

@implementation FileCacheRequest

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;
    
    _cacheName = @"";
    _fileName = @"";
    
    return self;
}

@end
