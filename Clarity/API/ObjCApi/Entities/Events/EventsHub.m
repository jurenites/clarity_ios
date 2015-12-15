//
//  EventsHub.m
//  TRN
//
//  Created by Oleg Kasimov on 2/23/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import "EventsHub.h"
#import "DelegatesHolder.h"
#import "ClarityApiManager.h"
//#import "Chat.h"
#import "Flow.h"

@interface EventsHub () <FlowDelegate>
{
    DelegatesHolder *_delegates;
    NSArray *_flows;
}
@end

@implementation EventsHub

+ (EventsHub *)shared
{
    static EventsHub *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [EventsHub new];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _delegates = [DelegatesHolder new];
    [self setupFlows];
    
    return self;
}

- (void)addListener:(id<EventsHubProtocol>)listener
{
    [_delegates addDelegate:listener];
}

- (void)removeListener:(id<EventsHubProtocol>)listener
{
    [_delegates removeDelegate:listener];
}

- (void)chatUpdated:(NSInteger)chatId messageId:(NSInteger)messageId action:(NSString *)action
{
    for (id<EventsHubProtocol> d in [_delegates getDelegates]) {
        if ([d respondsToSelector:@selector(updateChat:messageId:action:)]) {
            [d updateChat:chatId messageId:messageId action:action];
        }
    }
}

- (void)orderUpdated:(NSInteger)orderId action:(NSString *)action
{
    for (id<EventsHubProtocol> d in [_delegates getDelegates]) {
        if ([d respondsToSelector:@selector(updateOrder:action:)]) {
            [d updateOrder:orderId action:action];
        }
    }
}

#pragma mark -- Flows
- (void)setupFlows
{
//    Flow *createSession = [[Flow alloc] initWithMethod:AMGetUsers
//                                       screensSequence:[NSOrderedSet orderedSetWithArray:@[NSStringFromClass([VCtrlFindTrainer class]),
//                                                                                           NSStringFromClass([VCtrlSpecialistsList class]),
//                                                                                           NSStringFromClass([VCtrlSched class]),
//                                                                                           NSStringFromClass([VCtrlSessionSummary class])]]
//                                               ordered:NO
//                                              delegate:self];
//    _flows = @[createSession];
}

- (Flow *)flowByMethod:(ApiMethodID)method
{
    for (Flow *flow in _flows) {
        if (flow.method == method) {
            return flow;
        }
    }
    
    return nil;
}

- (void)screenOpened:(NSString *)screenName
{
    for (Flow *flow in _flows) {
        [flow validateScreen:screenName];
    }
}

- (void)finishFlow:(Flow *)flow
{
    for (id<EventsHubProtocol> d in [_delegates getDelegates]) {
        if ([d respondsToSelector:@selector(flowFinished:)]) {
            [d flowFinished:flow];
        }
    }
}

#pragma mark - FlowDelegate
- (void)flowStatusChanged:(Flow *)flow
{
    if (flow.status == FlowStatusComplete) {
        [self finishFlow:flow];
    }
}

@end
