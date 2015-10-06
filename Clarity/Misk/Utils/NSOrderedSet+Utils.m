//
//  NSOrderedSet+Utils.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/27/14.
//
//

#import "NSOrderedSet+Utils.h"

@implementation NSOrderedSet (Utils)

- (id)objectByObject:(id)object
{
    NSUInteger index = [self indexOfObject:object];
    
    if (index != NSNotFound) {
        return self[index];
    }
    
    return nil;
}

@end
