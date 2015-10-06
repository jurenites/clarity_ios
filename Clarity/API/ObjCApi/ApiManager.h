//
//  ApiManager.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/11/13.
//
//

#import <Foundation/Foundation.h>
#import "IOCachedHTTPRequest.h"
#import "DBManager.h"
#import "ApiCanceler.h"
#import "ApiRouter.h"
#import "PipelineItem.h"

@class ApiMethod;

@interface ApiManager : NSObject

- (IOHTTPRequest *)requestWithMethod:(ApiMethodID)methodID;

- (IOHTTPRequest *)requestWithMethod:(ApiMethodID)methodID
                        andUrlParams:(NSDictionary *)urlParams;

- (IOCachedHTTPRequest *)cachedRequestWithMethod:(ApiMethodID)methodID;

- (IOCachedHTTPRequest *)cachedRequestWithMethod:(ApiMethodID)methodID
                                    andUrlParams:(NSDictionary *)urlParams;

- (ApiCanceler *)enqueueHttpRequest:(IOHTTPRequest *)req
                          onSuccess:(OnIOSuccess)onSuccess
                            onError:(OnIOError)onError;

- (ApiCanceler *)enqueueApiRequest:(IOHTTPRequest *)req
                         onSuccess:(OnIOSuccess)onSuccess
                           onError:(OnIOError)onError;

- (ApiCanceler *)enqueueApiRequest:(IOHTTPRequest *)req
                          pipeline:(NSArray *)pipeline
                         onSuccess:(OnIOSuccess)onSuccess
                           onError:(OnIOError)onError;

- (ApiCanceler *)callMethodWithName:(NSString *)name
                             params:(NSDictionary *)params
                           pipeline:(NSArray *)pipeline
                          onSuccess:(OnIOSuccess)onSuccess
                            onError:(OnIOError)onError;

- (ApiCanceler *)callMethodWithName:(NSString *)name
                             params:(NSDictionary *)params
                           apiToken:(NSString *)apiToken
                           pipeline:(NSArray *)pipeline
                          onSuccess:(OnIOSuccess)onSuccess
                            onError:(OnIOError)onError;

- (ApiCanceler  *)enqueueMediaHttpRequest:(IOHTTPRequest *)req
                                onSuccess:(OnIOSuccess)onSuccess
                                  onError:(OnIOError)onError;

- (ApiCanceler *)enqueueMediaRequest:(IORequest *)req
                           onSuccess:(OnIOSuccess)onSuccess
                             onError:(OnIOError)onError;

- (ApiCanceler *)enqueueDBRequest:(DbExecAsyncFunc)req
                         pipeline:(NSArray *)pipeline
                        onSuccess:(OnIOSuccess)onSuccess
                          onError:(OnIOError)onError;

- (void)execDBRequest:(DbExecSyncFunc)req;

- (ApiCanceler *)execAsyncBlock:(void(^)())block onComplete:(void(^)())onComplete;

- (ApiCanceler *)execAsyncBlock:(PipelineResult *(^)())block
                      onSuccess:(OnIOSuccess)onSuccess
                        onError:(OnIOError)onError;

- (ApiCanceler *)execAsyncBlock:(PipelineResult *(^)())block
                       pipeline:(NSArray *)pipeline
                      onSuccess:(OnIOSuccess)onSuccess
                        onError:(OnIOError)onError;

- (void)cancelReqId:(UniqueNumber *)reqId ioManager:(const void *)ioManager;
- (void)cancelReqId:(UniqueNumber *)reqId dbManager:(const void *)dbManager;

- (void)cancelAllRequests;
- (void)clearCaches;

@property (readonly, nonatomic) ApiRouter *apiRouter;
@property (readonly, nonatomic) DBManager *db;

@end
