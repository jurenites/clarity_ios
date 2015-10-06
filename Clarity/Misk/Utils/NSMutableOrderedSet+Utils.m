//
//  NSMutableOrderedSet+Utils.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 4/12/14.
//
//

#import "NSMutableOrderedSet+Utils.h"

@implementation NSMutableOrderedSet (Utils)

- (void)replaceObject:(id)object
{
    [self replaceObject:object withObject:object];
}

- (void)replaceObject:(id)object withObject:(id)otherObject
{
    NSUInteger index = [self indexOfObject:object];
    
    if (index == NSNotFound) {
        return;
    }
    
    [self replaceObjectAtIndex:index withObject:otherObject];
}

@end
