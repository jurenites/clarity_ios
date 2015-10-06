//
//  NSDate+Api.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/5/13.
//
//

#import "NSDate+Api.h"

@implementation NSDate (Api)

- (NSDate *)dateValue
{
    return self;
}

- (NSString *)stringValue
{
    static NSDateFormatter *dateFormatter = nil;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    });
    
    return [dateFormatter stringFromDate:self];
}

@end
