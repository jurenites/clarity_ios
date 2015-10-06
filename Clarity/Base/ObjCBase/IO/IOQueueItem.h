//
//  IORequestsQueueItem.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/13/14.
//
//

#import <Foundation/Foundation.h>

@protocol IOQueueItem <NSObject>

- (BOOL)highPrio;

@end
