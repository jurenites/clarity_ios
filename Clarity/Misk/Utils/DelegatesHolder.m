//
//  DelegatesHolder.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/14/14.
//
//

#import "DelegatesHolder.h"
#import "WeakWrapper.h"

@interface DelegatesHolder ()
{
    NSMutableDictionary *_delegates;
}
@end

@implementation DelegatesHolder

-(instancetype)init
{
    self = [super init];
    if (!self)
        return nil;
    
    _delegates = [NSMutableDictionary dictionary];
    
    return self;
}

-(void)addDelegate:(id)delegate
{
    _delegates[[NSValue valueWithNonretainedObject:delegate]] = [[WeakWrapper alloc] initWithObj:delegate];
}

-(void)removeDelegate:(id)delegate
{
    [_delegates removeObjectForKey:[NSValue valueWithNonretainedObject:delegate]];
}

-(void)removeAllDelegates
{
    [_delegates removeAllObjects];
}

-(NSSet*)getDelegates
{
    NSMutableSet *delegates = [NSMutableSet set];
    
    for (id key in _delegates.allKeys) {
        if ([_delegates[key] object]) {
            [delegates addObject:[_delegates[key] object]];
        }
    }
    
    return delegates;
}

@end
