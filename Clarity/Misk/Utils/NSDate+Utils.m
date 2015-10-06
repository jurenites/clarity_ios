//
//  NSDate+Utils.m
//  TRN
//
//  Created by stolyarov on 03/02/2015.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import "NSDate+Utils.h"
#import "NSDateFormatter+Utils.h"

@implementation NSDate (Utils)
- (BOOL)isEqualDay:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    calendar.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSInteger comps = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
   
    NSDateComponents *date1 = [calendar components:comps
                                          fromDate:self];
    NSDateComponents *date2 = [calendar components:comps
                                     fromDate:date];
    
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
}

- (BOOL)isEqualDay:(NSDate *)date withCustomTimeZone:(NSTimeZone *)tz
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = tz;
    calendar.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSInteger comps = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
    
    NSDateComponents *date1 = [calendar components:comps
                                          fromDate:self];
    NSDateComponents *date2 = [calendar components:comps
                                          fromDate:date];
    
    return date1.year == date2.year &&
    date1.month == date2.month &&
    date1.day == date2.day;
}

- (NSInteger)minutes
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    calendar.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    return [calendar components:NSCalendarUnitMinute
                      fromDate:self].minute;
}

- (NSInteger)seconds
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    calendar.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    return [calendar components:NSCalendarUnitSecond
                       fromDate:self].second;
}


- (NSDate *)toApiDate
{
    return self;
    
    //Not needed after server went -4 NY time zone. Temporary.
//    NSTimeZone *tz = [NSTimeZone localTimeZone];
//    NSInteger seconds = -[tz secondsFromGMTForDate:self];
//    return [NSDate dateWithTimeInterval:seconds sinceDate:self];
}

- (NSDate *)toLocalDate
{
    return self;
    
    //Not needed after server went -4 NY time zone. Temporary.
//    NSTimeZone *tz = [NSTimeZone localTimeZone];
//    NSInteger seconds = [tz secondsFromGMTForDate:self];
//    return [NSDate dateWithTimeInterval:seconds sinceDate:self];
}


+ (NSDate *)localDate
{
    NSDate *date = [NSDate date];
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate:date];
    return [NSDate dateWithTimeInterval:seconds sinceDate:date];

}

- (NSString *)toApiString
{
    NSDateFormatter *dateFormatter = [NSDateFormatter defaultFormatter];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:self];
}

@end
