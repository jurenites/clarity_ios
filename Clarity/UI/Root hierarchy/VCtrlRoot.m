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
    
    Current = self;
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

- (void)showMainUI
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[VCtrlOrders new]];// [VCtrlTestTable new]];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.barTintColor = [UIColor colorFromHex:@"#1A5574"];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    [self moveToVctrl:nav animated:YES onComplete:NULL];
}

- (void)showLoginUI
{
    [self moveToVctrl:[VCtrlLogin new] animated:YES onComplete:NULL];
}

- (void)startup
{
    DispatchAfter(0.5, ^{
        if (_splash) {
            if ([ApiRouter shared].isLoggedIn) {
                [[ClarityApi shared] loadCommonInfo:^{
                    [self showMainUI];
                } onError:^(NSError *error) {
                    if (error.code != ApiErrorSessionTokenExpired) {
                        [self reportError:error];
                    }
                    [self showLoginUI];
                }];
            } else {
                [self showLoginUI];
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
    [self showLoginUI];
}

- (BOOL)needTrackGAI
{
    return NO;
}

@end
