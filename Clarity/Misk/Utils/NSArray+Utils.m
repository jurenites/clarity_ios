//
//  NSArray+Utils.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/28/14.
//
//

#import "NSArray+Utils.h"

@implementation NSArray (Utils)

- (BOOL)containsObjects:(NSArray *)objects
{
    for (id object in objects) {
        if (![self containsObject:object]) {
            return NO;
        }
    }
    
    return YES;
}

@end
