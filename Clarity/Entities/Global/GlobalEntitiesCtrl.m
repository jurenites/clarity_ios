//
//  GlobalEntitiesCtrl.m
//  TRN
//
//  Created by Oleg Kasimov on 12/2/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "GlobalEntitiesCtrl.h"
//#import "User+API.h"
//#import "TRNLocation+API.h"
//#import "Neighborhood.h"
//#import "Neighborhood+API.h"
//#import "TRNApiManager.h"
//#import "HealthProfile+API.h"
//#import "TRNApiManager+Session.h"
#import "DeviceHardware.h"
//#import "Helpshift.h"
//
//#import "VCtrlDashboard.h"
//#import "VCtrlFindTrainer.h"
//#import "VCtrlSpecialistsList.h"
//#import "VCtrlMenu.h"
//#import "VCtrlLogin.h"
//#import "VCtrlCreateChoose.h"
//#import "VCtrlMemberSignUp.h"
//#import "VCtrlSpecialistSignIn.h"
//#import "VCtrlSpecialistType.h"
//#import "VCtrlCreateLocation.h"

static NSString * const UserDictKey = @"UserDictKey";
static NSString * const StatusesDictKey = @"OrdersStatuses";
//static NSString * const LocationsKey = @"LocationsKey";
//static NSString * const RegionsKey = @"NeighborhoodsKey";
//static NSString * const AnonymousPromoKey = @"AnonymousPromoKey";
//
////Session
//static NSString * const TimeToStartSession = @"TimeToStartSession";
//static NSInteger const InSessionInterval = 60;
//static NSInteger const BeforeSessionInterval = 5 *60;

//#define USER_ONBOARDING     @"onboarding_flow"

@interface GlobalEntitiesCtrl() <AppDelegateDelegate, ApiRouterDelegate> //, HelpshiftDelegate
{
    NSDictionary *_statuses;
//    NSMutableDictionary *_locationsDict;
//    NSMutableDictionary *_regionsDict;
//    
//    NSTimer *_sessionTimer;
//    
//    ApiCanceler *_updSession;
//    ApiCanceler *_updCounters;
//    ApiCanceler *_loadSessions;
//    
//    Session *_startedSession;
//    
//    NSMutableOrderedSet *_cachedAnonymousPromos;
}
@end

@implementation GlobalEntitiesCtrl

+ (GlobalEntitiesCtrl *)shared
{
    static GlobalEntitiesCtrl *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[GlobalEntitiesCtrl alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _currentUser    = [User new];
    _statuses = [NSDictionary new];
//    _regions        = [NSArray new];
//    _locationsDict  = [NSMutableDictionary new];
//    _regionsDict    = [NSMutableDictionary new];
//    
//    _bookedSessions     = [NSArray new];
//    _completedSessions  = [NSArray new];
//    _canceledSessions   = [NSArray new];
//    _notRatedSessions   = [NSArray new];
//    
//    _cachedAnonymousPromos = [NSMutableOrderedSet new];
//    
//    _startedSession = nil;
//    
//    _messageCount = 0;
//    _sessionCount = 0;
//    _helpshiftCount = 0;
//    
    [[AppDelegate shared] addDelegate:self];
//    [[Helpshift sharedInstance] setDelegate:self];
    [[ApiRouter shared] addDelegate:self];
    
    return self;
}

- (BOOL)loadFromDefaults
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [ud objectForKey:UserDictKey];
    if (!dict) {
        return NO;
    }
    
    [self fillCurrentUserWithDict:dict];
    
    _statuses = AssureIsDict([ud valueForKey:StatusesDictKey]);
//    NSMutableArray *locs = [NSMutableArray new];
//    NSMutableArray *nhs = [NSMutableArray new];
//    
//    for (NSDictionary *d in AssureIsArray([[NSUserDefaults standardUserDefaults] valueForKey:UserDictKey])) {
//        if ([d isKindOfClass:[NSDictionary class]]) {
//            [locs addObject:[TRNLocation fromApiDict:d]];
//        }
//    }
//    
//    for (NSDictionary *nhDict in AssureIsArray([[NSUserDefaults standardUserDefaults] valueForKey:RegionsKey])) {
//        if ([nhDict isKindOfClass:[NSDictionary class]]) {
//            [nhs addObject:[Region fromDict:nhDict]];
//        }
//    }
//    
//    NSMutableDictionary *locsMap = [NSMutableDictionary dictionary];
//    NSMutableDictionary *regionsMap = [NSMutableDictionary dictionary];
//    
//    for (TRNLocation *loc in locs) {
//        locsMap[@(loc.locationId)] = loc;
//    }
//    
//    for (Region *nh in nhs) {
//        regionsMap[@(nh.regionId)] = nh;
//    }
//    
//    _locationsDict = locsMap;
//    _regionsDict = regionsMap;
//    
//    NSArray *promos = AssureIsArray([ud objectForKey:AnonymousPromoKey]);
//    for (NSDictionary *pD in promos) {
//        Promo *p = [Promo fromDict:pD];
//        if (p) {
//           [_cachedAnonymousPromos addObject:p];
//        }
//    }
    
    return YES;
}

