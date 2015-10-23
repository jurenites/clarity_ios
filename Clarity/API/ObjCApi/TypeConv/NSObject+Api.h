//
//  NSObject+Api.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/8/13.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (Api)

-(float)floatValue;
-(double)doubleValue;
-(int)intValue;
-(BOOL)boolValue;
-(NSDate*)dateValue;
-(NSString*)stringValue;

-(BOOL)isArray;
-(BOOL)isDict;

@end

NSString* ToStringDef(id val, NSString *def_val);
float ToFloatDef(id val, float def_val);
NSInteger ToIntDef(id val, NSInteger def_val);
BOOL ToBoolDef(id val, BOOL def_val);
NSDate* ToDateDef(id val, NSDate *def_val);

NSString* ToString(id val);
float ToFloat(id val);
double ToDouble(id val);
NSInteger ToInt(id val);
BOOL ToBool(id val);
NSDate* ToDate(id val);

BOOL IsArray(id val);

NSString* ToJSON(id obj);
id FromJSON(NSString *json);

NSArray* ArrayFromJSON(NSString *json);

NSArray* AssureIsArray(id obj);
NSArray* AssureIsStringArray(id obj);
NSDictionary* AssureIsDict(id obj);

NSDate *FromServerDate(NSString *serverDate);
NSDate *FromServerDateTime(NSString *serverDateTime);
NSString *ToServerDate(NSDate *date);
NSString *ToServerDateTime(NSDate *date);

