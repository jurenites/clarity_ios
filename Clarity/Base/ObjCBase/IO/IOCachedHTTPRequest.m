//
//  IOCachedHTTPRequest.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/9/13.
//
//

#import "IOCachedHTTPRequest.h"
#import "IOCachedHTTPOperation.h"

@implementation IOCachedHTTPRequest

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;
    
    _cache = [AvatarCacheRequest new];
    
    return self;
}

- (IOOperation *)makeOperationWithDelegate:(id<IOOperationDelegate>)delegate
{
    return [[IOCachedHTTPOperation alloc] initWithRequest:self delegate:delegate];
}

@end
