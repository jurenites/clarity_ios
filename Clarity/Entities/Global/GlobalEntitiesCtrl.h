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

@interface GlobalEntitiesCtrl : NSObject

+ (GlobalEntitiesCtrl *)shared;

- (BOOL)loadFromDefaults;

- (void)fillCurrentUserWithDict:(NSDictionary *)dict;
- (void)silentUpdateCurrentUserWithUser:(User *)user;//Will not notify event
- (void)updateCurrentUserWithUser:(User *)user;

- (void)fillCommonInfo:(NSDictionary *)commonInfo;
- (NSString *)orderFilterForKey:(NSString *)filterKey;

- (void)fillOrderStatuses:(NSDictionary *)orderStatuses;
- (NSString *)orderStatusForKey:(NSString *)orderStatusKey;
//- (void)updateUserLocation:(NSInteger)newLocationId;
//- (void)setLocations:(NSArray *)locations;
//- (void)addLocation:(TRNLocation *)location;
//- (void)setRegions:(NSArray *)regions;
//
//- (void)setSessionCount:(NSInteger)sessionCount;
//- (void)setMessageCount:(NSInteger)messageCount;
//
//- (void)updateCountersOnComplete:(void(^)())onComplete;
//
//- (void)updateAppBadgeWithUnreadSessions:(NSInteger)sessionsCount
//                             newMessages:(NSInteger)messagesCount;
//
//- (void)setTrainerAvailability:(BOOL)availability;
//
//- (Region *)regionForLocationId:(NSInteger)locationId;
//- (Region *)regionById:(NSInteger)regionId;
//
//- (TRNLocation *)locationById:(NSInteger)locationId;
//
////Onboarding
//- (OnboardingProgress)onboardingProgressForUser;//:(User *)user;
//
////Sessions
//- (void)immidiatelyProcessSession:(Session *)session;
//- (void)updateSessionsOnSuccess:(SessionsUpdated)onSuccess
//                        onError:(SessionsError)onError;
//- (void)updateSessions;
//
//- (void)checkSessionByPushInfo:(NSDictionary *)pushInfo
//                 openingScreen:(BOOL)openingScreen
//                     onSuccess:(void (^)(Session *session))onSuccess
//                       onError:(void (^)(NSError *error))onError;
//
//- (void)stopTrackingSession;
//- (void)didRateSession:(Session *)session;
//
////Anonymous
//- (void)addAnonymousPromo:(Promo *)promo;
//- (NSArray *)savedAnonymousPromos;
//- (void)cleanAnonymousPromos;

@property (readonly, nonatomic) User *currentUser;
@property (readonly, nonatomic) NSArray *orderFilters;
//@property (readonly, nonatomic) NSArray *regions;
//@property (readonly, nonatomic) NSTimeZone *myTimeZone;
//
//@property (readonly, nonatomic) NSInteger messageCount;
//@property (readonly, nonatomic) NSInteger sessionCount;
//@property (readonly, nonatomic) NSInteger helpshiftCount;
//
////Sessions
//@property (readonly, nonatomic) NSArray *bookedSessions;
//@property (readonly, nonatomic) NSArray *completedSessions;
//@property (readonly, nonatomic) NSArray *canceledSessions;
//@property (readonly, nonatomic) NSArray *notRatedSessions;
//@property (readonly, nonatomic) Session *scheduledSession;

//@property (readonly, nonatomic) BOOL currentUserHasSessions;

@end
