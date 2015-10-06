//
//  ApiRouter_Auth.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/3/14.
//
//

#import "ApiRouter.h"

@class User;

@interface ApiRouter ()

- (void)userLoggedIn:(User *)user
        withApiToken:(NSString *)apiToken
          onComplete:(void(^)())onComplete;

- (void)invalidateLogin;
- (void)logout;

- (void)updateCurrentUser:(User *)user;

@end
