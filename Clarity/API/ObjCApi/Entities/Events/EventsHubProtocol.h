//
//  EventsHubProtocol.h
//  TRN
//
//  Created by Oleg Kasimov on 2/23/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Flow;

@protocol EventsHubProtocol <NSObject>

@optional
- (void)updateChat:(NSInteger)orderId;

- (void)flowFinished:(Flow *)flow;

@end
