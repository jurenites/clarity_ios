//
//  TimePicker.m
//  TRN
//
//  Created by Oleg Kasimov on 1/5/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import "TimePicker.h"
#import "Time.h"
#import "NSDate+Utils.h"
#import "DoneAccessoryView.h"

static NSInteger const SearchFromNowTimeDelta = 15;

@interface TimePicker ()
{
    NSString *_placeholderText;
    UIDatePicker *_datePicker;
    NSCalendar *_gregorianCalendar;
    NSString *_accessoryTitle;
    Time *_timeOnStart;
    NSInteger _minHours;
    NSInteger _maxHours;
    
    NSTimeZone *_timeZone;
}

@property (strong, nonatomic) IBOutlet UILabel *uiTime;
@property (assign, nonatomic) BOOL maxTimeSelected;
@property (assign, nonatomic) BOOL oneHourOffset;
@property (assign, nonatomic) BOOL prefill;
@property (assign, nonatomic) NSInteger customMinHours;
@property (assign, nonatomic) NSInteger customMaxHours;

@end

@implementation TimePicker

- (void)awakeFromNib
{
    if (!self.customMinHours) {
        _minHours = DayStartHour;
    } else {
        _minHours = self.customMinHours;
    }
    
    if (!self.customMaxHours) {
        _maxHours = DayStopHour;
    } else {
        _maxHours = self.customMaxHours;
    }
    
    _gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    _datePicker = [UIDatePicker new];
    _datePicker.backgroundColor = [UIColor whiteColor];
    _datePicker.datePickerMode = UIDatePickerModeTime;
    _datePicker.calendar = _gregorianCalendar;
    _datePicker.minuteInterval = 15;
    _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    _selectedTime = [Time new];
    
    _accessoryTitle = NSLocalizedString(@"Select time", nil);
    
    [_datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    [self addTarget:self action:@selector(becomeFirstResponder) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupWithTimeZone:(NSTimeZone *)timeZone
{
    _timeZone = timeZone;
    
    _gregorianCalendar.timeZone = timeZone;
    _datePicker.timeZone = timeZone;
    
    [self setup];
}

- (void)setup
{
    NSDateComponents *cc = [_gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit)
                                                 fromDate:[NSDate date]];
    BOOL higherThenStart = ((cc.hour*60 + cc.minute) - _minHours*60) > -15;
//    BOOL lowerThenEnd = (_minHours * 60 - (cc.hour*60 + cc.minute)) <= 0;
    if (self.isTodayTime && higherThenStart) {
        [self setupFutureTime];
    } else {
        [self setupDefaultTime];
    }

    [self setValid:YES];
}

- (void)setupTimeRangeFromComponents:(NSDateComponents *)components
{
    _datePicker.minimumDate = [_gregorianCalendar dateFromComponents:components];
    [components setHour:_maxHours];
    [components setMinute:0];
    _datePicker.maximumDate = [_gregorianCalendar dateFromComponents:components];
    
    [_datePicker setDate:self.maxTimeSelected ?_datePicker.maximumDate : _datePicker.minimumDate
                animated:YES];
}

//Setup nearest time 15mins later and it should be multiple by 15mins
- (void)setupFutureTime
{
    NSTimeInterval offset = self.oneHourOffset ? 60*60 : SearchFromNowTimeDelta*60;
    NSDateComponents *cc = [_gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit)
                                                 fromDate:[NSDate dateWithTimeIntervalSinceNow:offset]];
    

    cc.minute = ceil((cc.minute / 60.0) * (60/_datePicker.minuteInterval)) * _datePicker.minuteInterval;
    
    if (cc.minute == 60) {
        cc.hour += 1;
        cc.minute = 0;
    }
    
    if (cc.hour >= _maxHours) {
        cc.hour = _maxHours;
        cc.minute = 0;
    }
    
    [self setupTimeRangeFromComponents:[cc copy]];
    
    _timeOnStart = [Time new];
    _timeOnStart.minute = cc.minute;
    _timeOnStart.hour = cc.hour;
    
    if (self.prefill) {
        [self selectTime:_timeOnStart];
    }
}

- (void)setupDefaultTime
{
    NSDateComponents *cc = [_gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit)
                                                 fromDate:[NSDate date]];

    [cc setHour:_minHours];
    [cc setMinute:0];
    
    [self setupTimeRangeFromComponents:[cc copy]];
    
    _timeOnStart = [Time new];
    _timeOnStart.hour = self.maxTimeSelected ? _maxHours : _minHours;
    _timeOnStart.minute = 0;
    
    if (self.prefill) {
        [self selectTime:_timeOnStart];
    }
}

- (void)dateChanged
{
    NSDateComponents *cc = [_gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit)
                                                 fromDate:_datePicker.date];
    _selectedTime.hour = [cc hour];
    _selectedTime.minute = [cc minute];
    
    self.uiTime.text = [_selectedTime stringRepresentetionWithTimeType:TimeType12];

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setValid:(BOOL)isValid
{
    self.layer.borderColor = isValid ? [UIColor whiteColor].CGColor:[UIColor redColor].CGColor;
    self.layer.borderWidth = isValid ? 0.0 : 1.0;
}

- (void)setIsTodayTime:(BOOL)isTodayTime
{
    _isTodayTime = isTodayTime;
    
    NSDateComponents *cc = [_gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit)
                                                 fromDate:[NSDate date]];
    
    NSInteger result = (cc.hour*60 + cc.minute) - _minHours*60;
    
    NSTimeInterval offset = self.oneHourOffset ? 60 : SearchFromNowTimeDelta;
    if (_isTodayTime && result > -offset) {
        [self setupFutureTime];
    } else {
        [self setupDefaultTime];
    }
}

- (void)selectSchedTime:(NSInteger)schedTime
{
    [self selectTime:[Time fromSchedTime:schedTime]];
}

- (NSInteger)selectedSchedTime
{
    return [self.selectedTime toSchedTime];
}

- (void)selectTime:(Time *)time
{
    _selectedTime = time;//[time copy];
    self.uiTime.text = [_selectedTime stringRepresentetionWithTimeType:TimeType12];
    
    NSDateComponents *cc = [_gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit)
                                                 fromDate:[NSDate date]];
    [cc setHour:_selectedTime.hour];
    [cc setMinute:_selectedTime.minute];
    
    NSDate *date = [_gregorianCalendar dateFromComponents:cc];
    [_datePicker setDate:date animated:YES];
}

- (void)selectMinTime
{
    _selectedTime.hour = DayStartHour;
    _selectedTime.minute = 0;
    self.uiTime.text = [_selectedTime stringRepresentetionWithTimeType:TimeType12];
}

- (void)selectMaxTime
{
    _selectedTime.hour = _maxHours;
    _selectedTime.minute = 0;
    self.uiTime.text = [_selectedTime stringRepresentetionWithTimeType:TimeType12];
}

- (void)setAccessoryTitle:(NSString *)title
{
    if ([self.inputAccessoryView isKindOfClass:[DoneAccessoryView class]]) {
        [(DoneAccessoryView *)self.inputAccessoryView setTitle:title hash:[self hash]];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    [self setAccessoryTitle:_accessoryTitle];
    
    if (!self.prefill) { //When the picker is shown we have to set default or future time.
        [self selectTime:_timeOnStart];
    }
    
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    [self setAccessoryTitle:nil];
    return [super resignFirstResponder];
}

- (UIView *)inputView
{
    return _datePicker;
}

@end
