//
//  WeakWrapper.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 12/2/13.
//
//

#import "WeakWrapper.h"

@implementation WeakWrapper

-(id)initWithObj:(id)object
{
    self = [super init];
    if (!self)
        return nil;
    
    self.object = object;
    
    return self;
}

@end
