//
//  NSMutableDictionary+DB.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/9/14.
//
//

#import "NSMutableDictionary+DB.h"

@implementation NSMutableDictionary (DB)

-(NSMutableDictionary*)add:(NSDictionary*)dict
{
    [self addEntriesFromDictionary:dict];
    return self;
}

@end
