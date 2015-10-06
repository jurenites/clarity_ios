//
//  VCtrlBase.h
//  StaffApp
//
//  Created by Alexey Klyotzin on 6/25/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCtrlBaseProtocol.h"
#import "VCtrlNavigation.h"
#import "NibLoader.h"
#import "MiscUtils.h"
#import "AlertView.h"

typedef void (^BaseOnLoadMoreComplete)(BOOL hasMoreData, BOOL tryAgain);

@interface VCtrlBase : UIViewController <VCtrlBaseProtocol>

+ (CGFloat)statusBarHeight;

- (void)checkPlacehoder;

- (BOOL)isNeedPlaceholder;
- (NSString *)placeholderText;
- (NSAttributedString *)attributedPlaceholderText;
- (CGFloat)placeholderYPos;
- (void)layoutPlaceholderView:(UIView *)view;

- (void)showLoadingOverlay;
- (void)hideLoadingOverlay;

- (BOOL)isTransitionAvailable;

- (void)updateSessionInfo;

- (NSString *)GAITrackName;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (readonly, nonatomic) ClarityApiManager *api;
@property (strong, nonatomic) ApiCanceler *pendingRequest;

@property (strong, nonatomic) AlertView *shownAlertView;

@end
