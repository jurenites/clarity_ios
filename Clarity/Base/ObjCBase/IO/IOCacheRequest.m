//
//  IOCacheRequest.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/17/14.
//
//

#import "IOCacheRequest.h"
#import "IOCacheOperation.h"

@implementation IOCacheRequest

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;
    
    _cache = [FileCacheRequest new];
    
    return self;
}

- (IOOperation *)makeOperationWithDelegate:(id<IOOperationDelegate>)delegate
{
    return [[IOCacheOperation alloc] initWithRequest:self delegate:delegate];
}


@end
