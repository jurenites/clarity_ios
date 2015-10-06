//
//  IOOperation.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/8/13.
//
//

#import "IOOperation.h"
#import "IORequest.h"

@implementation IOOperation

@dynamic request;

- (instancetype)initWithDelegate:(id<IOOperationDelegate>)delegate
{
    self = [super init];
    if (!self)
        return nil;
    
    _delegate = delegate;
    
    return self;
}

- (void)perform
{
    NSAssert(FALSE, @"Unimplemented method call", nil);
}

- (void)startNetworkOperation
{
    NSAssert(FALSE, @"Unimplemented method call", nil);
}

- (void)cancel
{
    NSAssert(FALSE, @"Unimplemented method call", nil);
}

- (id)uniqueId
{
    return self.request.requestId.uniqueId;
}

- (BOOL)highPrio
{
    return self.request.highPrio;
}

#pragma mark -- --------------

static volatile int TotalActiveOps = 0;

- (void)needSpinner
{
    @synchronized([IOOperation class]) {
        if (++TotalActiveOps == 1)
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

- (void)discardSpinner
{
    @synchronized([IOOperation class]) {
        if (--TotalActiveOps < 1)
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

@end
