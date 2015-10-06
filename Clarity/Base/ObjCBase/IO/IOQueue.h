//
//  IORequestsQueue.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/13/14.
//
//

#import <Foundation/Foundation.h>
#import "IOQueueItem.h"

@interface IOQueue : NSObject

- (void)addObject:(id<IOQueueItem>)object;
- (void)removeObject:(id)object;
- (BOOL)containsObject:(id)object;
- (id)getNextObject;
- (void)reorderWithIds:(NSArray *)ids;

@end
