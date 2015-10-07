//
//  NSObject+Api.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/8/13.
//
//

#import "NSObject+Api.h"

NSString* ToStringDef(id val, NSString *def_val)
{
    if (!val)
        return def_val;
    
    return [val stringValue];
}

float ToFloatDef(id val, float def_val)
{
    if (!val)
        return def_val;
    
    return [val floatValue];
}

NSInteger ToIntDef(id val, NSInteger def_val)
{
    if (!val)
        return def_val;
    
    return [val intValue];
}

BOOL ToBoolDef(id val, BOOL def_val)
{
    if (!val)
        return def_val;
    
    return [val boolValue];
}

NSDate *ToDateDef(id val, NSDate *def_val)
{
    if (!val) {
        return def_val;
    }
            
    NSDate *date = [val dateValue];
        
    return date ? date : def_val;
}

NSString* ToString(id val)
{
    return ToStringDef(val, @"");
}

float ToFloat(id val)
{
    return ToFloatDef(val, 0);
}

double ToDouble(id val)
{
    if (!val)
        return 0;
    
    return [val doubleValue];
}

NSInteger ToInt(id val)
{
    return ToIntDef(val, 0);
}

BOOL ToBool(id val)
{
    return ToBoolDef(val, NO);
}

NSDate* ToDate(id val)
{
    return ToDateDef(val, [NSDate dateWithTimeIntervalSince1970:0]);
}

BOOL IsArray(id val)
{
    return [val isKindOfClass:[NSArray class]];
}

NSString* ToJSON(id obj)
{
    NSData *data = nil;
    
    if (!obj) {
        return @"";
    }
    
    @try {
        data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
    }
    @catch (NSException *exception) {
    }
    
    if (!data) {
        return @"";
    }
    
    return [[NSString alloc] initWithBytes:data.bytes
                                    length:data.length
                                  encoding:NSUTF8StringEncoding];
}


id FromJSON(NSString *json)
{
    NSData *d = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    return [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
}

NSArray* AssureIsArray(id obj)
{
    if ([obj isKindOfClass:[NSArray class]]) {
        return obj;
    }
    
    return @[];
}

NSArray* AssureIsStringArray(id obj)
{
    if (![obj isKindOfClass:[NSArray class]]) {
        return @[];
    }
    
    NSMutableArray *filtered = [NSMutableArray array];
    
    for (NSString *str in obj) {
        if ([str isKindOfClass:[NSString class]]) {
            [filtered addObject:str];
        }
    }
    
    return filtered;
}

NSDictionary* AssureIsDict(id obj)
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return obj;
    }
    
    return @{};
}

NSArray* ArrayFromJSON(NSString *json)
{
    return AssureIsArray(FromJSON(json));
}

NSDate *FromServerDate(NSString *serverDate)
{
    serverDate = ToString(serverDate);
    
    static NSDateFormatter *dateFormatter = nil;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:enUSPOSIXLocale];
//        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm a"];
    });

    NSDate *dt = [dateFormatter dateFromString:serverDate];
    
    return dt ? dt : [NSDate dateWithTimeIntervalSince1970:0];
}

NSString *ToServerDate(NSDate *date)
{
    static NSDateFormatter *dateFormatter = nil;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    
    if (!date) {
        return @"";
    }
    
    return [dateFormatter stringFromDate:date];
}

//------------------------------------------
@implementation NSObject (Api)

- (float)floatValue
{
    return 0;
}

- (double)doubleValue
{
    return 0;
}

-(int)intValue
{
    return 0;
}

-(BOOL)boolValue
{
    return FALSE;
}

-(NSDate*)dateValue
{
    return [NSDate dateWithTimeIntervalSince1970:[self intValue]];
}

-(NSString*)stringValue
{
    return @"";
}

-(BOOL)isArray
{
    return [self isKindOfClass:[NSArray class]];
}

-(BOOL)isDict
{
    return [self isKindOfClass:[NSDictionary class]];
}

@end
