//
//  NSString+Api.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/8/13.
//
//

#import "NSString+Api.h"
#import "NSDateFormatter+Utils.h"

@implementation NSString (Api)

- (NSDate *)dateValue
{
    if (self.length < 4) {
        return nil;
    }
    
    static NSDateFormatter *dateFormatter = nil;
    static NSDateFormatter *dateFormatterShort = nil;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        dateFormatterShort = [[NSDateFormatter alloc] init];
        [dateFormatterShort setLocale:enUSPOSIXLocale];
        [dateFormatterShort setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [dateFormatterShort setDateFormat:@"yyyy-MM-dd"];
    });
    
    if (self.length > 10) {
        return [dateFormatter dateFromString:self];
    }
    
    return [dateFormatterShort dateFromString:self];
}

- (NSDate *)dateValueInScheduleFormat
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"]; //No seconds!
    });

    return [formatter dateFromString:self];
}

- (NSDate *)dateTimeValue
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    });
    return [dateFormatter dateFromString:self];
}

- (NSDate *)apiDateValue
{
    static NSDateFormatter *dateFormatter = nil;
    static NSDateFormatter *dateFormatterShort = nil;

    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter defaultFormatter];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        
        dateFormatterShort = [NSDateFormatter defaultFormatter];
        [dateFormatterShort setDateFormat:@"yyyy-MM-dd"];
    });
    if (self.length > 10) {
        return [dateFormatter dateFromString:self];
    }
    
    return [dateFormatterShort dateFromString:self];
}

-(NSString*)stringValue
{
    return self;
}

-(NSString*)urlEncode
{
    NSMutableString *result = [NSMutableString string];
    
    for (uint i = 0; i < self.length; i++) {
        unichar chr = [self characterAtIndex:i];
        switch(chr) {
            case '0' ... '9':
            case 'A' ... 'Z':
            case 'a' ... 'z':
            case '.':
            case '-':
            case '~':
            case '_':
                [result appendFormat:@"%c", chr];
                break;
            default:
                [result appendFormat:@"%%%02X", chr];
                break;
        }
    }
    
    return result;
    
//    CFStringRef encoded_CFString =
//        CFURLCreateStringByAddingPercentEscapes(
//            kCFAllocatorDefault,
//            (__bridge CFStringRef) self,
//            nil,
//            CFSTR("?!@#$^&%*+,:;='\"`<>()[]{}/\\| "), 
//            kCFStringEncodingUTF8);
//    
//    NSString *encoded =
//        [[NSString alloc]
//            initWithString:(__bridge_transfer NSString*) encoded_CFString];
//    
//    return encoded ? encoded : @"";
}

- (NSString *)toYoutubeThumb
{
    NSString *youtubeString = @"http://img.youtube.com/vi/";
    NSRange videoIDRange = [self rangeOfString:@"watch?v="];
    
    if (videoIDRange.location != NSNotFound) {
        youtubeString = [youtubeString stringByAppendingString:[self substringFromIndex:videoIDRange.location + videoIDRange.length]];
        youtubeString = [youtubeString stringByAppendingString:@"/0.jpg"];
    }
    
    return youtubeString;
}

@end
