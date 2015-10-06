//
//  IOManager.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/7/13.
//
//

#import "IOManager.h"

#import <SystemConfiguration/SystemConfiguration.h>

#import "IOHTTPRequest.h"
#import "IOHTTPOperation.h"
#import "PipelineItem.h"
#import "NetReachability.h"
#import "InternalError.h"
#import "DelegatesHolder.h"
#import "IORequest_Private.h"
#import "IOQueue.h"
#import "UniqueNumber.h"

@interface IOManager () <IOOperationDelegate, NetReachabilityDelegate, IOManagerInThread>
{
//-------syncronized-------------
    IOQueue *_pendingRequests;
    NSMutableSet *_requestsForCancel;
    NSMutableSet *_requestsInProcessing;
    DelegatesHolder *_delegates;
    uint64_t _nextRequestId;
//-------------------------------

    BOOL _running;
    NSCondition *_startCond;
    
//--------------------------------
    NSTimer *_idleTimer;
    size_t _maxSimulReqs;
    
    IOQueue *_operationsQueue;
    NSMutableSet *_activeOperations;
    
    //----------------------------------------
    NSMutableDictionary *_diskCaches;
    
    NetReachability *_reachabilityMonitor;
}

- (void)idle;
- (void)checkInputQueue;
- (void)checkRequestQueue;
- (void)performBlockImpl:(void (^)())block;

- (void)callRequestPipeline:(IOOperation *)operation withResult:(id)result httpCode:(NSInteger)httpCode;
- (void)setReachability:(IONetReachability)reach;

- (NSSet *)getDelegates;
- (BOOL)checkForCancel:(UniqueNumber *)reqId;
- (BOOL)checkForCancelAtExit:(UniqueNumber *)reqId;

@end


@implementation IOManager

- (instancetype)initWithMaxSimulReqs:(size_t)maxReqs
{
    self = [super init];
    if (!self)
        return nil;
    
    _pendingRequests = [IOQueue new];
    _requestsForCancel = [NSMutableSet set];
    _requestsInProcessing = [NSMutableSet set];
    
    _operationsQueue = [IOQueue new];
    _activeOperations = [NSMutableSet set];
    
    _diskCaches = [NSMutableDictionary dictionary];
    
    _delegates = [DelegatesHolder new];
    _nextRequestId = 1;
    _maxSimulReqs = maxReqs;
    
    _startCond = [NSCondition new];
    
    return self;
}

- (void)start
{
    [super start];
    
    [_startCond lock];
    
    while (!_running) {
        [_startCond wait];
    }
    
    [_startCond unlock];
}

- (void)main
{
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    _idleTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                  target:self
                                                selector:@selector(idle)
                                                userInfo:nil
                                                 repeats:TRUE];
    
    _reachabilityMonitor = [[NetReachability alloc] initWithHostname:@"www.google.com"
                                                             runLoop:runLoop
                                                            delegate:self];
    
    [self setReachability:_reachabilityMonitor.status];
    
    [_startCond lock];
    _running = TRUE;
    [_startCond signal];
    [_startCond unlock];
    
    while (_running) {
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

- (void)idle
{
}

- (void)doStop
{
    _running = FALSE;
    [_idleTimer invalidate];
}

- (void)stop
{
    [self performSelector:@selector(doStop) onThread:self withObject:nil waitUntilDone:TRUE];
}

- (void)performBlockImpl:(void (^)())block
{
    block();
}

- (void)performBlock:(void(^)())block
{
    if (!block)
        return;

    [self performSelector:@selector(performBlockImpl:)
                 onThread:self
               withObject:[block copy]
            waitUntilDone:FALSE];
}

- (void)execAsyncImpl:(void (^)(id<IOManagerInThread>))block
{
    block(self);
}

- (void)execAsync:(void(^)(id<IOManagerInThread> iom))block
{
    if (!block) {
        return;
    }

    [self performSelector:@selector(execAsyncImpl:)
                 onThread:self
               withObject:[block copy]
            waitUntilDone:NO];
}

- (void)exec:(void(^)(id<IOManagerInThread> iom))block
{
    if (!block) {
        return;
    }

    [self performSelector:@selector(execAsyncImpl:)
                 onThread:self
               withObject:[block copy]
            waitUntilDone:YES];
}

- (void)setReachability:(IONetReachability)reach
{
    @synchronized(self){
        _reachability = reach;
    }
}

- (BOOL)inOnline
{
    IONetReachability reach = self.reachability;

    return reach == IONetReachabilityCellular || reach == IONetReachabilityWifi;
}

- (void)addDiskCache:(FileCache *)diskCache withName:(NSString *)name
{
    [self exec:^(id<IOManagerInThread> iom) {
        [_diskCaches setObject:diskCache forKey:name];
        [diskCache reload];
    }];
}

- (void)clearAllCaches
{
    [self exec:^(id<IOManagerInThread> iom) {
        for (FileCache *dk in _diskCaches.allValues) {
            [dk deleteAllFiles];
        }
    }];
}

- (FileCache *)diskCacheByName:(NSString *)name
{
    return _diskCaches[name];
}

#pragma mark - NetReachabilityDelegate
- (void)netReachabilityChanged:(NetReachability *)nr status:(IONetReachability)status
{
    IONetReachability prevStatus = self.reachability;

    if (prevStatus == status) {
        return;
    }
    
    [self setReachability:status];
    
    const BOOL wasOnline = [NetReachability statusToInOnline:prevStatus];
    const BOOL becomeOnline = [NetReachability statusToInOnline:status];
    
    if (wasOnline == becomeOnline)
        return;
    
    NSSet *delegates = [self getDelegates];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id<IOManagerDelegate> d in delegates) {
            if (becomeOnline) {
                if ([d respondsToSelector:@selector(ioManagerGoToOnline:reach:)]) {
                    [d ioManagerGoToOnline:self reach:status];
                }
            } else {
                if ([d respondsToSelector:@selector(ioManagerGoToOffline:reach:)]) {
                    [d ioManagerGoToOffline:self reach:status];
                }
            }
            
        }
    });
}

