//
//  ApiManager.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/11/13.
//
//

#import "ApiManager.h"
#import "IOManager.h"
#import "IOCachedHTTPOperation.h"
#import "ApiCanceler.h"
#import "ApiCancelerFlag.h"
#import "ApiRouter.h"
#import "NetworkError.h"
#import "PLIParseApiResponse.h"
#import "PLIParseJSONRPC.h"
#import "Entity.h"
#import "ApiMethod.h"

static NSString * const ServerURLKey = @"ServerUrl";

static NSInteger RequestSequenceId = 0;

@interface ApiManager ()
{
    NSString *_serverUrl;
    
    IOManager *_apiIO;
    IOManager *_mediaIO;
    DBManager *_db;
    
    NSMutableDictionary *_pendingReqIds;
    NSMutableSet *_pendingDbReqIds;
}

- (void)addIOReqToPending:(UniqueNumber *)reqId withIoManager:(IOManager *)ioManager;
- (void)removeIOReqFromPending:(UniqueNumber *)reqId withIoManager:(IOManager *)ioManager;
- (void)cancelPendingsWithIoManager:(IOManager *)ioManager;

- (void)addDBReqToPending:(UniqueNumber *)reqId;
- (void)removeDBReqFromPending:(UniqueNumber *)reqId;

- (ApiCanceler *)enqueueRequest:(IORequest *)req
                  withIoManager:(IOManager *)ioManager
                      onSuccess:(OnIOSuccess)onSuccess
                        onError:(OnIOError)onError;

@end

@implementation ApiManager

@synthesize db = _db;

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;
    
    _serverUrl = [[[NSBundle mainBundle] infoDictionary] objectForKey:ServerURLKey];
    
    _apiRouter = [ApiRouter shared];
    
    _apiIO = [ApiRouter shared].apiIO;
    _mediaIO = [ApiRouter shared].mediaIO;
    _db = [ApiRouter shared].db;
    
    _pendingReqIds = [NSMutableDictionary dictionary];
    _pendingDbReqIds = [NSMutableSet set];
    
    return self;
}

- (void)dealloc
{
    [self cancelAllRequests];
}

- (void)cancelAllRequests
{
    [self cancelPendingsWithIoManager:_apiIO];
    [self cancelPendingsWithIoManager:_mediaIO];
    [_db cancelRequests:_pendingDbReqIds];
}

#pragma IO Requests

- (void)addIOReqToPending:(UniqueNumber *)reqId withIoManager:(IOManager *)ioManager
{
    NSMutableSet *iomSet =
        [_pendingReqIds objectForKey:
            [NSValue valueWithPointer:(__bridge void*)ioManager]];
    
    if (!iomSet) {
        iomSet = [NSMutableSet set];
        
        [_pendingReqIds
            setObject:iomSet
            forKey:[NSValue valueWithPointer:(__bridge void*)ioManager]];
    }
    
    [iomSet addObject:reqId];
}

- (void)removeIOReqFromPending:(UniqueNumber *)reqId withIoManager:(IOManager *)ioManager
{
    NSMutableSet *iomSet =
        [_pendingReqIds objectForKey:
            [NSValue valueWithPointer:(__bridge void *)ioManager]];
    
    if (!iomSet)
        return;

    [iomSet removeObject:reqId];
}

- (void)cancelPendingsWithIoManager:(IOManager *)ioManager
{
    NSMutableSet *iomSet =
        [_pendingReqIds objectForKey:
            [NSValue valueWithPointer:(__bridge void*)ioManager]];
    
    if (!iomSet)
        return;
    
    [ioManager cancelRequests:[iomSet allObjects]];
}

-(IOManager*)ioManagerByPtr:(const void*)ioManager
{
    if (ioManager == (__bridge const void*)_apiIO)
        return _apiIO;
    else if (ioManager == (__bridge const void*)_mediaIO)
        return _mediaIO;
    return nil;
}

