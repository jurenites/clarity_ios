//
//  IORequest.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/7/13.
//
//

#import <Foundation/Foundation.h>
#import "IOOperation.h"
#import "IOQueueItem.h"
#import "UniqueNumber.h"

@class IORequest;

typedef void(^OnIOSuccess)(id result);
typedef void(^OnIOError)(NSError *error);
typedef void(^BeforeIORestart)(IORequest *req);

@interface IORequest : NonTypedUniqueObject <IOQueueItem>

- (instancetype)init;
- (instancetype)initWithId:(UniqueNumber *)requestId;
- (IOOperation *)makeOperationWithDelegate:(id<IOOperationDelegate>)delegate;

- (BOOL)restart;

@property (readonly, nonatomic) UniqueNumber *requestId;
@property (assign, nonatomic) BOOL highPrio;
@property (strong, nonatomic) NSArray *pipeline;
@property (copy, nonatomic) OnIOSuccess onSuccess;
@property (copy, nonatomic) OnIOError onError;
@property (copy, nonatomic) BeforeIORestart beforeRestart;

@end
