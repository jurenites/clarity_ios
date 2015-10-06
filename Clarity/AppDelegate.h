//
//  AppDelegate.h
//  Clarity
//
//  Created by Oleg Kasimov on 9/22/15.
//  Copyright (c) 2015 Spring. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AppDelegateDelegate <NSObject>

@optional
- (void)appWillEnterForeground;
- (void)appDidEnterBackground;
- (void)appWillResignActive;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (AppDelegate *)shared;

- (void)addDelegate:(id<AppDelegateDelegate>)delegate;
- (void)removeDelegate:(id<AppDelegateDelegate>)delegate;

@property (strong, nonatomic) UIWindow *window;


@end

