//
//  VCtrlDatePicker.h
//  TRN
//
//  Created by stolyarov on 04/12/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "VCtrlBase.h"

typedef enum {
    DatePickerTypeDate,
    DatePickerTypeTime
} DatePickerType;

@class VCtrlDatePicker;
@protocol VCtrlDatePickerDelegate <NSObject>
- (void)datePicker:(VCtrlDatePicker *)datePicker doneWithDate:(NSDate *)date;
@end

@interface VCtrlDatePicker : VCtrlBase

@property (assign, nonatomic) id <VCtrlDatePickerDelegate> delegate;
@property (assign, nonatomic) DatePickerType type;
@property (strong, nonatomic) NSString *pickerTitle;


- (instancetype)initWithTitle:(NSString*)title
               datePickerType:(DatePickerType)type;

- (void)showOnComplete:(void(^)())onComplete;
- (void)hideOnComplete:(void(^)())onComplete;
@end
