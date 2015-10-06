//
//  IORequest.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/7/13.
//
//

#import "IORequest.h"
#import "IORequest_Private.h"

@interface IORequest ()
{
    UniqueNumber *_requestId;
    int _restartCount;
}
@end

@implementation IORequest

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;

    self.onSuccess = ^(id result) {
        NSLog(@"Warning! Default OnIOSuccess called");
    };
    
    self.onError = ^(id result) {
        NSLog(@"Warning! Default OnIOError called");
    };
    
    return self;
}

- (instancetype)initWithId:(UniqueNumber *)requestId
{
    self = [super init];
    if (!self)
        return nil;
    
    _requestId = requestId;
    
    return self;
}

- (id)uniqueId
{
    return self.requestId.uniqueId;
}

- (IOOperation *)makeOperationWithDelegate:(id<IOOperationDelegate>)delegate
{
    NSAssert(FALSE, @"Unimplemented method call", nil);
    return nil;
}

- (void)setRequestId:(UniqueNumber *)reqId
{
    _requestId = reqId;
}

- (UniqueNumber *)requestId
{
    return _requestId;
}

- (BOOL)restart
{
    if (_restartCount >= 1) {
        return NO;
    }
    
    _restartCount++;
    
    if (self.beforeRestart) {
        self.beforeRestart(self);
    }
    
    return YES;
}

@end
