//
//  GlobalEntitiesCtrl.m
//  TRN
//
//  Created by Oleg Kasimov on 12/2/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "GlobalEntitiesCtrl.h"
#import "DeviceHardware.h"

static NSString * const UserDictKey = @"UserDictKey";
static NSString * const StatusesDictKey = @"OrdersStatuses";
static NSString * const OrderFiltersDictKey = @"OrderFilters";

@interface GlobalEntitiesCtrl() <AppDelegateDelegate, ApiRouterDelegate>
{
    NSMutableDictionary *_statuses;
    NSMutableDictionary *_orderFiltersDict;
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
    
    _currentUser = [User new];
    _statuses = [NSMutableDictionary new];
    _orderFiltersDict = [NSMutableDictionary new];
    _orderFilters = [NSArray new];
    
    _badgeNumber = 0;

    [[AppDelegate shared] addDelegate:self];
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
    
//    _statuses = AssureIsDict([ud valueForKey:StatusesDictKey]);
//    _orderFiltersDict = AssureIsDict([ud valueForKey:OrderFiltersDictKey]);
//    _orderFilters = _orderFiltersDict.allKeys;
    
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
}

- (BOOL)isMyId:(NSInteger)userId
{
    if (userId == self.currentUser.userId) {
        return YES;
    }
    
    return NO;
}

- (void)updateUserLocation:(NSInteger)newLocationId
{
    [self saveUser];
}

- (void)fillCurrentUserWithDict:(NSDictionary *)dict
{
    _currentUser = [User new];
    [_currentUser fillWithApiDict:dict];
}

- (void)saveUser
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (_currentUser) {
        [ud setObject:[_currentUser toDict] forKey:UserDictKey];
    } else {
        [ud removeObjectForKey:UserDictKey];
    }
    [ud synchronize];
}

- (void)fillFilters:(NSDictionary *)filters
{
    _orderFiltersDict = [NSMutableDictionary dictionaryWithDictionary:filters];
    _orderFilters = _orderFiltersDict.allKeys;
}

- (NSString *)orderFilterForKey:(NSString *)filterKey
{
    NSString *name = [_orderFiltersDict objectForKey:filterKey];
    if (!name || name.length == 0) {
        return nil;
    }
    return name;
}

- (void)fillOrderStatuses:(NSArray *)orderStatuses
{
    [_statuses removeAllObjects];
    if (!orderStatuses.count) {
        return;
    }
    
    for (Status *status in orderStatuses) {
        _statuses[status.key] = status;
    }
}

- (Status *)orderStatusForKey:(NSString *)orderStatusKey;
{
    Status *status = [_statuses objectForKey:orderStatusKey];
    if (!status) {
        return [Status new];
    }
    return status;
}

- (void)setBadgeNumber:(NSInteger)badgeNumber
{
    _badgeNumber = badgeNumber;
    if (_badgeNumber < 0) {
        _badgeNumber = 0;
    }
    [self setupAppBadgeNumber];
}

- (void)changeBadgeNumberBy:(NSInteger)value
{
    _badgeNumber += value;
    if (_badgeNumber < 0) {
        _badgeNumber = 0;
    }
    [self setupAppBadgeNumber];
}

- (void)setupAppBadgeNumber
{
    UIApplication *application = [UIApplication sharedApplication];
    
    if([DeviceHardware iOS8AndHiger]) {
        if ([self checkNotificationType:UIUserNotificationTypeBadge]) {
            GHLog(@"badge number changed to %ld", (long)_badgeNumber);
            application.applicationIconBadgeNumber = _badgeNumber;
        } else {
            GHLog(@"access denied for UIUserNotificationTypeBadge");
        }
    } else {
        application.applicationIconBadgeNumber = _badgeNumber;
    }
}

#ifdef __IPHONE_8_0
- (BOOL)checkNotificationType:(UIUserNotificationType)type
{
    UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    return (currentSettings.types & type);
}
#endif


@end