-(void)cancelReqId:(UniqueNumber *)reqId ioManager:(const void*)ioManager
{
    IOManager *iom = [self ioManagerByPtr:ioManager];
    
    if (!iom)
        return;
    
    NSMutableSet *iom_set =
        [_pendingReqIds objectForKey:
            [NSValue valueWithPointer:(__bridge void*)iom]];
    
    if (!iom_set)
        return;

    [iom_set removeObject:reqId];
    [iom cancelRequest:reqId];
}


#pragma mark DB Requests

- (void)addDBReqToPending:(NSNumber *)reqId
{
    [_pendingDbReqIds addObject:reqId];
}

- (void)removeDBReqFromPending:(NSNumber *)reqId
{
    [_pendingDbReqIds removeObject:reqId];
}

- (void)cancelReqId:(UniqueNumber *)reqId dbManager:(const void *)dbManager
{
    if (dbManager == (__bridge const void *)_db) {
        [_db cancelRequest:reqId];
    }
}


#pragma mark -------

- (IOHTTPRequest *)requestWithMethod:(ApiMethodID)methodID
{
    IOHTTPRequest *req = [IOHTTPRequest new];
    
    [self.apiRouter prepareHttpRequest:req withMethodID:methodID];
    return req;
}

- (IOHTTPRequest *)requestWithMethod:(ApiMethodID)methodID
                                andUrlParams:(NSDictionary *)urlParams
{
    IOHTTPRequest *req = [IOHTTPRequest new];
    
    [self.apiRouter prepareHttpRequest:req withMethodID:methodID andUrlParams:urlParams];
    return req;
}

- (IOCachedHTTPRequest *)cachedRequestWithMethod:(ApiMethodID)methodID
{
    IOCachedHTTPRequest *req = [IOCachedHTTPRequest new];
    
    [self.apiRouter prepareHttpRequest:req withMethodID:methodID];
    return req;
}

- (IOCachedHTTPRequest *)cachedRequestWithMethod:(ApiMethodID)methodID
                                andUrlParams:(NSDictionary *)urlParams
{
    IOCachedHTTPRequest *req = [IOCachedHTTPRequest new];
    
    [self.apiRouter prepareHttpRequest:req withMethodID:methodID andUrlParams:urlParams];
    return req;
}

- (ApiCanceler *)enqueueHttpRequest:(IOHTTPRequest *)req
                      withIoManager:(IOManager *)iom
                          onSuccess:(OnIOSuccess)onSuccess
                            onError:(OnIOError)onError
{
    if (req.url.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (onError) {
                onError([InternalError errorWithDescr:@"No URL specified"]);
            }
        });
        
        return [ApiCanceler new];
    }
    
    return [self enqueueRequest:req withIoManager:iom onSuccess:onSuccess onError:onError];
}

-(ApiCanceler*)enqueueHttpRequest:(IOHTTPRequest*)req
                        onSuccess:(OnIOSuccess)onSuccess
                          onError:(OnIOError)onError
{
 
    return [self enqueueHttpRequest:req withIoManager:_apiIO onSuccess:onSuccess onError:onError];
}

- (ApiCanceler *)enqueueApiRequest:(IOHTTPRequest* )req
                         onSuccess:(OnIOSuccess)onSuccess
                           onError:(OnIOError)onError
{
    return [self enqueueApiRequest:req
                          pipeline:@[]
                         onSuccess:onSuccess
                           onError:onError];
}

- (ApiCanceler *)enqueueApiRequest:(IOHTTPRequest *)req
                          pipeline:(NSArray *)pipeline
                         onSuccess:(OnIOSuccess)onSuccess
                           onError:(OnIOError)onError;
{
    req.pipeline = [[@[[PLIParseJSONRPC new]] append:req.pipeline] append:pipeline]; //PLIParseApiResponse
    
    return [self enqueueHttpRequest:req withIoManager:_apiIO onSuccess:onSuccess onError:onError];
}

#pragma mark -- Base methods

