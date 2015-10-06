//
//  Flow.h
//  TRN
//
//  Created by Oleg Kasimov on 8/18/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import "UniqueObject.h"

@class Flow;
@protocol FlowDelegate <NSObject>

- (void)flowStatusChanged:(Flow *)flow;

@end

typedef NS_ENUM(NSUInteger, FlowStatus) {
    FlowStatusIdle = 0,
    FlowStatusActive,
    FlowStatusComplete,
};

@interface Flow : UniqueObject

- (instancetype)initWithMethod:(ApiMethodID)methodId screensSequence:(NSOrderedSet *)sequence ordered:(BOOL)ordered delegate:(id<FlowDelegate>)delegate;

- (BOOL)validateScreen:(NSString *)screenName;

@property (assign, nonatomic) NSInteger requestID;
@property (weak, nonatomic) id<FlowDelegate> delegate;
@property (readonly) ApiMethodID method;
@property (readonly) NSOrderedSet *screensSequence;
@property (readonly) BOOL isOrdered;
@property (readonly) FlowStatus status;

@end
