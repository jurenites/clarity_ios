//
//  IOManager.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/7/13.
//
//

#import <Foundation/Foundation.h>
#import "IOHTTPRequest.h"
#import "NSError+IO.h"
#import "NetReachability.h"
#import "FileCache.h"
#import "UniqueNumber.h"

@class IOManager;
@protocol IOManagerDelegate <NSObject>

@optional
- (void)ioManagerGoToOnline:(IOManager *)iom reach:(IONetReachability)reach;
- (void)ioManagerGoToOffline:(IOManager *)iom reach:(IONetReachability)reach;

@end

//------------------------------------
@interface IOManagerDelegateWeak

@property (weak, nonatomic) id<IOManagerDelegate> delegate;

@end

//-------------------------------
@protocol IOManagerInThread <NSObject>

- (FileCache *)diskCacheByName:(NSString *)name;

@end

//----------------------------------
@interface IOManager : NSThread

- (instancetype)initWithMaxSimulReqs:(size_t)maxReqs;

- (void)start;
- (void)stop;

- (void)addDiskCache:(FileCache *)diskCache withName:(NSString *)name;
- (void)clearAllCaches;

- (UniqueNumber *)enqueueRequest:(IORequest *)request;
- (void)reorderRequests:(NSArray *)newRequestsOrder;

- (void)cancelRequest:(UniqueNumber *)reqId;
- (void)cancelRequests:(NSArray *)reqIds;

- (void)addDelegate:(id<IOManagerDelegate>)delegate;
- (void)removeDelegate:(id<IOManagerDelegate>)delegate;

- (void)performBlock:(void(^)())block;

- (void)exec:(void(^)(id<IOManagerInThread> iom))block;
- (void)execAsync:(void(^)(id<IOManagerInThread> iom))block;

@property (readonly, atomic) IONetReachability reachability;
@property (readonly, atomic) BOOL inOnline;

@end
