//
//  VCtrlNavigation.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 6/26/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "VCtrlNavigation.h"
#import "VCtrlBaseOld.h"
#import "DeviceHardware.h"
#import "NibLoader.h"
//#import "VCtrlDashboard.h"
//#import "VCtrlHelp.h"
//#import "VCtrlSideBar.h"

#import "Clarity-Swift.h"
#import "CustomNavigationBar.h"
typedef enum {
    CurrentActionNone,
    CurrentActionPush,
    CurrentActionPop,
    CurrentActionSetRoot
} CurrentAction;

static VCtrlNavigation *Current = nil;

@interface VCtrlNavigation () <UINavigationControllerDelegate>
{
    CurrentAction _currentAction;
    VCtrlBaseOld *_currentScreen;
    
    UIBarButtonItem *_uiPromoBarButton;
    UIBarButtonItem *_uiInfoBarButton;
    UIBarButtonItem *_uiBackBarButton;
    
    UIBarButtonItem *_uiTimerBarButton;
    UIBarButtonItem *_uiLockBarButton;
    
    NSArray *_promoBarButtons;
    NSArray *_menuBarButtons;
    NSArray *_backBarButtons;
    
    NSArray *_timerBarButtons;
    NSArray *_lockBarButtons;
    
    void(^_pushCompleted)();
    
    BOOL _shouldShowSideMenu;
}
@property (strong, nonatomic) IBOutlet UIImageView *uiLockImg;
@property (strong, nonatomic) IBOutlet UILabel *uiTimerLabel;

@property (strong, nonatomic) IBOutlet UIButton *uiMenuButton;
@property (strong, nonatomic) IBOutlet UIButton *uiPromoButton;
@property (strong, nonatomic) IBOutlet UIButton *uiBackButton;

@property (strong, nonatomic) IBOutlet CustomNavigationBar *navBar;


@property (assign, nonatomic) BOOL canTransit;

@end

@implementation VCtrlNavigation

+ (instancetype)current
{
    return Current;
}

- (instancetype)init
{
    return [[UINib nibWithNibName:@"VCtrlNavigation" bundle:nil] instantiateWithOwner:nil options:nil].firstObject;
}

- (void)willAppear
{
    Current = self;
}
+ (instancetype)createWithRootVC:(VCtrlBaseOld *)vc
{
    VCtrlNavigation *navigation = [VCtrlNavigation new];
    [navigation setViewControllers:@[vc] animated:NO];
    return navigation;
}

- (BOOL)navBarDisabled
{
    return self.navigationBar.userInteractionEnabled;
}

- (void)setNavBarDisabled:(BOOL)navBarDisabled
{
    self.navigationBar.userInteractionEnabled = !navBarDisabled;
}

- (void)viewDidLoad
{
    Current = self;
    [super viewDidLoad];
    self.delegate = self;
    self.canTransit = YES;

    _currentAction = CurrentActionSetRoot;
    
    [self createBarButtonsArray];
}

- (void)createBarButtonsArray
{
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [spacer setWidth:-16];

    _uiBackBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.uiBackButton];
    _backBarButtons = @[spacer, _uiBackBarButton];
    
    _uiInfoBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.uiMenuButton];
    _menuBarButtons = @[spacer, _uiInfoBarButton];
    
    _uiPromoBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.uiPromoButton];
    _promoBarButtons = @[spacer, _uiPromoBarButton];
    
    UIBarButtonItem *timerSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [timerSpacer setWidth: -11];
    
    _uiLockBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.uiLockImg];
    _lockBarButtons = @[timerSpacer, _uiLockBarButton];
    
    _uiTimerBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.uiTimerLabel];
    _timerBarButtons = @[timerSpacer, _uiTimerBarButton];
}

- (void)updateTimerLabel:(NSString *)time
{
    self.uiTimerLabel.text = time;
}

- (void)setRootVCtrl:(UIViewController *)vctrl animated:(BOOL)animated
{
    if (!self.canTransit) {
        return;
    }
    [self setViewControllers:@[vctrl] animated:animated];
}

