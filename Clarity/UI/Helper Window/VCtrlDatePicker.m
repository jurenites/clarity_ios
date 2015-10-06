//
//  VCtrlDatePicker.m
//  TRN
//
//  Created by stolyarov on 04/12/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "VCtrlDatePicker.h"
#import "NSDateFormatter+Utils.h"

static const NSInteger kSecondsInDay = 60 * 60 * 24;

@interface VCtrlDatePicker ()
{
    UIWindow *_prevWindow;
    UIWindow *_window;
    
    BOOL _showed;
    NSString *_title;
}
@property (strong, nonatomic) IBOutlet UILabel *uiTitle;
@property (strong, nonatomic) IBOutlet UIView *uiControlView;
@property (strong, nonatomic) IBOutlet UIDatePicker *uiDatePicker;

@end

@implementation VCtrlDatePicker

- (instancetype)initWithTitle:(NSString *)title
              datePickerType:(DatePickerType)type
{
    self = [self initWithNibName:@"VCtrlDatePicker" bundle:nil];
    if (!self) {
        return nil;
    }
    _pickerTitle = title;
    _type = type;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.uiControlView.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer new];
    maskLayer.frame = self.uiControlView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.uiControlView.layer.mask = maskLayer;
    
    self.pickerTitle = _pickerTitle;
    self.type = _type;
    
    NSDateFormatter *formatter = [NSDateFormatter defaultFormatter];
    [formatter setDateFormat:@"dd-MM-yyyy hh:mm:ss"];
    
    self.uiDatePicker.date = [NSDate date];
    
    if(_type == DatePickerTypeDate) {
        self.uiDatePicker.minimumDate = [NSDate date];
        self.uiDatePicker.maximumDate = [[NSDate date] dateByAddingTimeInterval: kSecondsInDay * 12];
    } else {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *componentsStart = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
        NSDateComponents *componentsStop = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];

        componentsStart.hour = 5;
        componentsStop.hour = 23;
//        [formatter setDateFormat:@"dd-MM-yyyy"];
//        NSString *dt = [formatter stringFromDate:[NSDate date]];
//        NSString *start_d = [NSString stringWithFormat:@"%@ 05:00:00",dt];
//        NSString *stop_d = [NSString stringWithFormat:@"%@ 23:00:00",dt];
//    
//        self.uiDatePicker.date = [formatter dateFromString:start_d];
//        self.uiDatePicker.minimumDate = [formatter dateFromString:start_d];
//        self.uiDatePicker.maximumDate = [formatter dateFromString:stop_d];
        self.uiDatePicker.date = [calendar dateFromComponents:componentsStart];
        self.uiDatePicker.minimumDate = [calendar dateFromComponents:componentsStart];
        self.uiDatePicker.maximumDate = [calendar dateFromComponents:componentsStop];
    }
    
    
     self.uiTitle.font = [UIFont fontWithName:@"Fritz Quadrata Cyrillic" size:18.];

}

- (void)showOnComplete:(void (^)())onComplete
{
    _prevWindow = [[UIApplication sharedApplication] keyWindow];
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _window.opaque = NO;
    _window.backgroundColor = [UIColor clearColor];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _window.windowLevel = _prevWindow.windowLevel + 1;
    _window.rootViewController = self;
    [_window makeKeyAndVisible];
    
    self.view.superview.alpha = 0;
    [UIView animateWithDuration:0.33f
                     animations:^{
                         self.view.superview.alpha = 1.0;
                     } completion:^(BOOL finished){
                         onComplete();
                         _showed = YES;
                     }];
}

- (void)hideOnComplete:(void(^)())onComplete
{
    if (!onComplete) {
        onComplete = ^{};
    }
    if (!_showed) {
        onComplete();
        return;
    }
    [UIView animateWithDuration:0.33
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.view layoutIfNeeded];
                         self.view.superview.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             _window.hidden = YES;
                             _window.rootViewController = nil;
                             [_window removeFromSuperview];
                             _window = nil;
                             _showed = NO;
                             onComplete();
                         });
                     }];
}

- (void)setType:(DatePickerType)type
{
    _type = type;
    switch (_type) {
        case DatePickerTypeDate:
            self.uiDatePicker.datePickerMode = UIDatePickerModeDate;
            break;
        case DatePickerTypeTime:
            self.uiDatePicker.datePickerMode = UIDatePickerModeTime;
            break;
        default:
            break;
    }
}

- (void)setPickerTitle:(NSString *)pickerTitle
{
    _pickerTitle = pickerTitle;
    self.uiTitle.text = _pickerTitle;
}

#pragma mark Action
- (IBAction)actDone
{
    if ([self.delegate respondsToSelector:@selector(datePicker:doneWithDate:)]) {
        [self.delegate datePicker:self doneWithDate:self.uiDatePicker.date];
    }
    [self hideOnComplete:nil];
}

- (IBAction)actClose
{
    [self hideOnComplete:nil];
}
@end
