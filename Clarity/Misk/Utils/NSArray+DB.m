//
//  NSArray+DB.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/8/14.
//
//

#import "NSArray+DB.h"

@implementation NSArray (DB)

-(NSString*)join
{
    return [self componentsJoinedByString:@""];
}

-(NSString*)joinBy:(NSString*)str
{
    return [self componentsJoinedByString:str];
}

-(NSMutableArray*)append:(NSArray*)array
{
    NSMutableArray *mutable_copy = [self mutableCopy];

    if (array)
        [mutable_copy addObjectsFromArray:array];
    
    return mutable_copy;
}

@end
