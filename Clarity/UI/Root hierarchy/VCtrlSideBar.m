//
//  VCtrlSideBar.m
//  TRN
//
//  Created by stolyarov on 31/03/2015.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import "VCtrlSideBar.h"
#import "VCtrlMenu.h"
#import "VCtrlNavigation.h"
#import "VCtrlDashboard.h"
#import "VCtrlFindTrainer.h"
#import "Helpshift.h"

static const CGFloat kAnimateDuration = 0.33;

static VCtrlSideBar *Current = nil;

@interface VCtrlSideBar () <VCtrlMenuDelegate>
{
    VCtrlMenu *_sideMenu;
    VCtrlNavigation *_content;
    
    BOOL _isPushed;
    BOOL _isOpened;
}
@property (strong, nonatomic) IBOutlet UIView *uiContainer;
@property (strong, nonatomic) IBOutlet UIView *uiContentContainer;
@property (strong, nonatomic) IBOutlet UIView *uiMenuContainer;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lcMenuCenterX;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *lcContentCenterX;
@end

@implementation VCtrlSideBar

+ (instancetype)current
{
    return Current;
}

- (instancetype)init
{
    return [self initWithNibName:@"VCtrlSideBar" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    Current = self;
    
    _sideMenu = [VCtrlMenu new];
    _sideMenu.delegate = self;
    
    [self addVCtrl:_sideMenu intoView:self.uiMenuContainer atIndex:0];
    
    _content = [VCtrlNavigation createWithRootVC:[VCtrlDashboard new]];
    [self addVCtrl:_content intoView:self.uiContentContainer atIndex:0];
    
    [AquaManager setDeepLinker:^(NSString *localLink) {
        NSLog(@"AquaSDK reports: tracked local link \"%@\"", localLink);
        
        User *currentUser = [GlobalEntitiesCtrl shared].currentUser;
        BOOL menuIsOpened = [self menuIsOpened];
        BOOL userIsTrainer = [currentUser isTrainer];
        UIViewController *topVC = _content.topViewController;
        
        // Check if menu is opened
        if (menuIsOpened) {
            // Check if trainer and appropriate link is sended
            if (userIsTrainer && [localLink isEqualToString:TRNScreenSpecialistAddAvailBlock]) {
                // If we are on list of blocks, just push schedule block
                if ([topVC isKindOfClass:[VCtrlSched class]]) {
                    [(VCtrlSched *)topVC actAddBlock];
                } else if (![topVC isKindOfClass:[VCtrlScheduleBlock class]]) {
                    // Else push 2 VCs to open schedule block
                    VCtrlSched *sched = [[VCtrlSched alloc] initWithUser:currentUser];
                    [self setVctrl:sched];
                    [sched actAddBlock];
                }
            } else if ([localLink isEqualToString:TRNScreenMemberFindASpecialist]) {
                // Check if we are not already on this screen
                if (![topVC isKindOfClass:[VCtrlFindTrainer class]]) {
                    [self openVctrl:[VCtrlFindTrainer new]];
                }
            }
        } else {
            if (userIsTrainer && [localLink isEqualToString:TRNScreenSpecialistAddAvailBlock]) {
                if ([topVC isKindOfClass:[VCtrlSched class]]) {
                    [(VCtrlSched *)topVC actAddBlock];
                } else if (![topVC isKindOfClass:[VCtrlScheduleBlock class]]) {
                    VCtrlSched *sched = [[VCtrlSched alloc] initWithUser:currentUser];
                    [_content addVCtrl:sched animated:NO];
                    [sched actAddBlock];
                }
            } else if ([localLink isEqualToString:TRNScreenMemberFindASpecialist]) {
                if (![topVC isKindOfClass:[VCtrlFindTrainer class]]) {
                    [_content pushViewController:[VCtrlFindTrainer new] animated:YES];
                }
            }
        }
    }];
}

- (void)addVCtrl:(UIViewController *)vctrl intoView:(UIView *)view atIndex:(NSInteger)index
{
    vctrl.view.autoresizesSubviews = YES;
    vctrl.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    vctrl.view.frame = view.bounds;
    
    [self addChildViewController:vctrl];
    [view insertSubview:vctrl.view atIndex:index];
    [vctrl didMoveToParentViewController:self];
}

- (void)setVCtrlsForPush:(NSArray *)vctrls
{
    if (vctrls.count > 0) {
        if ([vctrls.firstObject isKindOfClass:[VCtrlSettings class]]
            && [_content.topViewController isKindOfClass:[VCtrlSettings class]]) {
            return;
        }
        NSMutableArray *curVctrls = [_content.viewControllers mutableCopy];
        [curVctrls addObjectsFromArray:vctrls];
        _content.viewControllers = curVctrls;
    }
    if (_isPushed && _isOpened) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        self.lcContentCenterX.constant = 0;
        self.lcMenuCenterX.constant = self.view.width/3.0;
        _isOpened = NO;
        [self.view layoutIfNeeded];
    } else if (vctrls.count == 0) {
        [_content popToRootViewControllerAnimated:YES];
    }
}

- (BOOL)menuIsOpened
{
    return _isPushed;
}

- (void)pushMenu
{
    [self pushMenuAnimated:YES];
}

