//
//  TRNApiManager.h
//  TRN
//
//  Created by Oleg Kasimov on 12/4/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "ApiManager.h"
//#import "GlobalEntitiesCtrl.h"
#import "PLITypeCheck.h"
//#import "Session+API.h"

typedef enum : NSInteger {
    StaticPageTypeSpecialistFaq,
    StaticPageTypeMemberFaq,
    StaticPageTypeTerms
} StaticPageType;

//@class CreateProfileFields, ApiMethod, Chat;

@interface ClarityApiManager : ApiManager

+ (ClarityApiManager *)shared;

//- (BOOL)isNewVersion;
//- (BOOL)isNewVersionForUserId:(NSInteger)userId;
//- (void)updateDefaultsVersion;
//- (NSString *)currentAppVersion;
//
//- (NSString *)deviceToken;
//
//- (ApiCanceler *)loginWithEmail:(NSString *)email
//                       password:(NSString *)password
//                      onSuccess:(void (^)(User *user))onSuccess
//                        onError:(void (^)(NSError *error))onError;
//
//- (ApiCanceler *)forgotPassForEmail:(NSString *)email
//                          onSuccess:(void (^)())onSuccess
//                            onError:(void (^)(NSError *error))onError;
//
//- (ApiCanceler *)createUser:(CreateProfileFields *)profileFields
//                  onSuccess:(void (^)(User *user))onSuccess
//                    onError:(void (^)(NSError *error))onError;
//
//- (ApiCanceler *)logoutOnComplete:(void (^)())onComplete;
//
//- (ApiCanceler *)autorizationSpecWithEmail:(NSString *)email
//                                  password:(NSString *)password
//                                  authCode:(NSInteger)authCode
//                                       pin:(NSInteger)pin
//                                 onSuccess:(void (^)(User *user))onSuccess
//                                   onError:(void (^)(NSError *error))onError;
//
////Static Pages
//- (ApiCanceler *)getStaticPageType:(StaticPageType)pageType
//                         onSuccess:(void (^)(NSString *htmlString))onSuccess
//                           onError:(void (^)(NSError *error))onError;
//
////Home Screen
//- (ApiCanceler *)getHomeScreenInfo:(User *)user
//                         onSuccess:(void (^)(Session *session, NSInteger unreadSessions, NSInteger newMessages))onSuccess
//                           onError:(void (^)(NSError *error))onError;
//
//
//- (ApiCanceler *)getChatsOnSuccess:(void(^)(NSArray *chats))onSuccess
//                           onError:(void(^)(NSError *error))onError;
//
//- (ApiCanceler *)getChatById:(NSInteger)chatId
//                   onSuccess:(void(^)(Chat *chat))onSuccess
//                     onError:(void(^)(NSError *error))onError;
//
//- (ApiCanceler *)getChatMessages:(NSInteger)chatId
//                        msgClass:(Class)msgClass
//                       onSuccess:(void (^)(NSArray *messages))onSuccess
//                         onError:(void (^)(NSError *error))onError;
//
//- (ApiCanceler *)sendMessageWithChatId:(NSInteger)chatId
//                               message:(NSString *)message
//                             onSuccess:(void(^)(NSInteger messageId))onSuccess
//                               onError:(void(^)(NSError *error))onError;
////Promo
//- (ApiCanceler *)createPromoWithCode:(NSString *)code
//                           onSuccess:(void(^)())onSuccess
//                             onError:(void(^)(NSError *error))onError;
//
//- (ApiCanceler *)getPromosForUserId:(NSInteger)userId
//                         locationId:(NSInteger)locationId
//                          onSuccess:(void(^)(NSArray *promos))onSuccess
//                            onError:(void(^)(NSError *error))onError;
@end

