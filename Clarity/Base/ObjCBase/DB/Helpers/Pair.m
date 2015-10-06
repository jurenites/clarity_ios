//
//  Pair.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/5/13.
//
//

#import "Pair.h"

@implementation Pair

+(Pair*)pairWithName:(NSString*)name value:(id)value
{
    Pair *p = [Pair new];
    
    p.name = name;
    p.value = value;
    
    return p;
}

@end
