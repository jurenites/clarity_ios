//
//  MiscUtils.h
//  StaffApp
//
//  Created by Alexey Klyotzin on 6/30/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

void DispatchAfter(NSTimeInterval delay, void (^block)());
void CallSyncOnMainThread(void (^block)());
NSString* TimeRangeTo12String(NSInteger from, NSInteger to);