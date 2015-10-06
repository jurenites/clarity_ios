//
//  IORequestsQueue.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/13/14.
//
//

#import "IOQueue.h"

@interface IOQueue ()
{
    NSMutableOrderedSet *_highPrioQueue;
    NSMutableOrderedSet *_queue;
    NSMutableOrderedSet *_lowPrioQueue;
}
@end

@implementation IOQueue

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _highPrioQueue = [NSMutableOrderedSet orderedSet];
    _queue = [NSMutableOrderedSet orderedSet];
    _lowPrioQueue = [NSMutableOrderedSet orderedSet];
    
    return self;
}

- (void)addObject:(id<IOQueueItem>)object
{
    if ([object highPrio]) {
        [_highPrioQueue addObject:object];
    } else {
        [_lowPrioQueue addObject:object];
    }
}

- (BOOL)containsObject:(id)object
{
    return [_lowPrioQueue containsObject:object]
        || [_queue containsObject:object]
        || [_highPrioQueue containsObject:object];
}

- (void)removeObject:(id)object
{
    [_highPrioQueue removeObject:object];
    [_queue removeObject:object];
    [_lowPrioQueue removeObject:object];
}

- (void)reorderWithIds:(NSArray *)ids
{
    NSMutableOrderedSet *reordered = [NSMutableOrderedSet orderedSetWithCapacity:ids.count];
    
    for (id reqId in ids) {
        NSUInteger index = [_lowPrioQueue indexOfObject:reqId];
        
        if (index != NSNotFound) {
            [reordered addObject:_lowPrioQueue[index]];
            [_lowPrioQueue removeObjectAtIndex:index];
            continue;
        }
        
        index = [_queue indexOfObject:reqId];
        
        if (index != NSNotFound) {
            [reordered addObject:_queue[index]];
            [_queue removeObjectAtIndex:index];
        }
    }
    
    [_lowPrioQueue addObjectsFromArray:[_queue array]];
    _queue = reordered;
}

- (id)getNextObject
{
    if (_highPrioQueue.count) {
        id object = _highPrioQueue[0];
        [_highPrioQueue removeObjectAtIndex:0];
        return object;
    } else if (_queue.count) {
        id object = _queue[0];
        [_queue removeObjectAtIndex:0];
        return object;
    } else if (_lowPrioQueue.count) {
        id object = _lowPrioQueue[0];
        [_lowPrioQueue removeObjectAtIndex:0];
        return object;
    }
    
    return nil;
}


@end