#pragma mark - queue work
- (void)checkInputQueue
{
    IORequest *reqForStart = nil;
    
    @synchronized(self) {
        for (UniqueNumber *reqId in [_requestsForCancel allObjects]) {
            if ([_operationsQueue containsObject:reqId]) {
                [_operationsQueue removeObject:reqId];
                [_requestsInProcessing removeObject:reqId];
                [_requestsForCancel removeObject:reqId];
            }
        }
        
        // Cancel active network operations
        NSSet *activeOps = [_activeOperations copy];
        
        for (IOOperation *op in activeOps) {
            UniqueNumber *key = op.request.requestId;
        
            if ([_requestsForCancel containsObject:key]) {
                [op cancel];
                [_activeOperations removeObject:op];
                [_requestsForCancel removeObject:key];
                [_requestsInProcessing removeObject:key];
                
                [self checkRequestQueue];
            }
        }
        
        reqForStart = [_pendingRequests getNextObject];
        
        if (reqForStart) {
            [_requestsInProcessing addObject:reqForStart.requestId];
        }
        
    }
    
    if (reqForStart) {
        [[reqForStart makeOperationWithDelegate:self] perform];
        [self performSelector:@selector(checkInputQueue) withObject:nil afterDelay:0];
    }
}

- (void)checkRequestQueue
{
    NSInteger extractCount = (NSInteger)_maxSimulReqs - (NSInteger)_activeOperations.count;
    
    for (NSInteger i = 0; i < extractCount; i++) {
        IOOperation *op = [_operationsQueue getNextObject];
        
        if (!op) {
            break;
        }
        
        [op startNetworkOperation];
        [_activeOperations addObject:op];
    }
}

- (void)callRequestPipeline:(IOOperation *)operation withResult:(id)result httpCode:(NSInteger)httpCode
{
    PipelineItem *head = operation.request.pipeline.firstObject;
    
    NSArray *tail =
        [operation.request.pipeline
            subarrayWithRange:NSMakeRange(1, operation.request.pipeline.count - 1)];
    
    PipelineContext *ctx =
        [[PipelineContext alloc]
            initWithOnSuccess:^(id result) {
                dispatch_async(
                    dispatch_get_main_queue(), ^{
                        if ([self checkForCancelAtExit:operation.request.requestId]) {
                            return;
                        }
                        
                        if (operation.request.onSuccess) {
                            operation.request.onSuccess(result);
                        }
                     }
                );
            }
            onError:^(NSError *error) {
                dispatch_async(
                    dispatch_get_main_queue(), ^{
                        if ([self checkForCancelAtExit:operation.request.requestId])
                            return;
                        
                        if (operation.request.onError) {
                            operation.request.onError(error);
                        }
                     }
                );
            }
            callOnPPLThread:^(void(^fn)()) {
                [self performBlock:fn];
            }
            restartRequest:^(NSError *error){
                dispatch_async(
                    dispatch_get_main_queue(), ^{
                        IORequest *req = operation.request;
                    
                        if ([self checkForCancelAtExit:req.requestId]) {
                            return;
                        }
                        
                        if ([req restart]) {
                            [self enqueueRequest:req];
                        } else if (operation.request.onError) {
                            operation.request.onError(error);
                        }
                     }
                );
            }
        ];
    
    ctx.httpCode = httpCode;
    [head call:result pipelineTail:tail ctx:ctx];
}

