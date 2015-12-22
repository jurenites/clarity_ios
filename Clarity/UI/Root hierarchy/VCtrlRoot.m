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
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[VCtrlOrders new]];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.barTintColor = [UIColor colorFromHex:@"#1A5574"];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    [self moveToVctrl:nav animated:YES onComplete:NULL];
}

- (void)showLoginUI
{
    [self moveToVctrl:[VCtrlLogin new] animated:YES onComplete:NULL];
}

- (void)showChatFromPush:(NSInteger)chatId
{
    if (_currentVCtrl.class == [UINavigationController class] && _currentVCtrl.navigationController.viewControllers.lastObject.class != [VCtrlChat class]) {
        NSArray *navStack = @[[VCtrlOrders new], [[VCtrlOrderDetails alloc] initWithOrderId:chatId], [[VCtrlChat alloc] initWithOrderId:chatId]];
        [(UINavigationController *)_currentVCtrl setViewControllers:navStack animated:YES];
    }
}

- (void)processPush:(NSDictionary *)pushInfo active:(BOOL)isActive
{
    NSInteger orderId = ToInt(pushInfo[@"order_id"]);
    NSString *type = ToString(pushInfo[@"type"]);
    
    if (_currentVCtrl.class != [UINavigationController class]) {
        return;
    }
    
    if ([type isEqualToString:PushMessageNew] || [type isEqualToString:PushMessageUpdate] || [type isEqualToString:PushMessageRemove]) {
        [[GlobalEntitiesCtrl shared] setBadgeNumber:ToInt(pushInfo[@"unread_messages_count"])];
        if (isActive) {
            NSInteger messageId = ToInt(pushInfo[@"message_id"]);
            [[EventsHub shared] chatUpdated:orderId messageId:messageId action:type];
        } else {
            if ([type isEqualToString:PushMessageNew]) {
                [[GlobalEntitiesCtrl shared] changeBadgeNumberBy:-1];
            }
            NSArray *navStack = @[[VCtrlOrders new], [[VCtrlOrderDetails alloc] initWithOrderId:orderId], [[VCtrlChat alloc] initWithOrderId:orderId]];
            [(UINavigationController *)_currentVCtrl setViewControllers:navStack animated:NO];
        }
    } else if ([type isEqualToString:PushOrderNew] || [type isEqualToString:PushOrderUpdate] || [type isEqualToString:PushOrderRemove]) {
        if (isActive) {
            [[EventsHub shared] orderUpdated:orderId action:type];
        } else {
            NSArray *navStack = @[[VCtrlOrders new]];
            if (![type isEqualToString:PushOrderRemove]) {
                navStack = @[[VCtrlOrders new], [[VCtrlOrderDetails alloc] initWithOrderId:orderId]];
            }
            [(UINavigationController *)_currentVCtrl setViewControllers:navStack animated:NO];
        }
    }
}

- (void)startup
{
    DispatchAfter(0.5, ^{
        if (_splash) {
            if ([ApiRouter shared].isLoggedIn) {
                [[GlobalEntitiesCtrl shared] loadFromDefaults];
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
