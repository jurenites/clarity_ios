//
//  ApiRouter.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/14/14.
//
//

#import "ApiRouter.h"
#import "ApiRouter_Auth.h"
#import "MediaFileCache.h"
#import "AvatarFileCache.h"
#import "IOHTTPRequest.h"
#import "PLIParseJson.h"
#import "PLITypeCheck.h"
#import "DelegatesHolder.h"
#import "ApiMethod.h"
#import "ApiMethods.h"
//#import "TRNApiManager.h"
//#import "FlashUpdateHolder.h"
#import "AppDelegate.h"
//#import "TRNApiManager+User.h"
//#import "Helpshift.h"

static const int BBMaxSimulApiRequests = 8000;
static const int BBMaxSimulMediaRequests = 3;
//static const int BBTryLoadDiscoveryIval = 10;
static NSString * const BBDbFileName = @"local_db.sqlite";

static NSString * const BBDiscoveryServerUrlKey = @"DiscoveryServerURL";
static NSString * const BBApiTokenKey = @"BBApiTokenKey";
static NSString * const BBCurrentUserIdKey = @"BBCurrentUserIdKey";
static NSString * const BBBundleVersionKey = @"CFBundleShortVersionString";

static NSString *const kTokenName = @"Authorization";

static NSString * const ServerURLKey = @"ServerUrl";

//static NSString * const ProtocolScheme = @"http://";
//static NSString * const Server = @"hurricanegold.lifechurch.tv/api/v1";//@"staff-portal-d7.local.stagingmonster.com/api/v1";

static ApiRouter * volatile BBSharedApiRouter = nil;


@interface ApiRouter () <IOManagerDelegate>
{
    NSInteger _savedUserId;
    
    DelegatesHolder *_delegates;
    NSTimer *_reloadDiscoveryTimer;
    UniqueNumber *_loadDiscoveryReqId;
    
    NSDictionary *_servers;
    NSDictionary *_methods;
    
    NSString *_apiToken;
    NSString *_serverUrl;
    
    ApiCanceler *_loginOperation;
    BOOL _needSendApnsToken;
}

- (void)changeState:(ApiRouterState)newState;

@property (readonly, nonatomic) BOOL isNetworkReachable;

@property (readonly, nonatomic) User *currentUser;

@end

@implementation ApiRouter


+ (ApiRouter *)shared
{
    if (!BBSharedApiRouter) {
        @synchronized(self) {
            if (!BBSharedApiRouter) {
                BBSharedApiRouter = [ApiRouter new];
            }
        }
    }

    return BBSharedApiRouter;
}

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;
    
    _serverUrl = [[[NSBundle mainBundle] infoDictionary] objectForKey:ServerURLKey];
    _state = ApiRouterStateConnecting;
    _delegates = [DelegatesHolder new];
    _apiToken = [[NSUserDefaults standardUserDefaults] stringForKey:BBApiTokenKey];
    _methods = [ApiMethods getMethods];
    _needSendApnsToken = YES;
    
    return self;
}

- (void)dealloc
{
    [_apiIO removeDelegate:self];
}

- (NSInteger)currentUserId
{
    return _currentUser.userId;
}

- (NSError *)startup
{
    NSError *error = nil;

    _apiIO = [[IOManager alloc] initWithMaxSimulReqs:BBMaxSimulApiRequests];
    [_apiIO addDelegate:self];
    
    [_apiIO start];
    
    _mediaIO = [[IOManager alloc] initWithMaxSimulReqs:BBMaxSimulMediaRequests];
    [_mediaIO start];
    
    _db = [[DBManager alloc] initWithDBFileName:BBDbFileName];
    [_db startDb:&error];
    
    _mediaFileCache = [MediaFileCache new];
    _avatarFileCache = [AvatarFileCache new];
    
    [self.mediaIO addDiskCache:_mediaFileCache
                      withName:[MediaFileCache name]];
    
    [self.mediaIO addDiskCache:_avatarFileCache
                      withName:[AvatarFileCache name]];
    
    if (self.isNetworkReachable) {
       _state = ApiRouterStateConnected;
    } else {
        _state = ApiRouterStateOffline;
    }
    
    _savedUserId = [[NSUserDefaults standardUserDefaults] integerForKey:BBCurrentUserIdKey];
    
    if (_savedUserId) {
        _currentUser = [User new];
        _currentUser.userId = (int)_savedUserId;
        
//        [FlashUpdateHolder start];
    }
    
    return error;
}


