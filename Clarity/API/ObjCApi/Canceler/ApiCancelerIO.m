//
//  ApiCancelerIO.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/10/14.
//
//

#import "ApiCancelerIO.h"
#import "ApiManager.h"

@interface ApiCancelerIO ()
{
    ApiManager * __weak _apm;
    const void *_ioManager;
    UniqueNumber *_reqId;
}
@end

@implementation ApiCancelerIO

- (instancetype)initWithApiManager:(ApiManager *)apm
                         ioManager:(const void *)ioManager
                             reqId:(UniqueNumber *)reqId
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _apm = apm;
    _ioManager = ioManager;
    _reqId = reqId;
    
    return self;
}

- (void)cancel
{
    [_apm cancelReqId:_reqId ioManager:_ioManager];
}

- (const void *)ioManager
{
    return _ioManager;
}

- (UniqueNumber *)requestId
{
    return _reqId;
}

@end
