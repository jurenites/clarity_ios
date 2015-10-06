//
//  AppDelegate.m
//  Clarity
//
//  Created by Oleg Kasimov on 9/22/15.
//  Copyright (c) 2015 Spring. All rights reserved.
//

#import "AppDelegate.h"
#import "DelegatesHolder.h"

@interface AppDelegate ()
{
    DelegatesHolder *_delegates;
}

@end

@implementation AppDelegate


+ (AppDelegate *)shared
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[ApiRouter shared] startup];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [VCtrlRoot new];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    for (id<AppDelegateDelegate> d in [_delegates getDelegates]) {
        if ([d respondsToSelector:@selector(appWillResignActive)]) {
            [d appWillResignActive];
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    for (id<AppDelegateDelegate> d in [_delegates getDelegates]) {
        if ([d respondsToSelector:@selector(appDidEnterBackground)]) {
            [d appDidEnterBackground];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    for (id<AppDelegateDelegate> d in [_delegates getDelegates]) {
        if ([d respondsToSelector:@selector(appWillEnterForeground)]) {
            [d appWillEnterForeground];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Delefate
- (void)addDelegate:(id<AppDelegateDelegate>)delegate
{
    if(_delegates == nil) {
        _delegates = [DelegatesHolder new];
    }
    [_delegates addDelegate:delegate];
}

- (void)removeDelegate:(id<AppDelegateDelegate>)delegate
{
    [_delegates removeDelegate:delegate];
}

@end
