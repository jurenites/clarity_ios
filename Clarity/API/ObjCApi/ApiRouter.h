//
//  ApiRouter.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/14/14.
//
//

#import <Foundation/Foundation.h>
#import "IOManager.h"
#import "DBManager.h"
#import "ApiCanceler.h"
#import "ApiMethods.h"
#import "AvatarFileCache.h"
#import "MediaFileCache.h"


typedef enum {
    ApiRouterStateConnecting,
    ApiRouterStateConnected,
    ApiRouterStateOffline
} ApiRouterState;

//-----------------------------------
@class ApiRouter;

@protocol ApiRouterDelegate <NSObject>

@optional
- (void)apiRouter:(ApiRouter *)apiRouter stateChanged:(ApiRouterState)state prevState:(ApiRouterState)prev;

- (void)apiRouterWillLogout:(ApiRouter *)apiRouter;
- (void)apiRouterDidLogout:(ApiRouter *)apiRouter;

- (void)apiRouterUserLoggedIn:(ApiRouter *)apiRouter;

@end


@protocol ApiRouterLoginDelegate <NSObject>

- (void)apiRouterPrepareForLogout:(ApiRouter *)apiRouter onComplete:(void(^)())onComplete;
- (void)apiRouterLogoutComplete:(ApiRouter *)apiRouter;

@end

//-----------------------------------
@interface ApiRouter : NSObject

+ (ApiRouter *)shared;

- (NSError *)startup;

- (void)addDelegate:(id<ApiRouterDelegate>)delegate;
- (void)removeDelegate:(id<ApiRouterDelegate>)delegate;

- (void)prepareHttpRequest:(IOHTTPRequest *)request
              withMethodID:(ApiMethodID)methodID
              andUrlParams:(NSDictionary *)urlParams;

- (void)prepareHttpRequest:(IOHTTPRequest *)request
              withMethodID:(ApiMethodID)methodID;

@property (readonly, nonatomic) IOManager *apiIO;
@property (readonly, nonatomic) IOManager *mediaIO;
@property (readonly, nonatomic) DBManager *db;
@property (readonly, nonatomic) MediaFileCache *mediaFileCache;
@property (readonly, nonatomic) AvatarFileCache *avatarFileCache;

@property (readonly, nonatomic) ApiRouterState state;
@property (readonly, nonatomic) IONetReachability netReachability;
@property (readonly, nonatomic) BOOL inOnline;

@property (readonly, nonatomic) BOOL discoveryReceived;
@property (readonly, nonatomic) NSInteger currentUserId;
@property (readonly, nonatomic) BOOL isLoggedIn;
@property (readonly, nonatomic) NSString *apiToken;
@property (strong, nonatomic) NSString *apnsToken;

@property (weak, nonatomic) id<ApiRouterLoginDelegate> loginDelegate;

@end
