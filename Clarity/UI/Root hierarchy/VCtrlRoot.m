//
//  VCtrlRoot.m
//  TRN
//
//  Created by stolyarov on 25/11/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "VCtrlRoot.h"
#import "VCtrlSplash.h"
#import "VCtrlNavigation.h"
#import "ApiRouter_Auth.h"

static VCtrlRoot *Current = nil;

@interface VCtrlRoot () <ApiRouterLoginDelegate, ApiRouterDelegate, EventsHubProtocol>
{
    UIViewController *_currentVCtrl;
    VCtrlSplash *_splash;
    
    BOOL _wasFirstAppear;
    
    NSDictionary *_startupPushData;
}
@end

@implementation VCtrlRoot



+ (instancetype)current
{
    return Current;
}

- (instancetype)init
{
    return [super initWithNibName:@"VCtrlRoot" bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [ApiRouter shared].loginDelegate = self;
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    Current = self;
//    _startupPushData = [AGAppDelegate shared].pushAtStart;
    _splash = [VCtrlSplash new];
    
    [self addChildViewController:_splash];
    _splash.view.autoresizesSubviews = YES;
    _splash.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _splash.view.frame = self.view.bounds;
    [self.view addSubview:_splash.view];
    [_splash didMoveToParentViewController:self];
//    [[EventsHub shared] addListener:self];
}

- (void)dealloc
{
//    [[EventsHub shared] removeListener:self];
}

//- (NSArray *)vctrlsForPush:(NSDictionary *)pushData
//{
//    NSString *type = ToString(pushData[@"push_type"]);
//    
//    if ([type isEqualToString:@"chat_new_message"]) {
//        NSInteger chatId = ToInt(pushData[@"chat_id"]);
//        VCtrlChatsList *chatList = [VCtrlChatsList new];
//        VCtrlChat *chat = [[VCtrlChat alloc] initWithChatId:chatId];
//        return @[chatList, chat];
//    } else if ([type isEqualToString:@"session_canceled"]) {
//        if ([GlobalEntitiesCtrl shared].currentUser.isTrainer) {
//            return @[[VCtrlSessionsList new]];
//        } else {
//            return @[[VCtrlFindTrainer new]];
//        }
//    } else if ([type isEqualToString:@"session_booked"]) {
//        if ([GlobalEntitiesCtrl shared].currentUser.isTrainer) {
//            return @[[VCtrlSessionsList new]];
//        }
//    } else if ([type isEqualToString:@"session_upcoming"]) {
//        return @[[[VCtrlSessionInfo alloc] initWithSessionId:ToInt(pushData[@"session_id"])]];
//    } else if ([type isEqualToString:@"session_upcoming_in_day"]) {
//        return @[[[VCtrlSessionInfo alloc] initWithSessionId:ToInt(pushData[@"session_id"])]];
//    } else if ([type isEqualToString:@"not_available_for_session"]) {
//        return @[[VCtrlSettings new]];
//    } else if ([type isEqualToString:@"session_started"]) {
//        return @[[[VCtrlMemberSession alloc] initWithPushInfo:pushData]];
//    } else if ([type isEqualToString:@"session_stopped"]) {
//        return @[[[VCtrlMemberRateSession alloc] initWithPushInfo:pushData]];
//    } else if ([type isEqualToString:@"confirm_pending_location"]) {
//        return @[[VCtrlFindTrainer new]];
//    }
//    
//    return @[];
//}

- (void)showMainUI
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[VCtrlOrders new]];//[VCtrlNavigation createWithRootVC:[VCtrlOrders new]];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.barTintColor = [UIColor colorFromHex:@"#1A5574"];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    [self moveToVctrl:nav animated:YES onComplete:NULL];
//    VCtrlSideBar *sideBar = [VCtrlSideBar new];
//    if (_startupPushData) {
//        NSArray *vctrlsForPush = [self vctrlsForPush:_startupPushData];
//        _startupPushData = nil;
//        
//        [sideBar setVCtrlsForPush:vctrlsForPush];
//    }
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
//                                                animated:YES];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    [self moveToVctrl:sideBar animated:YES onComplete:^{}];
}

- (void)showLoginUI
{
    [self moveToVctrl:[VCtrlLogin new] animated:YES onComplete:NULL];
//    [AquaManager logout];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    [self moveToVctrl:[VCtrlNavigation createWithRootVC:[VCtrlLogin new]]
//                              animated:YES
//                            onComplete:NULL];
}

