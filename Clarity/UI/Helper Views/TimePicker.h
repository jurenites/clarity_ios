//
//  TimePicker.h
//  TRN
//
//  Created by Oleg Kasimov on 1/5/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Time;

@interface TimePicker : UIControl

- (void)setupWithTimeZone:(NSTimeZone *)timeZone;

- (void)setValid:(BOOL)isValid;
- (void)selectTime:(Time *)time;
- (void)selectSchedTime:(NSInteger)schedTime;
- (void)selectMinTime;
- (void)selectMaxTime;

@property (readonly, nonatomic) Time *selectedTime;
@property (readonly, nonatomic) NSInteger selectedSchedTime;
@property (strong, nonatomic) UIView *inputAccessoryView;
@property (assign, nonatomic) BOOL isTodayTime;

@end
