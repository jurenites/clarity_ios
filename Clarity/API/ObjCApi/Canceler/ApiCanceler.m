//
//  ApiCanceller.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/12/13.
//
//

#import "ApiCanceler.h"
//#import "ApiManager.h"
#import "UniqueNumber.h"

@interface ApiCanceler ()
{
    ApiCanceler *_chained;
    NSArray *_group;
}
@end

@implementation ApiCanceler

- (instancetype)initWithGroup:(NSArray *)group
{
    self = [super init];
    if (!self)
        return nil;
    
    _group = group;
    
    return self;
}

- (instancetype)initWithImpl:(ApiCancelerImplAbstract *)impl
{
    self = [super init];
    if (!self)
        return nil;
    
    _impl = impl;
    
    return self;
}

- (instancetype)initEmpty
{
    return [self initWithImpl:nil];
}

- (instancetype)initWithApiManager:(ApiManager *)apm
                         ioManager:(const void *)ioManager
                             reqId:(UniqueNumber *)reqId
{
    return [self initWithImpl:[[ApiCancelerIO alloc] initWithApiManager:apm
                                                              ioManager:ioManager
                                                                  reqId:reqId]];
}

- (instancetype)initWithApiManager:(ApiManager *)apm
                         dbManager:(const void *)dbManager
                             reqId:(UniqueNumber *)reqId
{
    return [self initWithImpl:[[ApiCancelerDB alloc] initWithApiManager:apm
                                                              dbManager:dbManager
                                                                  reqId:reqId]];
}

- (ApiCanceler *)chained
{
    @synchronized(self) {
        return _chained;
    }
}

- (void)setChained:(ApiCanceler *)canceler
{
    @synchronized(self) {
        _chained = canceler;
        _impl = nil;
    }
}

- (void)cancel
{
    [_chained cancel];
    [_impl cancel];
    
    for (ApiCanceler *c in _group) {
        [c cancel];
    }
    
    _group = nil;
    _impl = nil;
    _chained = nil;
}

@end
