//
//  GlobalEntitiesCtrl.h
//  TRN
//
//  Created by Oleg Kasimov on 12/2/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GlobalEntitiesCtrl;
@class User;
@class Status;

static NSString * const PushMessageNew      = @"NewNotice";
static NSString * const PushMessageUpdate   = @"UpdateNotice";
static NSString * const PushMessageRemove   = @"RemoveNotice";

static NSString * const PushOrderNew        = @"NewOrder";
static NSString * const PushOrderUpdate     = @"UpdateOrder";
static NSString * const PushOrderRemove     = @"RemoveOrder";

@interface GlobalEntitiesCtrl : NSObject

+ (GlobalEntitiesCtrl *)shared;

- (BOOL)loadFromDefaults;

- (void)fillCurrentUserWithDict:(NSDictionary *)dict;
- (void)silentUpdateCurrentUserWithUser:(User *)user;//Will not notify event
- (void)updateCurrentUserWithUser:(User *)user;
- (BOOL)isMyId:(NSInteger)userId;

- (void)fillFilters:(NSDictionary *)filters;
- (NSString *)orderFilterForKey:(NSString *)filterKey;

- (void)fillOrderStatuses:(NSArray *)orderStatuses;
- (Status *)orderStatusForKey:(NSString *)orderStatusKey;

- (void)setBadgeNumber:(NSInteger)badgeNumber;
- (void)changeBadgeNumberBy:(NSInteger)value;

@property (readonly, nonatomic) User *currentUser;
@property (readonly, nonatomic) NSArray *orderFilters;
@property (readonly, nonatomic) NSInteger badgeNumber;

@end
