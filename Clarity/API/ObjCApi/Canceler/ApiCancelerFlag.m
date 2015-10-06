//
//  ApiCancelerFlag.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/28/14.
//
//

#import "ApiCancelerFlag.h"

@interface ApiCancelerFlag ()
{
    BOOL _isCanceled;
}
@end

@implementation ApiCancelerFlag

- (void)cancel
{
    @synchronized(self) {
        _isCanceled = YES;
    }
}

-(BOOL)isCanceled
{
    @synchronized(self) {
        return _isCanceled;
    }
}

@end