- (void)silentUpdateCurrentUserWithUser:(User *)user
{
    _currentUser = user;
    [self saveUser];
}

- (void)updateCurrentUserWithUser:(User *)user
{
    _currentUser = user;
    [self saveUser];
//    [[EventsHub shared] updateCurrentUser];
}

- (void)updateUserLocation:(NSInteger)newLocationId
{
//    _currentUser.locationId = newLocationId;
    [self saveUser];
//    [[EventsHub shared] updateCurrentUser];
}

- (void)fillCurrentUserWithDict:(NSDictionary *)dict
{
//    _currentUser = [User fromApiDict:dict];
}

- (void)saveUser
{
    if (_currentUser) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:[_currentUser toDict] forKey:UserDictKey];
        [ud synchronize];
//        [AquaManager trackUser:_currentUser];
    } else {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud removeObjectForKey:UserDictKey];
        [ud synchronize];
    }
}


- (void)fillOrderStatuses:(NSDictionary *)orderStatuses
{
    _statuses = orderStatuses;
    [[NSUserDefaults standardUserDefaults] setValue:_statuses forKey:StatusesDictKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (NSString *)orderStatusForKey:(NSString *)orderStatusKey
{
    NSString *name = [_statuses objectForKey:orderStatusKey];
    if (!name || name.length == 0) {
        return @"Unknown Status";
    }
    return name;
}

//- (void)saveLocations
//{
//    NSMutableArray *locs = [NSMutableArray array];
//    
//    for (TRNLocation *loc in _locationsDict.allValues) {
//        [locs addObject:[loc toApiDict]];
//    }
//    
//    [[NSUserDefaults standardUserDefaults] setValue:locs forKey:LocationsKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//- (void)saveRegions
//{
//    NSMutableArray *nhs = [NSMutableArray array];
//    
//    for (Region *nh in _regionsDict.allValues) {
//        [nhs addObject:[nh toDict]];
//    }
//    
//    [[NSUserDefaults standardUserDefaults] setValue:nhs forKey:RegionsKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//- (void)setRegions:(NSArray *)regions
//{
//    _regions = [regions copy];
//    _regions = [_regions sortedArrayUsingComparator:^NSComparisonResult(Neighborhood *n1, Neighborhood *n2){
//        if (n1.priority == n2.priority) {
//            return NSOrderedSame;
//        }
//        return n1.priority > n2.priority ? NSOrderedAscending : NSOrderedDescending;
//    }];
//    
//    [_regionsDict removeAllObjects];
//    for (Region *nh in regions) {
//        _regionsDict[@(nh.regionId)] = nh;
//    }
//    
//    [self saveRegions];
//}
//
//- (void)setLocations:(NSArray *)locations
//{
//    if (!locations.count) {
//        return;
//    }
//    
//    [_locationsDict removeAllObjects];
//    
//    for (TRNLocation *loc in locations) {
//        _locationsDict[@(loc.locationId)] = loc;
//    }
//    
//    [self saveLocations];
//}
//
//- (void)addLocation:(TRNLocation *)location
//{
//    _locationsDict[@(location.locationId)] = location;
//    [self saveLocations];
//}
//
//- (void)setTrainerAvailability:(BOOL)availability
//{
//    _currentUser.profile.availability = availability;
//    [self saveUser];
//}
//
//- (TRNLocation *)locationById:(NSInteger)locationId
//{
//    TRNLocation *loc = _locationsDict[@(locationId)];
//    return loc ? loc : [TRNLocation new];
//}
//
//- (Region *)regionById:(NSInteger)regionId
//{
//    Region *nh = _regionsDict[@(regionId)];
//    return nh ? nh : [Region new];
//}
//
//- (Region *)regionForLocationId:(NSInteger)locationId
//{
//    TRNLocation *loc = _locationsDict[@(locationId)];
//    
//    if (loc) {
//        for (Region *nh in _regions) {
//            if (nh.regionId == loc.regionId) {
//                return nh;
//            }
//        }
//    }
//    
//    return nil;
//}
//
//- (NSTimeZone *)myTimeZone
//{
//    if (_currentUser.regionId > 0) {
//        Region *reg = _regionsDict[@(_currentUser.regionId)];
//        
//        if (reg) {
//            return reg.timeZone;
//        }
//    } else if (_currentUser.locationId > 0) {
//        TRNLocation *loc = _locationsDict[@(_currentUser.locationId)];
//        Region *reg = _regionsDict[@(loc.regionId)];
//        
//        if (reg) {
//            return reg.timeZone;
//        }
//    }
//    
//    return [NSTimeZone timeZoneForSecondsFromGMT:0];
//}
//
//#pragma mark - Onboarding
//
//- (OnboardingProgress)onboardingProgressForUser
//{
//    if (_currentUser.profile.gender == UnknownGender || _currentUser.profile.height == 0 || _currentUser.profile.weight == 0) {
//        return OnboardingProgressBasic;
//    }
//    
//    if (!_currentUser.profile.heartCondition || _currentUser.profile.personalGoals.length == 0) {
//        return OnboardingProgressMedical;
//    }
//    
//    return OnboardingProgressDone;
//}
//
//#pragma mark - Badges
//- (void)setSessionCount:(NSInteger)sessionCount
//{
//    _sessionCount = sessionCount > 0 ? sessionCount : 0;
//    [self setupAppBadge];
//}
//- (void)setMessageCount:(NSInteger)messageCount
//{
//    _messageCount = messageCount > 0 ? messageCount : 0;
//    [self setupAppBadge];
//}
//
//- (void)updateCountersOnComplete:(void(^)())onComplete
//{
//    if (_updCounters) {
//        return;
//    }
//    _updCounters = [[TRNApiManager shared] getHomeScreenInfo:_currentUser onSuccess:^(Session *session, NSInteger unreadSessions, NSInteger newMessages) {
//        [self updateAppBadgeWithUnreadSessions:unreadSessions newMessages:newMessages];
//        if (onComplete) {
//            onComplete();
//        }
//        _updCounters = nil;
//    } onError:^(NSError *error) {
//        if (onComplete) {
//            onComplete();
//        }
//        _updCounters = nil;
//    }];
//}
//
//- (void)updateAppBadgeWithUnreadSessions:(NSInteger)sessionsCount
//                             newMessages:(NSInteger)messagesCount
//{
//    [self setSessionCount:sessionsCount];
//    [self setMessageCount:messagesCount];
////    _helpshiftCount = [[Helpshift sharedInstance] getNotificationCountFromRemote:NO];
//    [[Helpshift sharedInstance] getNotificationCountFromRemote:YES];
//
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[EventsHub shared] updateDashboardCounters];
//    });
//    
//    [self setupAppBadge];
//}
//
//- (void)setupAppBadge
//{
//    UIApplication *application = [UIApplication sharedApplication];
//    NSInteger badgeNumber = _sessionCount + _messageCount + _helpshiftCount;
//    
//    if([DeviceHardware iOS8AndHiger]) {
//        if ([self checkNotificationType:UIUserNotificationTypeBadge]) {
//            TRNLog(@"badge number changed to %d", badgeNumber);
//            application.applicationIconBadgeNumber = badgeNumber;
//        } else {
//            TRNLog(@"access denied for UIUserNotificationTypeBadge");
//        }
//    } else {
//        application.applicationIconBadgeNumber = badgeNumber;
//    }
//}
//
//#ifdef __IPHONE_8_0
//- (BOOL)checkNotificationType:(UIUserNotificationType)type
//{
//    UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
//    return (currentSettings.types & type);
//}
//#endif
//
//
//#pragma mark - Sessions
//
//- (BOOL)currentUserHasSessions
//{
//    return _currentUser != nil && (_bookedSessions.count  > 0 || _completedSessions.count > 0 || _canceledSessions.count > 0);
//}
//
//- (void)didRateSession:(Session *)session
//{
//    if (!session) {
//        return;
//    }
//    
//    NSMutableArray *notRated = [NSMutableArray arrayWithArray:_notRatedSessions];
//    NSUInteger i = [notRated indexOfObjectPassingTest:^BOOL(Session *obj, NSUInteger idx, BOOL *stop) {
//        return obj.sessionId = session.sessionId;
//    }];
//    
//    if (i != NSNotFound) {
//        [notRated removeObjectAtIndex:i];
//    }
//    _notRatedSessions = notRated;
//}
//
//- (void)processCompletedSessions:(NSArray *)cSessions bookedSessions:(NSArray *)bSessions
//{
//    NSMutableArray *sortBookedSessions = [NSMutableArray new];
//    NSMutableArray *canceledSessions = [NSMutableArray new];
//    for (Session *s in bSessions) {
//        if (s.status == SessionStatusCanceled) {
//            [canceledSessions addObject:s];
//            continue;
//        }
//        
//        if (s.status == SessionStatusStarted) {
//            _startedSession = s;
//        }
//        
//        [sortBookedSessions addObject:s];
//    }
//    
//    _bookedSessions = sortBookedSessions;
//    _completedSessions = cSessions;
//    _canceledSessions = canceledSessions;
//    
//    _startedSession = nil;
//    _scheduledSession = nil;
//    
//    NSMutableArray *notRated = [NSMutableArray new];
//    
//    for (Session *s in _completedSessions) {
//        if (s.status != SessionStatusUnattended && s.status != SessionStatusCanceled && s.member.rate == 0) {
//            [notRated addObject:s];
//        }
//    }
//    
//    _notRatedSessions = notRated;
//    
//    BOOL isTrainer = [[GlobalEntitiesCtrl shared].currentUser isTrainer];
//    
//    if (_startedSession) {
//        if (isTrainer) {
//            [[EventsHub shared] enqueueSession:_startedSession];
//            [self runTimerForSession:_startedSession];
//            return;
//        }
//        [[EventsHub shared] startSession:_startedSession];
//        [self runTimerForSession:_startedSession];
//    } else {
//        NSMutableArray *arr = [NSMutableArray arrayWithArray:_bookedSessions];
//        [arr sortUsingComparator:^NSComparisonResult(Session *obj1, Session *obj2) {
//            return [obj1.dateFrom compare:obj2.dateFrom] == NSOrderedDescending;
//        }];
//        [self runTimerForSession:arr.firstObject];
//        
//        if (_notRatedSessions.count && !isTrainer) {
//            [[EventsHub shared] finishSession:_notRatedSessions.firstObject];
//        }
//    }
//    [[EventsHub shared] updateDashboardCounters];
//}
//
//- (void)immidiatelyProcessSession:(Session *)session
//{
//    if (session.status == SessionStatusStarted) {
//        [[EventsHub shared] startSession:session];
//        TRNLog(@"\n#################\nSession started\n#################");
//        CallSyncOnMainThread(^{
//            [self runTimerForSession:session];
//        });
//    } else if (session.status != SessionStatusBooked){
//        [[EventsHub shared] finishSession:session];
//        TRNLog(@"\n#################\nSession finished\n#################");
//        [self updateSessions];
//    } else if (session.status == SessionStatusBooked) {
//        [self runTimerForSession:session];
//    }
//}
//
//- (void)stopTrackingSession
//{
//    if (_sessionTimer) {
//        [_sessionTimer invalidate];
//        _sessionTimer = nil;
//    }
//}
//
//- (void)checkSessionByPushInfo:(NSDictionary *)pushInfo
//                 openingScreen:(BOOL)openingScreen
//                     onSuccess:(void (^)(Session *session))onSuccess
//                       onError:(void (^)(NSError *error))onError
//{
//    if (!pushInfo) {
//        if (onSuccess) {
//            onSuccess(nil); //TODO Should onError?
//        }
//        return;
//    }
//    NSString *type = ToString(pushInfo[@"push_type"]);
//    NSUInteger sessionId = ToInt(pushInfo[@"session_id"]);
//    
//    if (_updSession) {
//        return;
//    }
//    TRNLog(@"\n#################\nAsk for session status from PUSH\n#################");
//    User *me = [GlobalEntitiesCtrl shared].currentUser;
//    _updSession = [[TRNApiManager shared] getSessionById:sessionId forUser:me onSuccess:^(Session *session) {
//        if ([type isEqualToString:@"session_started"] && session.status == SessionStatusStarted) {
//            if (openingScreen) {
//                [[EventsHub shared] startSession:session];
//            }
//            if (onSuccess) {
//                onSuccess(session);
//            }
//            _startedSession = session;
//            TRNLog(@"\n#################\nSession started from PUSH\n#################");
//            CallSyncOnMainThread(^{
//                [self runTimerForSession:session];
//            });
//        } else if ([type isEqualToString:@"session_stopped"] && session.status != SessionStatusStarted && session.status != SessionStatusBooked) {
//            if (openingScreen) {
//                [[EventsHub shared] finishSession:session];
//            }
//            if (onSuccess) {
//                onSuccess(session);
//            }
//            _startedSession = nil;
//            TRNLog(@"\n#################\nSession finished from PUSH\n#################");
//            [self stopTrackingSession];
//            [self updateSessions];
//        }
//        _updSession = nil;
//    } onError:^(NSError *error) {
//        _updSession = nil;
//        if (onError) {
//            onError(error);
//        }
//    }];
//}
//
//- (void)updateSessions
//{
//    if (_loadSessions) {
//        return;
//    }
//    [self updateSessionsOnSuccess:NULL onError:NULL];
//}
//
//- (void)updateSessionsOnSuccess:(SessionsUpdated)onSuccess onError:(SessionsError)onError
//{
//    _loadSessions = [[TRNApi shared] loadSessions:^(NSArray *completed, NSArray * booked) {
//        [self processCompletedSessions:completed bookedSessions:booked];
//        if (onSuccess) {
//            //WARNING!!!
//            //It's important to know - in booked session will be also some canceled session due to app logic.
//            //If you need only booked sessions then in completition block get bookedSessions of shared instance
//            onSuccess(completed, booked, _startedSession);
//        }
//        _loadSessions = nil;
//    } onError:^(NSError * error) {
//        if (onError) {
//            onError(error);
//        }
//        _loadSessions = nil;
//    }];
//}
//
//- (void)updateSession:(NSTimer *)timer
//{
//    if (_updSession) {
//        return;
//    }
//    
//    NSString *userInfo = nil;
//    if (timer.userInfo) {
//        userInfo = ToString(timer.userInfo);
//    }
//    
//    TRNLog(@"\n#################\nAsk for session status\n#################");
//    User *me = [GlobalEntitiesCtrl shared].currentUser;
//    BOOL isTrainer = [me isTrainer];
//    _updSession = [[TRNApiManager shared] getSessionById:_scheduledSession.sessionId forUser:me onSuccess:^(Session *session) {
//        if (session.status != _scheduledSession.status) {
//            if (_scheduledSession.status == SessionStatusBooked && session.status == SessionStatusStarted) {
//                if (isTrainer) {
//                    [[EventsHub shared] enqueueSession:session];
//                } else {
//                    [[EventsHub shared] startSession:session];
//                }
//                
//                _startedSession = session;
//                TRNLog(@"\n#################\nSession started\n#################");
//                CallSyncOnMainThread(^{
//                    [self runTimerForSession:session];
//                });
//            } else {
//                if (isTrainer) {
//                    [[EventsHub shared] enqueueSession:nil];
//                } else {
//                    [[EventsHub shared] finishSession:session];
//                }
//                
//                _startedSession = nil;
//                TRNLog(@"\n#################\nSession finished\n#################");
//                [self stopTrackingSession];
//                [self updateSessions];
//            }
//        } else if ([userInfo isEqualToString:TimeToStartSession]) {
//            TRNLog(@"\n#################\nTime to spam for Session status\n#################");
//            CallSyncOnMainThread(^{
//                [self runTimerForSession:session];
//            });
//        }
//        _updSession = nil;
//    } onError:^(NSError *error) {
//        _updSession = nil;
//    }];
//}
//
//- (void)runTimerForSession:(Session *)session
//{
//    if (_sessionTimer) {
//        [_sessionTimer invalidate];
//        _sessionTimer = nil;
//    }
//    
//    if (!session) {
//        [[EventsHub shared] enqueueSession:nil];
//        return;
//    } else {
//        _scheduledSession = session;
//    }
//    
//    NSTimeInterval interval = [session.dateFrom timeIntervalSinceDate:[NSDate date]];
//    if (interval <= BeforeSessionInterval) {
//        _sessionTimer = [NSTimer scheduledTimerWithTimeInterval:InSessionInterval target:self selector:@selector(updateSession:) userInfo:nil repeats:YES];
//    } else {
//        TRNLog(@"\n#################\nSetup session timer till start\n#################");
//        _sessionTimer = [NSTimer scheduledTimerWithTimeInterval:interval-BeforeSessionInterval
//                                                         target:self
//                                                       selector:@selector(updateSession:)
//                                                       userInfo:[NSString stringWithString:TimeToStartSession]
//                                                        repeats:NO];
//    }
//    
//    [[EventsHub shared] enqueueSession:_scheduledSession];
//}
//
//- (void)update
//{
//    if (![TRNApiManager shared].apiRouter.isLoggedIn) {
//        return;
//    }
//    
//    if (![_currentUser isComplete] || ![_currentUser locationIsConfirmed]) {
//        return;
//    }
//    
//    [self updateSessions];
//    [self updateCountersOnComplete:NULL];
//}
//
//#pragma mark - Anonimous
//
//- (void)addAnonymousPromo:(Promo *)promo
//{
//    if (!promo) {
//        return;
//    }
//    
//    [_cachedAnonymousPromos addObject:promo];
//    [self saveAnonymousPromos];
//}
//
//- (NSArray *)savedAnonymousPromos
//{
//    return _cachedAnonymousPromos.array;
//}
//
//- (void)saveAnonymousPromos
//{
//    NSMutableArray *promos = [NSMutableArray array];
//    
//    for (Promo *promo in _cachedAnonymousPromos) {
//        [promos addObject:[promo toDict]];
//    }
//    
//    [[NSUserDefaults standardUserDefaults] setValue:promos forKey:AnonymousPromoKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//- (void)cleanAnonymousPromos
//{
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:AnonymousPromoKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}

//#pragma mark - AGAppDelegate
//- (void)appWillEnterForeground
//{
//    [self update];
//}
//
//#pragma mark - ApiRouter Delegate
//- (void)apiRouter:(ApiRouter *)apiRouter stateChanged:(ApiRouterState)state prevState:(ApiRouterState)prev
//{
//    if (state == ApiRouterStateConnected) {
//        [self update];
//    }
//}
//
//#pragma mark - Helpshift Delegate
//- (void) didReceiveNotificationCount:(NSInteger)count
//{
//    if( _helpshiftCount == count )
//        return;
//    
//    _helpshiftCount = count;
//    [self updateAppBadgeWithUnreadSessions:_sessionCount newMessages:_messageCount];
//}
//
//- (void) helpshiftSessionHasEnded
//{
//    [self updateAppBadgeWithUnreadSessions:_sessionCount newMessages:_messageCount];
//}
//
//- (void) didReceiveInAppNotificationWithMessageCount:(NSInteger)count
//{
//    if( _helpshiftCount == count )
//        return;
//    
//    _helpshiftCount = count;
//    [self updateAppBadgeWithUnreadSessions:_sessionCount newMessages:_messageCount];
//}

@end