- (void)popMenuAnimated:(BOOL)animated;
{
    if (!_isPushed) {
        return;
    }
    _isPushed = NO;
    _isOpened = NO;
    
    [self.uiContentContainer endEditing:YES];
    [self.uiContainer bringSubviewToFront:self.uiMenuContainer];
    
    self.uiContentContainer.hidden = NO;
    
    if (animated) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        self.lcContentCenterX.constant = -self.view.width/3.0;
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:kAnimateDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.lcContentCenterX.constant = 0;
                             self.lcMenuCenterX.constant = self.view.width;
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL completed){
                         }];
    } else {
        self.lcContentCenterX.constant = 0;
        self.lcMenuCenterX.constant = self.view.width;
        [self.view layoutIfNeeded];
    }
}

- (void)setVctrl:(VCtrlBase *)vctrl
{
    if (!_isOpened) {
        return;
    }
    _isOpened = NO;
    [self.uiContentContainer endEditing:YES];
    self.lcContentCenterX.constant = -self.view.width;
    [self.view layoutIfNeeded];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [_content addVCtrl:vctrl animated:NO];
    [_content.view layoutIfNeeded];
    [UIView animateWithDuration:kAnimateDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.lcContentCenterX.constant = 0;
                         self.lcMenuCenterX.constant = self.view.width/3.0;
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL completed){
                     }];
}

- (void)openVctrl:(VCtrlBase *)vctrl
{
    if (!_isOpened) {
        return;
    }
    _isOpened = NO;
    [self.uiContentContainer endEditing:YES];
    self.lcContentCenterX.constant = -self.view.width;
    [self.view layoutIfNeeded];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [_content pushViewController:vctrl
                        animated:NO
                      completion:^(){
                          [_content.view layoutIfNeeded];
                          [UIView animateWithDuration:kAnimateDuration
                                                delay:0
                                              options:UIViewAnimationOptionCurveEaseInOut
                                           animations:^{
                                               self.lcContentCenterX.constant = 0;
                                               self.lcMenuCenterX.constant = self.view.width/3.0;
                                               [self.view layoutIfNeeded];
                                           } completion:^(BOOL completed){
                                           }];
                      }];
}

- (void)showMenu
{
    [self showMenuAnimated:YES];
}

- (void)pushMenuAnimated:(BOOL)animated
{
    if (_isPushed) {
        return;
    }
    _isPushed = YES;
    _isOpened = YES;
    [self.uiContentContainer endEditing:YES];
    
    self.lcMenuCenterX.constant = self.view.width;
    self.uiMenuContainer.hidden = NO;
    [self.view layoutIfNeeded];
    
    [_sideMenu updateContent];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    if (animated) {
        [UIView animateWithDuration:kAnimateDuration delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.lcContentCenterX.constant = -self.view.width/3.0;
                             self.lcMenuCenterX.constant = 0;
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL completed){
                             self.lcContentCenterX.constant = -2*self.view.width;
                             
                             [self.view layoutIfNeeded];
                             
                             self.uiContentContainer.hidden = YES;
                             [self.uiContainer bringSubviewToFront:self.uiContentContainer];
                             self.uiContentContainer.hidden = NO;
                         }];
    } else {
        self.lcMenuCenterX.constant = 0;
        self.lcContentCenterX.constant = -2*self.view.width;
        [self.view layoutIfNeeded];
        
        self.uiContentContainer.hidden = YES;
        [self.uiContainer bringSubviewToFront:self.uiContentContainer];
        self.uiContentContainer.hidden = NO;
    }
}

- (void)showMenuAnimated:(BOOL)animated
{
    if (_isOpened) {
        return;
    }
    _isOpened = YES;
    [self.uiContentContainer endEditing:YES];
    
    [_sideMenu updateContent];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    if (animated) {
        [UIView animateWithDuration:kAnimateDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.lcContentCenterX.constant = -self.view.width;
                             self.lcMenuCenterX.constant = 0;
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL completed){
                             [_content popViewControllerAnimated:NO];
                             self.lcContentCenterX.constant = -2*self.view.width;
                             
                             [self.view layoutIfNeeded];
                         }];
    } else {
        self.lcMenuCenterX.constant = 0;
        [_content popViewControllerAnimated:NO];
        self.lcContentCenterX.constant = -2*self.view.width;
        [self.view layoutIfNeeded];
    }
}

- (void)showMenuWithHelpshiftData:(NSDictionary *)userInfo
{
    if (!userInfo || ![[userInfo objectForKey:@"origin"] isEqualToString:@"helpshift"]) {
        return;
    }
    
    if (!_isPushed) {
        [self pushMenuAnimated:NO];
    }
    
    if (!_isOpened) {
        [self showMenuAnimated:NO];
    }
    
    if ([[userInfo objectForKey:@"origin"] isEqualToString:@"helpshift"]) {
        [[Helpshift sharedInstance] handleRemoteNotification:userInfo withController:_sideMenu];
    }
}

#pragma mark VCtrlMenuDelegate

- (void)vctrlMenu:(VCtrlMenu *)menu showVctrl:(VCtrlBase *)vctrl
{
    [self openVctrl:vctrl];
}

- (void)vctrlMenuClose:(VCtrlMenu *)menu
{
    [self popMenuAnimated:YES];
}

- (BOOL)needTrackGAI
{
    return NO;
}

@end