- (void)setVCtrl:(UIViewController *)vctrl atIndex:(NSInteger)index animated:(BOOL)animated
{
    if (!self.canTransit) {
        return;
    }
    
    NSMutableArray *vctrls = [[self.viewControllers subarrayWithRange:NSMakeRange(0, MAX(MIN(self.viewControllers.count, index), 0))] mutableCopy];
    
    [vctrls addObject:vctrl];
    [self setViewControllers:vctrls animated:animated];
}

- (void)addVCtrl:(UIViewController *)vctrl animated:(BOOL)animated
{
    if (!self.canTransit) {
        return;
    }
    
    NSMutableArray *vctrls = [self.viewControllers mutableCopy];
    
    [vctrls addObject:vctrl];
    [self setViewControllers:vctrls animated:animated];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion
{
    _pushCompleted = completion;
    [self pushViewController:viewController animated:animated];
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated 
{
    if (!self.canTransit) {
        return;
    }

    self.canTransit = NO;
    _currentAction = CurrentActionPush;
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if (self.viewControllers.count < 2) {
        return nil;
    }
    
    if (!self.canTransit) {
        return nil;
    }
    
    self.canTransit = NO;
    
    _currentAction = CurrentActionPop;
   
    return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    if (self.viewControllers.count < 2) {
        return @[];
    }
    
    if (!self.canTransit) {
        return @[];
    }
    
    self.canTransit = NO;
    
    _currentAction = CurrentActionPop;

    return [super popToRootViewControllerAnimated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.canTransit = NO;
    
    BOOL needNavBar = NO;
    if ([viewController respondsToSelector:@selector(needNavBar)]) {
        needNavBar = [(VCtrlBase *)viewController needNavBar];
    }
    [self setNavigationBarHidden:!needNavBar animated:YES];
    
    viewController.navigationItem.hidesBackButton = YES;
//    BOOL needMenu = YES;
//    if ([viewController respondsToSelector:@selector(needMenu)]) {
//        needMenu = [(VCtrlBase *)viewController needMenu];
//        viewController.navigationItem.leftBarButtonItems = needMenu ? _menuBarButtons : nil;
//    }

    if (self.viewControllers.count > 1) {
        BOOL needBackButton = YES;
        if ([viewController respondsToSelector:@selector(needBackButton)]) {
            needBackButton = [(VCtrlBase *)viewController needBackButton];
        }
        viewController.navigationItem.leftBarButtonItems = needBackButton ? _backBarButtons : nil;
    }
    
    NSArray *customButtons = nil;
    if ([viewController isKindOfClass:[VCtrlBase class]]) {
        customButtons = [(VCtrlBase *)viewController needCustomButtons];
    }
    
    if (customButtons) {
        viewController.navigationItem.rightBarButtonItems = customButtons;
        return;
    }
    
    if ([viewController isKindOfClass:[VCtrlBase class]]) {
        if([(VCtrlBase *)viewController needTimer]) {
            viewController.navigationItem.rightBarButtonItems = _timerBarButtons;
        } else if([(VCtrlBase *)viewController needLock]) {
            viewController.navigationItem.rightBarButtonItems = _lockBarButtons;
        }
    }
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (_pushCompleted) {
        _pushCompleted();
        _pushCompleted = nil;
    }
    self.canTransit = YES;
}

- (void)showPromoBtn:(BOOL)animated
{
    [self.topViewController.navigationItem setRightBarButtonItems:_promoBarButtons animated:animated];
}

- (void)hidePromoBtn:(BOOL)animated
{
    [self.topViewController.navigationItem setRightBarButtonItems:nil animated:animated];
}

- (IBAction)goBack
{
//    if ([[VCtrlSideBar current] menuIsOpened] && self.viewControllers.count == 2) {
////        [[VCtrlSideBar current] showMenu];
//        _shouldShowSideMenu = YES;
////        return;
//    }
    
    if([self.topViewController respondsToSelector:@selector(goBack)]) {
        [(VCtrlBase *)self.topViewController goBack];
    } else {
        [self popViewControllerAnimated:YES];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}
@end
