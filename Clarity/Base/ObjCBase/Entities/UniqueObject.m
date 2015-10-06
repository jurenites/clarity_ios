//
//  UniqueObject.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 6/4/14.
//
//

#import "UniqueObject.h"

@implementation UniqueObject

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
        return ([object isKindOfClass:[self class]]
                && [self.uniqueId isEqual:((UniqueObject *)object).uniqueId]);
    }
    
    return [super isEqual:object];
}

@end
