//
//  FMResultSet+DB.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/5/13.
//
//

#import "FMResultSet+DB.h"
#import "NSObject+Api.h"

@implementation FMResultSet (DB)

- (NSString *)stringCol:(NSString *)colName
{
    if ([self columnIndexForName:colName] < 0) {
        return @"";
    }

    return [self stringForColumn:colName];
}

- (int)intCol:(NSString *)colName
{
    if ([self columnIndexForName:colName] < 0) {
        return 0;
    }
    
    return [self intForColumn:colName];
}

- (BOOL)boolCol:(NSString *)colName
{
    if ([self columnIndexForName:colName] < 0) {
        return NO;
    }
    
    return [self boolForColumn:colName];
}

- (float)floatCol:(NSString *)colName
{
    if ([self columnIndexForName:colName] < 0) {
        return 0.0;
    }
    
    return [self doubleForColumn:colName];
}

- (NSDate *)dateCol:(NSString *)colName
{
    if ([self columnIndexForName:colName] < 0) {
        return [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    return [NSDate dateWithTimeIntervalSince1970:[self intCol:colName]];
}

- (BOOL)isNull:(NSString *)columnName
{
    return [self columnIsNull:columnName];
}

@end
