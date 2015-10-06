//
//  Flow.m
//  TRN
//
//  Created by Oleg Kasimov on 8/18/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import "Flow.h"

@interface Flow ()
{
    NSInteger _lastScreenIndex;
}

@end

@implementation Flow

- (instancetype)initWithMethod:(ApiMethodID)methodId screensSequence:(NSOrderedSet *)sequence ordered:(BOOL)ordered delegate:(id<FlowDelegate>)delegate
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _method = methodId;
    _screensSequence = [NSOrderedSet orderedSetWithOrderedSet:sequence];
    _isOrdered = ordered;
    _lastScreenIndex = 0;
    _status = FlowStatusIdle;
    self.delegate = delegate;
    
    return self;
}

- (BOOL)validateScreen:(NSString *)screenName
{
    FlowStatus prevStatus = _status;
    if (![_screensSequence containsObject:screenName]) {
        if (prevStatus != FlowStatusIdle) {
            [self statusChanged];
            _status = FlowStatusIdle;
        }
        
        return NO;
    }
    
    //The first and necessary screen for Flow
    if ([[_screensSequence firstObject] isEqualToString:screenName]) {
        _status = FlowStatusActive;
        [self statusChanged];
        return YES;
    }
    
    //The last and necessary screen for Flow
    if ([[_screensSequence lastObject] isEqualToString:screenName]) {
        _status = FlowStatusComplete;
        [self statusChanged];
        return YES;
    }
    
    //Flow started not from beginning, skip
    if (prevStatus == FlowStatusIdle) {
        return NO;
    }
    
    _status = FlowStatusActive;
    return YES;
}

- (void)statusChanged
{
    if ([self.delegate respondsToSelector:@selector(flowStatusChanged:)]) {
        [self.delegate flowStatusChanged:self];
    }
}

@end