- (void)addDelegate:(id<ApiRouterDelegate>)delegate
{
    [_delegates addDelegate:delegate];
}

- (void)removeDelegate:(id<ApiRouterDelegate>)delegate
{
    [_delegates removeDelegate:delegate];
}

- (BOOL)isNetworkReachable
{
    return self.apiIO.inOnline;
}

- (IONetReachability)netReachability
{
    return self.apiIO.reachability;
}

- (void)changeState:(ApiRouterState)newState
{
    if (newState == _state) {
        return;
    }
    
    ApiRouterState prevState = _state;
    _state = newState;
    
    for (id<ApiRouterDelegate> delegate in [_delegates getDelegates]) {
        if ([delegate respondsToSelector:@selector(apiRouter:stateChanged:prevState:)]) {
            [delegate apiRouter:self stateChanged:_state prevState:prevState];
        }
    }
}

- (NSString *)apiToken
{
    return _apiToken;
}

- (void)checkApnsToken
{
    if (self.isLoggedIn && self.apnsToken.length > 0 && _currentUser.userId > 0 && _needSendApnsToken) {
//        [[TRNApiManager shared] setApnsToken:self.apnsToken forUserId:_currentUser.userId onSuccess:^{
//            _needSendApnsToken = NO;
//       } onError:^(NSError *error) {
//           _needSendApnsToken = YES;
//       }];
    }
}

- (void)cleanup:(void(^)())onComplete
{    
    [[ClarityApiManager shared] execAsyncBlock:^{
        [_apiIO clearAllCaches];
        [_mediaIO clearAllCaches];
        [_db recreateDb];
    } onComplete:onComplete];
}

- (void)userLoggedIn:(User *)user
        withApiToken:(NSString *)apiToken
          onComplete:(void(^)())onComplete
{
    NSParameterAssert(user);
    NSParameterAssert(apiToken.length);
    
    _currentUser = user;
    _apiToken = [NSString stringWithFormat:@"Bearer %@", apiToken];
    
    [[NSUserDefaults standardUserDefaults] setObject:_apiToken forKey:BBApiTokenKey];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.currentUser.userId) forKey:BBCurrentUserIdKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[GlobalEntitiesCtrl shared] updateCurrentUserWithUser:user];
//
//    [Helpshift loginWithIdentifier:[NSString stringWithFormat:@"%d", user.userId]
//                          withName:user.userName
//                          andEmail:user.email];

    void (^doNext)() = ^{
        _savedUserId = self.currentUser.userId;
        
        [_db execAsync:^id(Database *db) {
            return nil;
        }];
        
        
        if (onComplete) {
            onComplete();
        }
        
        [self checkApnsToken];
        
        for (id<ApiRouterDelegate> d in [_delegates getDelegates]) {
            if ([d respondsToSelector:@selector(apiRouterUserLoggedIn:)]) {
                [d apiRouterUserLoggedIn:self];
            }
        }
    };

    if (_savedUserId && _savedUserId != self.currentUser.userId) {
        [self cleanup:doNext];
    } else {
        doNext();
    }
}

- (void)notifyWillLogout
{
    for (id<ApiRouterDelegate> delegate in [_delegates getDelegates]) {
        if ([delegate respondsToSelector:@selector(apiRouterWillLogout:)]) {
            [delegate apiRouterWillLogout:self];
        }
    }
}

