//
//  MiscUtils.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 6/30/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "MiscUtils.h"

void DispatchAfter(NSTimeInterval delay, void (^block)())
{
    dispatch_time_t fireTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(fireTime, dispatch_get_main_queue(), block);
}

void CallSyncOnMainThread(void (^block)())
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

NSString* TimeRangeTo12String(NSInteger from, NSInteger to)
{
    int count = 0;
    BOOL previousValue = NO;
    NSMutableString *result = [NSMutableString new];
    
    for (NSNumber *time in @[@(from), @(to)]) {
        int hour = time.intValue / 60;
        int minute = time.intValue % 60;
        int amPmHour = 0;
        BOOL isPm = NO;
        
        if (hour == 0) {
            amPmHour = 12;
            isPm = NO;
        } else if (hour == 12) {
            amPmHour = 12;
            isPm = YES;
        } else if (hour > 12) {
            amPmHour = hour - 12;
            isPm = YES;
        } else {
            amPmHour = hour;
            isPm = NO;
        }
        
        if (count == 0) {
            previousValue = isPm;
            result = [NSMutableString stringWithFormat:@"%d:%02d", amPmHour, minute];
        } else {
            if (previousValue != isPm) {
                [result appendString: previousValue ? @"pm" : @"am"];
            }
            [result appendFormat:@"-%d:%02d", amPmHour, minute];
            [result appendString: isPm ? @"pm" : @"am"];
        }
        count += 1;
        
    }
    return result;
}

//func rangeTo12String(from : Int, to : Int) ->  String {
//    var result : String = ""
//    var count : Int = 0
//    var previousValue : Bool = false
//    
//    for time in [from,to] {
//        let hour = time / 60
//        let minute = time % 60
//        var amPmHour = 0
//        var isPm = false
//        
//        if hour == 0 {
//            amPmHour = 12
//            isPm = false
//        } else if hour == 12 {
//            amPmHour = 12
//            isPm = true
//        } else if hour > 12 {
//            amPmHour = hour - 12
//            isPm = true
//        } else {
//            amPmHour = hour
//            isPm = false
//        }
//        
//        if (count == 0) {
//            previousValue = isPm
//            result = String(format: "%d:%02d", amPmHour, minute)
//        } else {
//            if (previousValue != isPm) {
//                result += previousValue ? "pm":"am"
//            }
//            result += "-" + String(format: "%d:%02d", amPmHour, minute)
//            result += isPm ? "pm":"am"
//        }
//        count += 1
//    }
//    
//    return result
//}