//- (ApiCanceler *)callMethodWithId:(ApiMethodID)methodId
//                           params:(NSDictionary *)params
//                         pipeline:(NSArray *)pipeline
//                        onSuccess:(OnIOSuccess)onSuccess
//                          onError:(OnIOError)onError
//{
//    return [self callMethodWithId:methodId
//                         apiToken:[ApiRouter shared].apiToken
//                           params:params
//                         pipeline:pipeline
//                        onSuccess:onSuccess
//                          onError:onError];
//}

//- (ApiCanceler *)callMethodWithId:(ApiMethodID)methodId
//                         apiToken:(NSString *)apiToken
//                           params:(NSDictionary *)params
//                         pipeline:(NSArray *)pipeline
//                        onSuccess:(OnIOSuccess)onSuccess
//                          onError:(OnIOError)onError
//{
//    IOHTTPRequest *req = [IOHTTPRequest new];
//    
//    if (apiToken.length > 0) {
//#warning TODO : Walid token key/value here
//        [req addHeaders:@{kTokenName : apiToken}];
//    }
//    
//    ApiMethod *method = _methods[@(methodID)];
//    
//    if (method.httpMethod == HttpMethodGet) {
//        req.url = [NSString stringWithFormat:@"%@%@", _serverUrl, [method buildUrlWithParams:params]];
//    } else if (method.httpMethod == HttpMethodPost) {
//        req.url = [NSString stringWithFormat:@"%@%@", _serverUrl, [method buildUrlWithParams:nil]];
//        [req addParams:params];
//    }
//    
//    return [self enqueueApiRequest:req pipeline:pipeline onSuccess:onSuccess onError:onError];
//}

- (ApiCanceler *)callMethodWithName:(NSString *)name
                             params:(NSDictionary *)params
                           pipeline:(NSArray *)pipeline
                          onSuccess:(OnIOSuccess)onSuccess
                            onError:(OnIOError)onError
{
    return [self callMethodWithName:name params:params apiToken:[ApiRouter shared].apiToken
                           pipeline:pipeline onSuccess:onSuccess onError:onError];
}

- (ApiCanceler *)callMethodWithName:(NSString *)name
                             params:(NSDictionary *)params
                           apiToken:(NSString *)apiToken
                           pipeline:(NSArray *)pipeline
                          onSuccess:(OnIOSuccess)onSuccess
                            onError:(OnIOError)onError
{
    IOHTTPRequest *req = [IOHTTPRequest new];
    
    req.method = HttpMethodPost;
    req.bodyEncoding = HttpBodyJSON;
    req.url = _serverUrl;
    
    NSMutableDictionary *sendParams = [NSMutableDictionary dictionaryWithDictionary:params];
    
    if (apiToken) {
        sendParams[@"token"] = apiToken;
    }
    
    [req addParams:@{
                     @"id" : ToString(@(++RequestSequenceId)),
                     @"jsonrpc" : @"2.0",
                     @"method": name,
                     @"params" : sendParams}];
    
    req.pipeline = [[@[[PLIParseJSONRPC new]] append:req.pipeline] append:pipeline];
    
    return [self enqueueHttpRequest:req withIoManager:_apiIO onSuccess:onSuccess onError:onError];
}

- (ApiCanceler *)enqueueMediaHttpRequest:(IOHTTPRequest*)req
                              onSuccess:(OnIOSuccess)onSuccess
                                onError:(OnIOError)onError
{
//    [req addHeaders:@{@"Accept-Encoding" : @"gzip, deflate", @"Cache-Control" : @"no-cache"}];
    
    return [self enqueueHttpRequest:req withIoManager:_mediaIO onSuccess:onSuccess onError:onError];
}

- (ApiCanceler *)enqueueMediaRequest:(IORequest *)req
                           onSuccess:(OnIOSuccess)onSuccess
                             onError:(OnIOError)onError
{
    return [self enqueueRequest:req withIoManager:_mediaIO onSuccess:onSuccess onError:onError];
}

