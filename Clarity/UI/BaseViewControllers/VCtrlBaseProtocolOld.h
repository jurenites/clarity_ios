//
//  VCtrlBaseProtocol.h
//  StaffApp
//
//  Created by Alexey Klyotzin on 6/24/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "UIView+Utils.h"
#import "ClarityApiManager.h"

@protocol VCtrlBaseProtocolOld <NSObject>

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
- (BOOL)needNavBar;
- (BOOL)needBackButton;
- (BOOL)needTimer;
- (BOOL)needLock;

//GAI
- (BOOL)needTrackGAI;

- (NSArray *)needCustomButtons;
- (ApiCanceler *)baseReloadContent:(void(^)(BOOL hasMoreData, BOOL tryAgain))onComplete;


- (void)keyboardWillShowWithSize:(CGSize)kbdSize duration:(NSTimeInterval)duration curve:(UIViewAnimationOptions)curve;
- (void)keyboardDidShow;
- (void)keyboardWillHideWithDuration:(NSTimeInterval)duration curve:(UIViewAnimationOptions)curve;
//---------------------------------------------

- (void)clearPendingRequest;

@property (readonly, nonatomic) ClarityApiManager *api;
@property (strong, nonatomic) ApiCanceler *pendingRequest;


@property (readonly, nonatomic) BOOL isOnScreen;
@property (readonly, nonatomic) BOOL inOnline;
@property (readonly, nonatomic) UIViewController<VCtrlBaseProtocol> *parent;
@property (readonly, nonatomic) NSArray *childs;

@end