- (void)operationSucceeded:(IOOperation *)operation withResult:(id)result httpCode:(NSInteger)httpCode
{
    [_activeOperations removeObject:operation];
    [self checkRequestQueue];
    
    if ([self checkForCancel:operation.request.requestId]) {
        return;
    }
    
    if (operation.request.pipeline.count) {
        [self callRequestPipeline:operation withResult:result httpCode:httpCode];
    } else {
        dispatch_async(
           dispatch_get_main_queue(), ^{
               if ([self checkForCancelAtExit:operation.request.requestId]) {
                   return;
               }
               
               if (operation.request.onSuccess) {
                   operation.request.onSuccess(result);
               }
           }
        );
    }
}


#pragma mark - IOOperationDelegate
- (void)ioOperationSucceeded:(IOOperation *)operation withData:(NSData *)data httpCode:(NSInteger)httpCode
{
    [self operationSucceeded:operation withResult:data httpCode:httpCode];
}

- (void)ioOperationSucceeded:(IOOperation *)operation withFilePath:(NSString *)filePath httpCode:(NSInteger)httpCode
{
    [self operationSucceeded:operation withResult:filePath httpCode:httpCode];
}

- (void)ioOperationFailed:(IOOperation *)operation withError:(NSError *)error
{
    [_activeOperations removeObject:operation];
    [self checkRequestQueue];
    
    dispatch_async(
        dispatch_get_main_queue(), ^{
            if ([self checkForCancelAtExit:operation.request.requestId]) {
                return;
            }
            
            if (operation.request.onError) {
                operation.request.onError(error);
            }
         }
    );
}

- (void)ioOperationNeedNetwork:(IOOperation *)operation
{
    [_operationsQueue addObject:operation];
    [self checkRequestQueue];
}

- (FileCache *)ioOperation:(IOOperation *)operation cacheForName:(NSString *)name
{
    return _diskCaches[name];
}

- (BOOL)ioOperationInOnline
{
    return self.inOnline;
}

#pragma mark - Synchronized methods

- (UniqueNumber *)enqueueRequest:(IORequest *)request
{
    @synchronized(self) {
        [request setRequestId:[[UniqueNumber alloc] initWithNumber:@(_nextRequestId++)]];
        
        if ([_pendingRequests containsObject:request]
            || [_requestsInProcessing containsObject:request.requestId]) {
            NSAssert(FALSE, @"Panic in -(IORequestId*)enqueueRequest:(IORequest*)request");
            return request.requestId;
        }
    
        [_pendingRequests addObject:request];
    }
    
    [self performSelector:@selector(checkInputQueue) onThread:self withObject:nil waitUntilDone:NO];
    return request.requestId;
}

- (void)reorderRequests:(NSArray *)newRequestsOrder
{
    @synchronized(self) {        
        [_pendingRequests reorderWithIds:newRequestsOrder];
    }
    
    [self execAsync:^(id<IOManagerInThread> iom) {
        [_operationsQueue reorderWithIds:newRequestsOrder];
    }];
}

- (void)cancelRequest:(UniqueNumber *)reqId
{
    if (reqId) {
        [self cancelRequests:@[reqId]];
    }
}

- (void)cancelRequests:(NSArray *)reqIds
{
    @synchronized(self) {
        for (UniqueNumber *reqId in reqIds) {
            if ([_pendingRequests containsObject:reqId]) {
                [_pendingRequests removeObject:reqId];
            } else if ([_requestsInProcessing containsObject:reqId]) {
                [_requestsForCancel addObject:reqId];
            }
        }
    }
    
    [self performSelector:@selector(checkInputQueue) onThread:self withObject:nil waitUntilDone:NO];
}

- (void)addDelegate:(id<IOManagerDelegate>)delegate
{
    @synchronized(self) {
        [_delegates addDelegate:delegate];
    }
}

- (void)removeDelegate:(id<IOManagerDelegate>)delegate
{
    @synchronized(self) {
        [_delegates removeDelegate:delegate];
    }
}

- (NSSet *)getDelegates
{
    NSSet *delegates = nil;

    @synchronized(self) {
        delegates = [_delegates getDelegates];
    }
    
    return delegates;
}

- (BOOL)checkForCancel:(UniqueNumber *)reqId
{
    @synchronized(self) {
        BOOL canceled = [_requestsForCancel containsObject:reqId];
        
        if (canceled) {
            [_requestsForCancel removeObject:reqId];
            [_requestsInProcessing removeObject:reqId];
        }
        
        return canceled;
    }
}

- (BOOL)checkForCancelAtExit:(UniqueNumber *)reqId
{
    @synchronized(self) {
        BOOL canceled = [_requestsForCancel containsObject:reqId];
        
        if (canceled) {
            [_requestsForCancel removeObject:reqId];
        }
            
        [_requestsInProcessing removeObject:reqId];
        
        return canceled;
    }
}

@end
