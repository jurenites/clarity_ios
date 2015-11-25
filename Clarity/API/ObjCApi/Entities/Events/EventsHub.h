//
//  EventsHub.h
//  TRN
//
//  Created by Oleg Kasimov on 2/23/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventsHubProtocol.h"

@interface EventsHub : NSObject <EventsHubProtocol>

+ (EventsHub *)shared;

- (void)chatWasUpdated:(NSInteger)chatId;
//- (void)updateDashboardCounters;
//- (void)updateCurrentUser;
//
//- (void)enqueueSession:(Session *)session;
//- (void)startSession:(Session *)session;
//- (void)finishSession:(Session *)session;
//- (void)rateSessions:(NSArray *)sessions;
//
- (void)addListener:(id<EventsHubProtocol>)listener;
- (void)removeListener:(id<EventsHubProtocol>)listener;

//- (Flow *)flowByMethod:(ApiMethodID)method;
- (void)screenOpened:(NSString *)screenName;

@end