- (void)notifyDidLogout
{
    for (id<ApiRouterDelegate> delegate in [_delegates getDelegates]) {
        if ([delegate respondsToSelector:@selector(apiRouterDidLogout:)]) {
            [delegate apiRouterDidLogout:self];
        }
    }
}

- (void)invalidateLogin
{
    _needSendApnsToken = YES;
    [self notifyWillLogout];
    
    void (^doLogout)() = ^{
        _apiToken = @"";
        _currentUser = nil;
        _savedUserId = 0;
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:BBApiTokenKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:BBCurrentUserIdKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
//        [Helpshift logout];
//        
//        [[GlobalEntitiesCtrl shared] stopTrackingSession];
        [[GlobalEntitiesCtrl shared] updateCurrentUserWithUser:nil];
        
        [_apiIO clearAllCaches];
        [_mediaIO clearAllCaches];
        [_db recreateDb];
        
        [self.loginDelegate apiRouterLogoutComplete:self];
        [self notifyDidLogout];
    };

    if (self.loginDelegate) {
        [self.loginDelegate apiRouterPrepareForLogout:self onComplete:doLogout];
    } else {
        doLogout();
    }
}

- (void)logout
{
    if (_apiToken.length == 0) {
        return;
    }
    
    _needSendApnsToken = YES;
    [self notifyWillLogout];
    
    void (^doLogout)() = ^{
//        [[TRNApiManager shared] logoutOnComplete:^{
//            _currentUser = nil;
//            _savedUserId = 0;
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey:BBApiTokenKey];
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey:BBCurrentUserIdKey];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            
//            [Helpshift logout];
//            
//            [[GlobalEntitiesCtrl shared] stopTrackingSession];
//            [[GlobalEntitiesCtrl shared] updateCurrentUserWithUser:nil];
//            
//            [self.loginDelegate apiRouterLogoutComplete:self];
//            [self notifyDidLogout];
//        }];
        
        _apiToken = @""; //Clear token to prevent logout again on invalid token error
    };

    if (self.loginDelegate) {
        [self.loginDelegate apiRouterPrepareForLogout:self onComplete:doLogout];
    } else {
        doLogout();
    }
}

- (void)setApnsToken:(NSString *)apnsToken
{
    NSParameterAssert(apnsToken);
    
    _apnsToken = apnsToken;
    
    [self checkApnsToken];
}

- (BOOL)isLoggedIn
{
    return self.apiToken.length > 0;
}

-(BOOL)discoveryReceived
{
    return _servers != nil;
}

- (BOOL)inOnline
{
    return self.state == ApiRouterStateConnected;
}

#pragma mark -- IOManagerDeledate

- (void)ioManagerGoToOnline:(IOManager *)iom reach:(IONetReachability)reach
{
    [self changeState:ApiRouterStateConnected];
}

- (void)ioManagerGoToOffline:(IOManager *)iom reach:(IONetReachability)reach
{
    [self changeState:ApiRouterStateOffline];
}

#pragma mark ------------------------

- (void)prepareHttpRequest:(IOHTTPRequest *)request
              withMethodID:(ApiMethodID)methodID
{
    [self prepareHttpRequest:request withMethodID:methodID andUrlParams:@{}];
}

- (void)prepareHttpRequest:(IOHTTPRequest *)request
              withMethodID:(ApiMethodID)methodID
              andUrlParams:(NSDictionary *)urlParams
{
    if (self.apiToken.length) {
        [request addHeaders:@{kTokenName : self.apiToken}];
    }
    
    ApiMethod *method = _methods[@(methodID)];
    
    NSAssert(method, @"makeUrlForMethod: unknown method");

    request.url = [NSString stringWithFormat:@"%@%@",
                   _serverUrl,
                   [method buildUrlWithParams:urlParams]];
    
    request.method = method.httpMethod;
}


@end
