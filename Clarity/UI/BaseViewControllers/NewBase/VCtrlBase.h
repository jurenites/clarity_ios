//
//  VCtrlBase.h
//  StaffApp
//
//  Created by Alexey Klyotzin on 6/25/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <HealthKit/HealthKit.h>
#import "VCtrlBaseProtocol.h"
#import "NibLoader.h"
#import "AlertView.h"
#import "UIFont+Utils.h"
//#import "Settings.h"
//#import "HealthKitAccess.h"
#import "PtrScrollProtocol.h"

typedef void (^BaseOnLoadMoreComplete)(BOOL hasMoreData, BOOL tryAgain);

@interface VCtrlBase : UIViewController <VCtrlBaseProtocol>

//+ (void)trackScreenWithName:(NSString *)name;

//- (void)setBadgeNumber:(NSInteger)badgeNumber;

- (void)checkPlacehoder;
- (void)configurePtr;

- (BOOL)isNeedPlaceholder;
- (NSString *)placeholderText;
- (NSAttributedString *)attributedPlaceholderText;
- (CGFloat)placeholderYPos;
- (void)layoutPlaceholderView:(UIView *)view;

- (void)showLoadingOverlay;
- (void)hideLoadingOverlay;

- (BOOL)isTransitionAvailable;

- (void)goBackPages:(NSInteger)pages;
//- (void)showTopNotice:(NSString *)notice withColor:(UIColor *)color;

//- (void)checkHealthKitAccess;
//- (NSArray *)hkReadDataTypes;
//- (NSArray *)hkWriteDataTypes;

- (void)configureBarButton:(UIBarButtonItem *)barButton;
- (void)configureBackButton;
- (void)configureBackButtonWithTitle:(NSString *)title;

//- (BOOL)needCompanyLogo;

- (BOOL)isNeedPullToRefresh;
- (BOOL)isNeedInfiniteScroll;

//- (void)willAppearInTabBar;

- (ApiCanceler *)ptrReloadContent:(BaseOnLoadMoreComplete)onComplete;
- (ApiCanceler *)ptrLoadMoreContent:(BaseOnLoadMoreComplete)onComplete;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIScrollView<PtrScrollProtocol> *ptrScrollView;

@property (assign, nonatomic) BOOL pullToRefreshEnabled;
@property (assign, nonatomic) BOOL infiniteScrollEnabled;
@property (assign, nonatomic) BOOL isNeedAvatarButton;

@property (strong, nonatomic) NSString *trackScreenName;

//@property (readonly, nonatomic) YYApi *api;
@property (readonly, nonatomic) ClarityApiManager *api;
@property (strong, nonatomic) ApiCanceler *pendingRequest;
@property (strong, nonatomic) AlertView *shownAlertView;

//@property (strong, nonatomic) HKHealthStore *hkStore;
//@property (strong, nonatomic) HealthKitAccess *healthKit;


@end
