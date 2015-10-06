//
//  NSDateFormatter+Utils.m
//  TRN
//
//  Created by stolyarov on 23/03/2015.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import "NSDateFormatter+Utils.h"

@implementation NSDateFormatter (Utils)

+ (NSDateFormatter *)defaultFormatter
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.locale = usLocale;
    });    
    return formatter;
}

+ (NSDateFormatter *)currentFormatter
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.locale = usLocale;
    });
//    formatter.timeZone = [GlobalEntitiesCtrl shared].myTimeZone;

    
    return formatter;
}

@end