//- (void)showTutorialUI
//{
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    [self moveToVctrl:[VCtrlNavigation createWithRootVC:[VCtrlTutorial new]]
//             animated:YES
//           onComplete:NULL];
//}
//
//- (void)showAnonymousUIIfNeed
//{
//    if ([GlobalEntitiesCtrl shared].currentUser.isTrainer) { //Cpecialist already has filled profile.
//        [self showMainUI];
//        return;
//    }
//    
//    if (![GlobalEntitiesCtrl shared].currentUser.isAnonymous) {
//        if ([GlobalEntitiesCtrl shared].currentUserHasSessions) {
//            [self showMainUI];
//        } else {
//            [self showLoadingOverlay];
//            [[GlobalEntitiesCtrl shared] updateSessionsOnSuccess:^(NSArray *completed, NSArray *booked, Session *started) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self hideLoadingOverlay];
//                    if (completed.count > 0 || booked.count > 0 || started) {
//                        [self showMainUI];
//                    } else {
//                        [self showAnonymousUI];
//                    }
//                });
//            } onError:^(NSError *error) {
//                [self hideLoadingOverlay];
//                [self reportError:error];
//                [self showTutorialUI];
//            }];
//        }
//    } else {
//        [self showAnonymousUI];
//    }
//}
//
//- (void)showAnonymousUI
//{
//    VCtrlSideBar *sideBar = [VCtrlSideBar new];
//    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
//                                                animated:YES];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    [self moveToVctrl:sideBar animated:YES onComplete:^{}];
//    VCtrlSideBar *sideB = (VCtrlSideBar *)_currentVCtrl;
//    [sideB setVCtrlsForPush:@[[VCtrlFindTrainer new]]];
//}
//
//- (void)showActiveSession:(Session *)session
//{
//    if (![[GlobalEntitiesCtrl shared].currentUser isTrainer]) {
//        VCtrlSideBar *sideBar = (VCtrlSideBar *)_currentVCtrl;
//        
//        if (sideBar == nil) {
//            return;
//        }
//
//        VCtrlMemberSession *ms = [[VCtrlMemberSession alloc] initWithSession:session];
//        [sideBar setVCtrlsForPush:@[ms]];
//    } else {
//        [self showMainUI];
//    }
//}
//
//- (void)showRateSession:(Session *)session
//{
//    if (![[GlobalEntitiesCtrl shared].currentUser isTrainer]) {
//        VCtrlSideBar *sideBar = (VCtrlSideBar *)_currentVCtrl;
//        
//        if (sideBar == nil) {
//            return;
//        }
//
//        VCtrlMemberRateSession *rs = [VCtrlMemberRateSession new];
//        [rs setSession:session];
//        [sideBar setVCtrlsForPush:@[rs]];
//    } else {
//        [self showMainUI];
//    }
//}
//
//- (void)setStartupPushData:(NSDictionary *)pushData
//{
//    _startupPushData = pushData;
//}
//
//- (void)processPush:(NSDictionary *)pushData
//{
//    VCtrlSideBar *sideBar = (VCtrlSideBar *)_currentVCtrl;
//    
//    if (sideBar == nil) {
//        return;
//    }
//    
//    if ([[pushData objectForKey:@"origin"] isEqualToString:@"helpshift"]) {
//        [sideBar showMenuWithHelpshiftData:pushData];
//        return;
//    }
//    
//    NSArray *vctrlsForPush = [self vctrlsForPush:pushData];
//    [sideBar setVCtrlsForPush:vctrlsForPush];
//}

- (void)startup
{
    DispatchAfter(0.5, ^{
        if (_splash) {
            BOOL loaded = [[GlobalEntitiesCtrl shared] loadFromDefaults];
            if ([ApiRouter shared].isLoggedIn) {
                [self showMainUI];
//                [[TRNApi shared] loadInitialData:[ApiRouter shared].currentUserId onSuccess:^{
//                    [self showAnonymousUIIfNeed];
//                } onError:^(NSError *error) {
//                    if (error.code == 50000 || error.code == 1002) {
//                        [self reportError:error];
//                    }
//                    [self showTutorialUI];
//                }];
            } else {
                [self showLoginUI];
//                [[TRNApi shared] loadAnonymousInitialData:^{
//                    User *u = [GlobalEntitiesCtrl shared].currentUser;
//                    
//                    if (loaded && u.isAnonymous && u.locationId != 0) {
//                        [self showAnonymousUIIfNeed];
//                    } else {
//                        [self showTutorialUI];
//                    }
//                } onError:^(NSError * error) {
//                    if (error.code == 50000 || error.code == 1002) {
//                        [self reportError:error];
//                    }
//                    [self showTutorialUI];
//                }];
            }
        }
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_wasFirstAppear) {
        [self startup];
    }
    _wasFirstAppear = YES;
}

- (void)moveToVctrl:(UIViewController *)vctrl animated:(BOOL)animated onComplete:(void(^)())onComplete
{
    [self addChildViewController:vctrl];
    vctrl.view.autoresizesSubviews = YES;
    vctrl.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    vctrl.view.frame = self.view.bounds;
    
    UIViewController *disappearingVC = _currentVCtrl ? _currentVCtrl : _splash;
    [self.view insertSubview:vctrl.view belowSubview:disappearingVC.view];
    
    [disappearingVC willMoveToParentViewController:nil];
    _currentVCtrl = vctrl;
    
    if (animated) {
        [UIView animateWithDuration:0.33f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             disappearingVC.view.alpha = 0;
                             [self setNeedsStatusBarAppearanceUpdate];
                         }
                         completion:^(BOOL finished) {
                             disappearingVC.view.alpha = 1;
                             [disappearingVC.view removeFromSuperview];
                             [disappearingVC removeFromParentViewController];
                             [vctrl didMoveToParentViewController:self];
                             if (onComplete) {
                                 onComplete();
                             }
                         }
         ];
    } else {
        disappearingVC.view.alpha = 1;
        [disappearingVC.view removeFromSuperview];
        [disappearingVC removeFromParentViewController];
        [vctrl didMoveToParentViewController:self];
        if (onComplete) {
            dispatch_async(dispatch_get_main_queue(), onComplete);
        }
    }
}

#pragma mark ApiRouterDelegate

- (void)apiRouterPrepareForLogout:(ApiRouter *)apiRouter onComplete:(void (^)())onComplete
{
    dispatch_async(dispatch_get_main_queue(), onComplete);
}

- (void)apiRouterLogoutComplete:(ApiRouter *)apiRouter
{
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault
//                                                animated:YES];
    [self showLoginUI];
}

- (BOOL)needTrackGAI
{
    return NO;
}

@end
