//
//  TRNApiManager.m
//  TRN
//
//  Created by Oleg Kasimov on 12/4/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "ClarityApiManager.h"
//#import <AdSupport/AdSupport.h>
//#import "SecurityHelper.h"
//#import "User+API.h"
//#import "CreateProfileFields.h"
#import "PLIBlock.h"
#import "NSString+Api.h"
//#import "UserApiFields.h"
//#import "SessionApiFields.h"

#import "ApiRouter_Auth.h"
#import "ApiMethod.h"
//#import "Message.h"
//#import "GlobalEntitiesCtrl.h"
//
//#import "Chat.h"

static ClarityApiManager * volatile Shared = nil;

static NSString *const kServerUrl = @"ServerUrl";

static NSString *const TRNAppVersion = @"TRNAppVersion";

@interface ClarityApiManager ()
{
    NSString *_serverUrl;
}

@end

@implementation ClarityApiManager

#pragma mark -- Shared Instance
+ (ClarityApiManager *)shared
{
    if (!Shared) {
        Shared = [ClarityApiManager new];
    }
    
    return Shared;
}

//- (BOOL)isNewVersionForUserId:(NSInteger)userId
//{
//    NSString *defaultsVersion = [[NSUserDefaults standardUserDefaults] stringForKey:[self versionKeyForId:userId]];
//    if (!defaultsVersion.length) {
//        return YES;
//    }
//    
//    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//    NSComparisonResult result = [defaultsVersion compare:bundleVersion options:(NSLiteralSearch | NSNumericSearch | NSCaseInsensitiveSearch)];
//    
//    return result == NSOrderedAscending;
//}
//
//- (BOOL)isNewVersion
//{
//    NSString *defaultsVersion = [[NSUserDefaults standardUserDefaults] stringForKey:[self versionKeyForId:[GlobalEntitiesCtrl shared].currentUser.userId]];
//    if (!defaultsVersion.length) {
//        return YES;
//    }
//    
//    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//
//    NSComparisonResult result = [defaultsVersion compare:bundleVersion options:(NSLiteralSearch | NSNumericSearch | NSCaseInsensitiveSearch)];
//    
//    return result == NSOrderedAscending;
//}
//
//- (void)updateDefaultsVersion
//{
//    [[NSUserDefaults standardUserDefaults] setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
//                                              forKey:[self versionKeyForId:[GlobalEntitiesCtrl shared].currentUser.userId]];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//- (NSString *)currentAppVersion
//{
//    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//}
//
//- (NSString *)versionKeyForId:(NSInteger)userId
//{
//    NSString *myVersionKey = [NSString stringWithFormat:@"%@_%ld", TRNAppVersion, (long)userId];
//    return myVersionKey;
//}
//
//- (ApiCanceler *)loginWithEmail:(NSString *)email
//                       password:(NSString *)password
//                      onSuccess:(void (^)(User *user))onSuccess
//                        onError:(void (^)(NSError *error))onError
//{
//    NSString *str = [self deviceToken];
//    NSString *encoderInput =  [NSString stringWithFormat:@"%@|%@|%@", email, password, str];
//    NSString *key = [SecurityHelper encryptString:encoderInput];
//    
//    if (!key.length) {
//        onError([InternalError errorWithDescr:@"LOGIN : Security could not generate key for login"]);
//    }
//    
//    IOHTTPRequest *req = [self requestWithMethod:AMLoginViaEmail];
//    [req addParams:@{@"key":key}];
//    req.pipeline = @[[PLITypeCheck PLIIsDictionary]];
//    
//    return [self enqueueApiRequest:req onSuccess:^(NSDictionary *result) {
//        NSString *token = ToString(result[@"session_token"]);
//        User *user = [User fromApiDict:result[@"user"]];
//        if (token.length > 0 && user) {
//            [self.apiRouter userLoggedIn:user withApiToken:token onComplete:^{
//                onSuccess(user);
//            }];
//        } else {
//            onError([InternalError errorWithDescr:@"Invalid token or user"]);
//        }
//    } onError:^(NSError *error) {
//        onError(error);
//    }];
//}
//
//- (ApiCanceler *)autorizationSpecWithEmail:(NSString *)email
//                                  password:(NSString *)password
//                                  authCode:(NSInteger)authCode
//                                       pin:(NSInteger)pin
//                                 onSuccess:(void (^)(User *user))onSuccess
//                                   onError:(void (^)(NSError *error))onError
//{
//    NSString *str = [self deviceToken];
//    NSString *encoderInput =  [NSString stringWithFormat:@"%@|%@|%@", email, password, str];
//    NSString *key = [SecurityHelper encryptString:encoderInput];
//    
//    if (!key.length) {
//        onError([InternalError errorWithDescr:@"LOGIN : Security could not generate key for login"]);
//    }
//    
//    IOHTTPRequest *req = [self requestWithMethod:AMLoginViaEmail];
//    [req addParams:@{@"key":key, @"auth_code" : @(authCode), @"pin" : @(pin)}];
//    req.pipeline = @[[PLITypeCheck PLIIsDictionary]];
//    
//    return [self enqueueApiRequest:req onSuccess:^(NSDictionary *result) {
//        NSString *token = ToString(result[@"session_token"]);
//        User *user = [User fromApiDict:result[@"user"]];
//        if (token.length > 0 && user) {
//            [self.apiRouter userLoggedIn:user withApiToken:token onComplete:^{
//                onSuccess(user);
//            }];
//        } else {
//            onError([InternalError errorWithDescr:@"Invalid token or user"]);
//        }
//    } onError:^(NSError *error) {
//        onError(error);
//    }];
//}
//
//- (ApiCanceler *)forgotPassForEmail:(NSString *)email
//                          onSuccess:(void (^)())onSuccess
//                            onError:(void (^)(NSError *error))onError
//{
//    IOHTTPRequest *req = [self requestWithMethod:AMForgotPassword];
//    [req addParams:@{@"email":email}];
//    return [self enqueueApiRequest:req
//                         onSuccess:onSuccess
//                           onError:onError];
//
//}
//
//- (ApiCanceler *)createUser:(CreateProfileFields *)profileFields
//                  onSuccess:(void (^)(User *user))onSuccess
//                    onError:(void (^)(NSError *error))onError
//{
//    IOHTTPRequest *req = [self requestWithMethod:AMCreateUser];
//    
//    NSDictionary *profileFieldsDictionary = [profileFields toApiDict];
//    [req addParams:profileFieldsDictionary];
//    [req addParams:@{@"device_token" : [self deviceToken]}];
//    req.pipeline = @[[PLITypeCheck PLIIsDictionary]];
//    
//    return [self enqueueApiRequest:req onSuccess:^(NSDictionary *result) {
//        NSString *token = ToString(result[@"session_token"]);
//        NSInteger userId = ToInt(result[@"user_id"]);
//        
//        if (token.length > 0 && userId) {
//            NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithDictionary:@{API_USER_ID : @(userId)}];
//            [userDict addEntriesFromDictionary:profileFieldsDictionary];
//            
//            User *user = [User fromApiDict:userDict];
//            if (user) {
//                [self.apiRouter userLoggedIn:user withApiToken:token onComplete:^{
//                    onSuccess(user);
//                }];
//            } else {
//                onError([InternalError errorWithDescr:@"Could not create user."]);
//            }
//        } else {
//            onError([InternalError errorWithDescr:@"Invalid token or userId"]);
//        }
//    } onError:^(NSError *error) {
//        onError(error);
//    }];
//}
//
//- (ApiCanceler *)logoutOnComplete:(void (^)())onComplete
//{
//    IOHTTPRequest *req = [self requestWithMethod:AMLogout];
//    [req addParams:@{@"device_token":[self deviceToken]}];
//    
//    return [self enqueueApiRequest:req onSuccess:onComplete onError:onComplete];
//}
//
//- (NSString *)deviceToken
//{
//    NSString *vendorId = [[UIDevice currentDevice].identifierForVendor UUIDString];
//    
//#ifdef DEBUG
//    vendorId = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
//#endif
//    
//    return vendorId;
//}
//
//
//- (ApiCanceler *)getStaticPageType:(StaticPageType)pageType
//                         onSuccess:(void (^)(NSString *))onSuccess
//                           onError:(void (^)(NSError *))onError
//{
//    NSString *apiStaticPage = @"";
//    switch (pageType) {
//        case StaticPageTypeMemberFaq:
//            apiStaticPage = @"faq_user";
//            break;
//        case StaticPageTypeSpecialistFaq:
//            apiStaticPage = @"faq_specialist";
//            break;
//        case StaticPageTypeTerms:
//            apiStaticPage = @"terms";
//            break;
//        default:
//            break;
//    }
//    IOHTTPRequest *req = [self requestWithMethod:AMGetStaticPage andUrlParams:@{@"page" : apiStaticPage}];
//       
//    return [self enqueueApiRequest:req onSuccess:^(id result) {
//        onSuccess(ToString(result));
//    } onError:^(NSError *error) {
//        onError(error);
//    }];
//
//}
//
//- (ApiCanceler *)getHomeScreenInfo:(User *)user
//                         onSuccess:(void (^)(Session *session, NSInteger unreadSessions, NSInteger newMessages))onSuccess
//                           onError:(void (^)(NSError *error))onError;
//{
//    if (!user.role.length) {
//        onError(nil);
//    }
//    IOHTTPRequest *req = [self requestWithMethod:AMGetHomeScreenInfo];
//    
//    [req addParams:@{API_SESSION_ROLE : user.role}];
//    req.pipeline = @[[PLITypeCheck PLIIsDictionary]];
//    
//    return [self enqueueApiRequest:req
//                         onSuccess:^(NSDictionary *d){
//                             Session *s = [Session fromApiDict:AssureIsDict(d[@"started_session"])];
//                             if (!s) {
//                                 s = [Session fromApiDict:AssureIsDict(d[@"nearest_session"])];
//                             }
//                             onSuccess(s,
//                                       ToInt(d[@"unread_sessions_quantity"]),
//                                       ToInt(d[@"new_messages_chats_quantity"])); //new_messages_quantity
//                         }
//                           onError:onError];
//}
//
//- (ApiCanceler *)getChatMessages:(NSInteger)chatId
//                        msgClass:(Class)msgClass
//                       onSuccess:(void (^)(NSArray *messages))onSuccess
//                         onError:(void (^)(NSError *error))onError
//{
//    NSInteger me = [GlobalEntitiesCtrl shared].currentUser.userId;
//    IOHTTPRequest *req = [self requestWithMethod:AMGetChatMessages];
//    
//    [req addParams:@{@"chat_id": @(chatId)}];
//    
//    PPLProcessBlock process = ^PipelineResult*(NSArray *inMessages) {
//        NSMutableArray *messages = [NSMutableArray new];
//        
//        for (NSDictionary *d in inMessages) {
//            if ([d isKindOfClass:[NSDictionary class]]) {
//                Message *message = (Message *)[msgClass fromApiDict:d];
//                
//                message.isMy = message.senderId == me;
//                [messages addObject:message];
//            }
//        }
//        
//        return [[PipelineResult alloc] initWithResult:messages];
//    };
//    
//    return [self enqueueApiRequest:req pipeline:@[[PLITypeCheck PLIIsArray], [[PLIBlock alloc] initWithBlock:process]]
//                         onSuccess:onSuccess onError:onError];
//}
//
//- (ApiCanceler *)getChatsOnSuccess:(void(^)(NSArray *chats))onSuccess
//                           onError:(void(^)(NSError *error))onError
//{
//    IOHTTPRequest *req = [self requestWithMethod:AMGetChats];
//    
//    PPLProcessBlock chatsFromArray = ^PipelineResult*(id chats) {
//        NSMutableArray *output_chats = [NSMutableArray new];
//        for (NSUInteger i = 0; i < [chats count]; i++) {
//            NSDictionary *d = [chats objectAtIndex:i];
//            Chat *chat = [Chat fromApiDict:d];
//            if (chat) {
//                [output_chats addObject:chat];
//            }
//        }
//        [output_chats sortUsingComparator:^NSComparisonResult(Chat *obj1, Chat *obj2) {
//            return [obj1.updatedAt compare:obj2.updatedAt] == NSOrderedAscending;
//        }];
//
//        return [[PipelineResult alloc] initWithResult:output_chats];
//    };
//    
//    req.pipeline = @[[PLITypeCheck PLIIsArray], [[PLIBlock alloc] initWithBlock:chatsFromArray]];
//    
//    return [self enqueueApiRequest:req onSuccess:onSuccess onError:onError];
//}
//
//- (ApiCanceler *)getChatById:(NSInteger)chatId
//                   onSuccess:(void(^)(Chat *chat))onSuccess
//                     onError:(void(^)(NSError *error))onError
//{
//    IOHTTPRequest *req = [self requestWithMethod:AMGetChat andUrlParams:@{@"id" : @(chatId)}];
//    req.pipeline = @[[PLITypeCheck PLIIsDictionary]];
//    
//    return [self enqueueApiRequest:req onSuccess:^(NSDictionary *result) {
//        Chat *chat = [Chat fromApiDict:result];
//        onSuccess(chat);
//    } onError:onError];
//}
//
//- (ApiCanceler *)sendMessageWithChatId:(NSInteger)chatId
//                               message:(NSString *)message
//                             onSuccess:(void(^)(NSInteger messageId))onSuccess
//                               onError:(void(^)(NSError *error))onError
//{
//    IOHTTPRequest *req = [self requestWithMethod:AMSendChatMessage];
//    
//    [req addParams:@{@"chat_id": @(chatId), @"message": ToString(message)}];
//    
//    return [self enqueueApiRequest:req pipeline:@[[PLITypeCheck PLIIsDictionary]] onSuccess:^(NSDictionary *result) {
//        onSuccess(ToInt(result[@"id"]));
//    } onError:onError];
//}
//
//
////Promo
//- (ApiCanceler *)createPromoWithCode:(NSString *)code
//                           onSuccess:(void(^)())onSuccess
//                             onError:(void(^)(NSError *error))onError
//{
//    IOHTTPRequest *req = [self requestWithMethod:AMCreatePromo];
//    [req addParam:code name:@"code"];
//    return [self enqueueApiRequest:req
//                         onSuccess:onSuccess
//                           onError:onError];
//}
//
//- (ApiCanceler *)getPromosForUserId:(NSInteger )userId
//                         locationId:(NSInteger)locationId
//                           onSuccess:(void(^)(NSArray *promos))onSuccess
//                             onError:(void(^)(NSError *error))onError
//{
//    IOHTTPRequest *req = [self requestWithMethod:AMGetPromo];
//    
//    NSDictionary *params = @{};
//    if (userId != 0) {
//        params = @{@"user_id" : @(userId)};
//    } else {
//        if (locationId == 0) {
//            #warning REMOVE NIL!
//            return nil;
//        }
//        params = @{@"location_id" : @(locationId)};
//    }
//    [req addParams:params];
//    req.pipeline = @[[PLITypeCheck PLIIsArray]];
//    return [self enqueueApiRequest:req
//                         onSuccess:^(NSArray *promosArray){
//                             NSMutableArray *result = [NSMutableArray new];
//                             for (NSDictionary *d in promosArray) {
//                                 Promo *p = [Promo fromDict:AssureIsDict(d)];
//                                 [result addObject:p];
//                             }
//                             onSuccess(result);
//                         }
//                           onError:onError];
//}


@end
