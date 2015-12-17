//
//  VCtrlRoot.h
//  TRN
//
//  Created by stolyarov on 25/11/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "VCtrlBaseOld.h"

@interface VCtrlRoot : VCtrlBaseOld

+ (instancetype)current;

- (void)showMainUI;

- (void)showChatFromPush:(NSInteger)chatId;
- (void)processPush:(NSDictionary *)pushInfo active:(BOOL)isActive;
//- (void)setStartupPushData:(NSDictionary *)pushData;
//- (void)processPush:(NSDictionary *)pushData;

@end
