//
//  VCtrlBaseProtocol.h
//  StaffApp
//
//  Created by Alexey Klyotzin on 6/24/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "YYAppDelegate.h"
#import "AppDelegate.h"
#import "UIView+Utils.h"
#import "ClarityApiManager.h"
//#import "YYApi.h"

@protocol VCtrlBaseProtocol <NSObject>//, AppDelegateDelegate>

- (void)reportError:(NSError *)error;
- (void)reportErrorString:(NSString *)string;
- (void)showNotice:(NSString *)string;

- (void)goBack;
- (void)goBackAfretDelay:(NSTimeInterval)delay;

- (void)triggerReloadContent;

- (void)showSpinner;
- (void)hideSpinner;

//=============Override methods=========================
- (void)appWentOnline;
- (void)appWentOffline;

- (void)appWillEnterForeground;
- (void)appDidEnterBackground;
- (void)appWillResignActive;

- (void)viewWillFirstAppear;
- (void)viewDidFirstLayoutSubviews;

- (ApiCanceler *)baseReloadContent:(void(^)(BOOL hasMoreData, BOOL tryAgain))onComplete;

- (void)keyboardWillShowWithSize:(CGSize)kbdSize duration:(NSTimeInterval)duration curve:(UIViewAnimationOptions)curve;
- (void)keyboardDidShow;
- (void)keyboardWillHideWithDuration:(NSTimeInterval)duration curve:(UIViewAnimationOptions)curve;
//---------------------------------------------

- (void)clearPendingRequest;

//@property (readonly, nonatomic) YYApi *api;
@property (readonly, nonatomic) ClarityApiManager *api;
@property (strong, nonatomic) ApiCanceler *pendingRequest;


@property (readonly, nonatomic) BOOL isOnScreen;
@property (readonly, nonatomic) BOOL inOnline;
@property (readonly, nonatomic) UIViewController<VCtrlBaseProtocol> *parent;
@property (readonly, nonatomic) NSArray *childs;

@end
