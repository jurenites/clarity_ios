//
//  NSDictionary+DB.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/9/14.
//
//

#import "NSDictionary+DB.h"

@implementation NSDictionary (DB)

-(NSMutableDictionary*)add:(NSDictionary*)dict
{
    NSMutableDictionary *mutable_copy = self.mutableCopy;

    [mutable_copy addEntriesFromDictionary:dict];
    return mutable_copy;
}

@end