- (ApiCanceler *)enqueueRequest:(IORequest *)req
                  withIoManager:(IOManager *)ioManager
                      onSuccess:(OnIOSuccess)onSuccess
                        onError:(OnIOError)onError
{
    __block UniqueNumber *req_id = nil;
    
    req.onSuccess =^(id result) {
        [self removeIOReqFromPending:req_id withIoManager:ioManager];
        
        if (onSuccess)
            onSuccess(result);
    };
    
    req.onError = ^(NSError *error) {
        [self removeIOReqFromPending:req_id withIoManager:ioManager];
        
        if (onError)
            onError(error);
    };
    
    req_id = [ioManager enqueueRequest:req];
    [self addIOReqToPending:req_id withIoManager:ioManager];
    
    return [[ApiCanceler alloc] initWithApiManager:self
             ioManager:(__bridge const void*)ioManager reqId:req_id];
}

- (ApiCanceler *)enqueueDBRequest:(DbExecAsyncFunc)req
                         pipeline:(NSArray *)pipeline
                        onSuccess:(OnIOSuccess)onSuccess
                          onError:(OnIOError)onError
{
    __block UniqueNumber *req_id = nil;
    
    req_id = [_db
        execAsync:req
        pipeline:pipeline
        onSuccess:^(id res) {
            [self removeDBReqFromPending:req_id];
            
            if (onSuccess)
                onSuccess(res);
        }
        onError:^(NSError *error) {
            [self removeDBReqFromPending:req_id];
            
            if (onError)
                onError(error);
        }
    ];
    
    [self addDBReqToPending:req_id];
    
    return [[ApiCanceler alloc] initWithApiManager:self
        dbManager:(__bridge const void*)_db reqId:req_id];
}

- (ApiCanceler *)execAsyncBlock:(void(^)())block onComplete:(void(^)())onComplete
{
    ApiCancelerFlag *flag = [ApiCancelerFlag new];
    ApiCanceler *canceler = [[ApiCanceler alloc] initWithImpl:flag];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        block();
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!flag.isCanceled && onComplete) {
                onComplete();
            }
        });
    });
    
    return canceler;
}

- (ApiCanceler *)execAsyncBlock:(PipelineResult *(^)())block
                       pipeline:(NSArray *)pipeline
                      onSuccess:(OnIOSuccess)onSuccess
                        onError:(OnIOError)onError
{
    ApiCancelerFlag *flag = [ApiCancelerFlag new];
    ApiCanceler *canceler = [[ApiCanceler alloc] initWithImpl:flag];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PipelineResult *res = block();
        
        void (^onSuccessImpl)(id result) = ^(id result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!flag.isCanceled && onSuccess) {
                    onSuccess(result);
                }
            });
        };
        
        void (^onErrorImpl)(NSError *error) = ^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!flag.isCanceled && onError) {
                    onError(error);
                }
            });
        };
        
        if (!res.error && pipeline.count) {
            PipelineItem *head = pipeline.firstObject;
            NSArray *tail = [pipeline subarrayWithRange:NSMakeRange(1, pipeline.count - 1)];
            
            PipelineContext *ctx = [[PipelineContext alloc] initWithOnSuccess:^(id result) {
                onSuccessImpl(result);
            } onError:^(NSError *error) {
                onErrorImpl(error);
            } callOnPPLThread:^(void(^fn)()) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), fn);
            } restartRequest:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (onError) {
                        onError([InternalError errorWithDescr:@"not supported"]);
                    }
                });
            }];
            
            [head call:res.result pipelineTail:tail ctx:ctx];
        } else if (res.error) {
            onErrorImpl(res.error);
        } else {
            onSuccessImpl(res.result);
        }
    });
    
    return canceler;
}

- (ApiCanceler *)execAsyncBlock:(PipelineResult *(^)())block
                      onSuccess:(OnIOSuccess)onSuccess
                        onError:(OnIOError)onError
{
    return [self execAsyncBlock:block pipeline:@[] onSuccess:onSuccess onError:onError];
}

- (void)execDBRequest:(DbExecSyncFunc)req
{
    [_db exec:req];
}

- (void)clearCaches
{
    [_apiIO clearAllCaches];
    [_mediaIO clearAllCaches];
}

@end
