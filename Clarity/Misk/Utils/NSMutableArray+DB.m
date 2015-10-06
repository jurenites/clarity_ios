//
//  NSMutableArray+DB.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/9/14.
//
//

#import "NSMutableArray+DB.h"

@implementation NSMutableArray (DB)

-(NSMutableArray*)append:(NSArray*)array
{
    if (array)
        [self addObjectsFromArray:array];
    
    return self;
}

@end
