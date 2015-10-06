//
//  NonTypedUniqueObject.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 12/4/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "NonTypedUniqueObject.h"

@implementation NonTypedUniqueObject

- (id)uniqueId
{
    return nil;
}

- (NSUInteger)hash
{
    return self.uniqueId ? [self.uniqueId hash] : [super hash];
}

- (BOOL)isEqual:(id)object
{
    if (self.uniqueId) {
        return ([object isKindOfClass:[NonTypedUniqueObject class]]
                && [self.uniqueId isEqual:((NonTypedUniqueObject *)object).uniqueId]);
    }
    
    return [super isEqual:object];
}

@end
