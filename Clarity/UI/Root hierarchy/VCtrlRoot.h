//
//  VCtrlRoot.h
//  TRN
//
//  Created by stolyarov on 25/11/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "VCtrlBase.h"

@interface VCtrlRoot : VCtrlBase

+ (instancetype)current;

- (void)showMainUI;

//- (void)setStartupPushData:(NSDictionary *)pushData;
//- (void)processPush:(NSDictionary *)pushData;

@end
