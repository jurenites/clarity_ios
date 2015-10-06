//
//  NSThread+Utils.m
//  Brabble-iOSClient
//
//  Created by Alexey on 2/14/14.
//
//

#import "NSThread+Utils.h"

@implementation NSThread (Utils)

- (void)performBlockImpl:(void (^)())block
{
    if (block) {
        block();
    }
}

- (void)performBlock:(void(^)())block
{
    [self performSelector:@selector(performBlockImpl:) onThread:self withObject:[block copy] waitUntilDone:YES];
}

- (void)performAsyncBlock:(void(^)())block
{
    [self performSelector:@selector(performBlockImpl:) onThread:self withObject:[block copy] waitUntilDone:NO];
}

@end
