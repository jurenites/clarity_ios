//
//  DateUtils.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/12/14.
//
//

#import "DateUtils.h"
#import "NSDate+Utils.h"

@implementation DateUtils

+ (NSString *)timeSince:(NSDate *)date
{
    NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:date];
    if (duration == 0) {
        return @"unknown";
    }
    
    NSInteger minutes = duration/60;
    
    if (minutes == 0)
        return NSLocalizedString(@"1m", time label);
    
    if (minutes <= 30)
        return [NSString stringWithFormat:@"%ld%@", (long)minutes, NSLocalizedString(@"m", @"time display")];
    
    if (minutes <= 90)
        return @"1hr";
    
    int hours = ((int)minutes + 30) / 60;
    if (hours < 24)
        return [NSString stringWithFormat:@"%d%@",hours, NSLocalizedString(@"hr", @"time display")];
    
    if (hours <= 36)
        return NSLocalizedString(@"1d",@"time display");
    
    int days = (hours + 12) / 24;
    if (days < 7)
        return [NSString stringWithFormat:@"%d%@",days,NSLocalizedString(@"d", @"time display")];
    
    int weeks = (days) / 7;
    return [NSString stringWithFormat:@"%d%@",weeks,NSLocalizedString(@"w", @"time display")];
    
    
    
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    [df setDateStyle:NSDateFormatterMediumStyle];
//    return [df stringFromDate:date];
}

+ (NSString *)chatTimeSins:(NSDate *)date
{
    NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:date];
    if (duration == 0) {
        return @"unknown";
    }
    
    NSInteger minutes = fabs(duration/60);
    
    if (minutes == 0)
        return NSLocalizedString(@"new", time label);
    
    if (minutes <= 59)
        return [NSString stringWithFormat:@"%ld %@", (long)minutes, NSLocalizedString(@"m", @"time display")];
    
    if (minutes <= 119)
        return @"1 hr";
    
    int hours = ((int)minutes + 59) / 60;
    if (hours < 24)
        return [NSString stringWithFormat:@"%d%@",hours, NSLocalizedString(@"hr", @"time display")];
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM.dd"];
    return [df stringFromDate:date];
}

@end
