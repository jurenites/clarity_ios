//
//  VCtrlBase.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 6/25/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "VCtrlBase.h"
#import "Spinner.h"
#import "UIView+Utils.h"
#import "NetworkError.h"
#import "MiscUtils.h"
#import "NSAttributedString+Utils.h"
#import "UIImage+Utils.h"
//#import "LoadingOverlay.h"
//#import "NoticeView.h"
#import "VCtrlNavigation.h"
//#import <SDWebImage/UIImageView+WebCache.h>
//#import <Google/Analytics.h>
#import "VCtrlRoot.h"
//#import "NavBarLogo.h"
#import "PtrCtrl.h"
//#import "VCtrlTab.h"
//#import "LayoutGuide.h"

typedef enum {
    ContentCurrentActionNone,
    ContentCurrentActionPullToRefresh,
    ContentCurrentActionInfiniteScroll
} ContentCurrentAction;

static const CGFloat PlaceholderWidth = 270;

@interface VCtrlBase () <ApiRouterDelegate, AppDelegateDelegate, PtrCtrlDelegate>
{
    BOOL _wasFirstAppear;
    BOOL _wasFirstLayout;
    
    Spinner *_spinner;
    
    UIFont *_placehoderFont;
    UIColor *_placehoderColor;
    UILabel *_placehoderLabel;
    
    LoadingOverlay *_loadingOverlay;
    
    BOOL _transitionIsDenied;
    
    BOOL _blockPtrWhileReload;
    BOOL _blockInfWhileReload;
}
@end

@implementation VCtrlBase

//+ (void)trackScreenWithName:(NSString *)name
//{
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:name];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
//}

- (void)goBack
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goBackPages:(NSInteger)pages
{
    [self.view endEditing:YES];
    
    NSArray *vctrls = self.navigationController.viewControllers;
    
    if (pages < vctrls.count) {
        [self.navigationController setViewControllers:[vctrls subarrayWithRange:NSMakeRange(0, vctrls.count - pages)] animated:YES];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    
    _pullToRefreshEnabled = YES;
    _infiniteScrollEnabled = YES;
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _pullToRefreshEnabled = YES;
    _infiniteScrollEnabled = YES;
}

//- (id<UILayoutSupport>)bottomLayoutGuide
//{
//    VCtrlTab *tab = (VCtrlTab *)self.parentViewController.parentViewController;
//    
//    if ([tab isKindOfClass:[VCtrlTab class]]) {
//        return [[LayoutGuide alloc] initWithLenght:49];
//    }
//    
//    return [super bottomLayoutGuide];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _spinner = loadViewFromNib(@"Spinner");
    _api = [ClarityApiManager new];
    [self.view addSubview:_spinner];

    _placehoderFont = [UIFont systemFontOfSize:16];
    _placehoderColor = [UIColor colorWithWhite:0.66 alpha:1];
    _placehoderLabel = [UILabel new];
    
    _placehoderLabel.hidden = YES;
    _placehoderLabel.numberOfLines = 0;
    _placehoderLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:_placehoderLabel];
    
    self.ptrScrollView.ptrCtrl.delegate = self;
    
    self.isNeedAvatarButton = YES;
    
    if (self.navigationController.navigationBar) {
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[ApiRouter shared] addDelegate:self];
    
    if (self.isNeedAvatarButton) {
        UIButton *avatarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
        avatarButton.accessibilityLabel = @"LogoutButton";
        [avatarButton setImage:[UIImage imageNamed:@"96"] forState:UIControlStateNormal];
        [avatarButton addTarget:self action:@selector(showProfileOverlay) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:avatarButton];
    }
    
    [self kbdSubscribe];
    [self configurePtr];
    
    if (!_wasFirstAppear) {
        _wasFirstAppear = YES;
        [self viewWillFirstAppear];
    }
    [self.view setNeedsLayout];

    [self configureBackButton];
//
//    if ([self needCompanyLogo] && ![Settings shared].logoInCircles) {
//        if (self.navigationController.viewControllers.count == 1) {
//            NSString *companyId = ToString(@([Settings shared].companyId));
//         
//            if (companyId.length) {
//                NavBarLogo *logo = [NavBarLogo new];
//                
//                logo.frame = CGRectMake(0, 0, 80, 36);
//                [logo setup];
//                
//                self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logo];
//            }
//        } else {
//            self.navigationItem.leftBarButtonItem = nil;
//        }
//    }
//        
//    [[ApiRouter shared] addDelegate:self];
//    [[YYAppDelegate shared] addDelegate:self];
//    
//    [self kbdSubscribe];
//    [self configurePtr];
//        
//    if (!_wasFirstAppear) {
//        _wasFirstAppear = YES;
//        [self viewWillFirstAppear];
//    }
//    
//    if (self.trackScreenName.length > 0) {
//        [[self class] trackScreenWithName:self.trackScreenName];
//    }
//    
//    [self checkHealthKitAccess];
//    [self.view setNeedsLayout];
    
    
}

- (void)showProfileOverlay
{
    MenuOverlay *mV = [MenuOverlay new];
    [mV show];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.shownAlertView hide];
    self.shownAlertView = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.pendingRequest = nil;
    [_api cancelAllRequests];
    
    [[ApiRouter shared] removeDelegate:self];
//    [[YYAppDelegate shared] removeDelegate:self];

    [self kbdUnsubscribe];
    [self hideLoadingOverlay];
    
    [self.ptrScrollView.ptrCtrl cancelPtrLoading];
    [self.ptrScrollView.ptrCtrl cancelInfsLoading];
    
    [self.view setNeedsLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    void (^iterateSv)(UIView *view) = NULL;
    void (^ __block iterateSvWeak)(UIView *view) = NULL;
    
    iterateSv = ^(UIView *view) {
        view.exclusiveTouch = YES;
        for (UIView *subview in view.subviews) {
            iterateSvWeak(subview);
        }
    };
    
    iterateSvWeak = iterateSv;
    
    if (self.navigationController.navigationBar) {
        iterateSv(self.navigationController.navigationBar);
    }
    
    self.navigationItem.backBarButtonItem.accessibilityIdentifier = @"nav_back";
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (self.scrollView) {
        UIEdgeInsets insets = UIEdgeInsetsMake([self.topLayoutGuide length], 0, [self.bottomLayoutGuide length], 0);
        
        self.scrollView.contentInset = insets;
        self.scrollView.scrollIndicatorInsets = insets;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _spinner.center = CGPointMake(self.view.width * 0.5f, self.view.height * 0.5f);
    
    if (!_wasFirstLayout) {
        _wasFirstLayout = YES;
        [self viewDidFirstLayoutSubviews];
    }
}

//- (void)setBadgeNumber:(NSInteger)badgeNumber
//{
//    [[VCtrlTab current] setBageNumber:badgeNumber forVctrl:self];
//}

//- (void)checkHealthKitAccess
//{
//    if (!self.healthKit.isAvailable) {
//        return;
//    }
//    
//    NSArray *readDataTypes = [self hkReadDataTypes];
//    NSArray *writeDataTypes = [self hkWriteDataTypes];
//    
//    if (readDataTypes.count == 0 && writeDataTypes.count == 0) {
//        return;
//    }
//    
//    [self.healthKit requestAccessForReadTypes:[self hkReadDataTypes] writeTypes:[self hkWriteDataTypes] onComplete:^(BOOL hasAccess, NSError *error) {
//        if (!hasAccess) {
//            NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
//        }
//    }];
//}

- (void)configureBarButton:(UIBarButtonItem *)barButton
{
//    [barButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont safeFontWithName:@"Cabin-Regular" size:15]}
//                             forState:UIControlStateNormal];
}

- (void)configureBackButton
{
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain
                                                            target:nil action:NULL]; //self.navigationItem.title
    
    [self configureBarButton:back];
    self.navigationItem.backBarButtonItem = back;
}

- (void)configureBackButtonWithTitle:(NSString *)title
{
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain
                                                            target:nil action:NULL];
    
    [self configureBarButton:back];
    self.navigationItem.backBarButtonItem = back;
}

//- (NSArray *)hkReadDataTypes
//{
//    return @[];
//}
//
//- (NSArray *)hkWriteDataTypes
//{
//    return @[];
//}

- (BOOL)needCompanyLogo
{
    return NO;
}

- (void)willAppearInTabBar
{
}

#pragma mark StatusBar

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark VCtrlBaseProtocol

- (void)viewWillFirstAppear
{
}

- (void)viewDidFirstLayoutSubviews
{
}

- (void)appWillEnterForeground
{
}

- (void)appDidEnterBackground
{
}

- (void)appWillResignActive
{
}

- (void)appWentOnline
{
    [self configurePtr];
}

- (void)appWentOffline
{
    [self configurePtr];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark Placeholder

- (BOOL)isNeedPlaceholder
{
    return NO;
}

- (NSString *)placeholderText
{
    return NSLocalizedString(@"No content available.", nil);
}

- (NSAttributedString *)attributedPlaceholderText
{
    NSString *str = [self placeholderText];
    
    return [[NSAttributedString alloc] initWithString:str
                                           attributes:@{NSFontAttributeName:_placehoderFont,
                                                        NSForegroundColorAttributeName:_placehoderColor}];
}

- (CGFloat)placeholderYPos
{
    return 0;
}

- (void)layoutPlaceholderView:(UIView *)view
{
    CGFloat yPos = [self placeholderYPos];
    
    view.frame = CGRectMake(0.5 * (self.scrollView.width - view.width),
                            yPos ? yPos : 0.5 * (self.scrollView.height - view.height),
                            view.width, view.height);
}

- (void)checkPlacehoder
{
    if ([self isNeedPlaceholder]) {
        NSAttributedString *text = [self attributedPlaceholderText];
        const CGFloat height = [text heightForWidth:PlaceholderWidth];
        
        
        _placehoderLabel.attributedText = text;
        _placehoderLabel.frame = CGRectMake(0, 0, PlaceholderWidth, height);
        [self layoutPlaceholderView:_placehoderLabel];
        _placehoderLabel.hidden = NO;
    } else {
        _placehoderLabel.hidden = YES;
    }
}

#pragma mark Keyboard

- (void)kbdSubscribe
{
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kbdWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kbdWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)kbdUnsubscribe
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)kbdWillShow:(NSNotification *)n
{
    const CGFloat duration = [n.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
          CGRect kbdFrame = [n.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    const UIViewAnimationOptions curve = (UIViewAnimationOptions)[n.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
    
    [self keyboardWillShowWithSize:kbdFrame.size duration:duration curve:curve];
}

- (void)kbdWillHide:(NSNotification *)n
{
    const CGFloat duration = [n.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    const UIViewAnimationOptions curve = (UIViewAnimationOptions)[n.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
    
    [self keyboardWillHideWithDuration:duration curve:curve];
}


- (void)keyboardWillShowWithSize:(CGSize)kbdSize duration:(NSTimeInterval)duration curve:(UIViewAnimationOptions)curve
{
}

- (void)keyboardDidShow
{
}

- (void)keyboardWillHideWithDuration:(NSTimeInterval)duration curve:(UIViewAnimationOptions)curve
{
}

- (void)reportError:(NSError *)error
{
    if ([error isKindOfClass:[NetworkError class]]
        && error.code == NetworkErrorOffline) {
        [[AlertView new] showWithTitle:@""
                                  text:NSLocalizedString(@"Internet connectivity has been lost.Please check your connection and try again.", nil)
                     cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                     otherButtonTitles:@[]
                            onComplete:NULL];
    } else {
        [[AlertView new] showWithTitle:@""
                                  text:error.localizedDescription
                     cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                     otherButtonTitles:@[]
                            onComplete:NULL];
    }
}

- (void)reportErrorString:(NSString *)string
{
    [[AlertView new] showWithTitle:@""
                              text:string
                 cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                 otherButtonTitles:@[]
                        onComplete:NULL];
}

- (void)showNotice:(NSString *)string
{
    [[AlertView new] showWithTitle:NSLocalizedString(@"", nil)
                              text:string
                 cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                 otherButtonTitles:@[]
                        onComplete:NULL];
}

//- (void)showTopNotice:(NSString *)notice withColor:(UIColor *)color
//{
//    [[VCtrlRoot current] showTopNotice:notice withColor:color];
//}

- (void)goBackAfretDelay:(NSTimeInterval)delay
{
    dispatch_time_t fireTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(fireTime, dispatch_get_main_queue(), ^{
        [self goBack];
    });
}

- (NSArray *)childs
{
    NSMutableArray *childCtrls = [NSMutableArray array];
    
    for (UIViewController *vctrl in self.childViewControllers) {
        if ([vctrl conformsToProtocol:@protocol(VCtrlBaseProtocol)]) {
            [childCtrls addObject:vctrl];
        }
    }
    
    return childCtrls;
}

- (UIViewController<VCtrlBaseProtocol> *)parent
{
    if ([self.parentViewController conformsToProtocol:@protocol(VCtrlBaseProtocol)]) {
        return (UIViewController<VCtrlBaseProtocol> *)self.parentViewController;
    } else if ([self.navigationController conformsToProtocol:@protocol(VCtrlBaseProtocol)]) {
        return (UIViewController<VCtrlBaseProtocol> *)self.navigationController;
    }
    
    return nil;
}

- (BOOL)isOnScreen
{
    return [self isViewLoaded] && self.view.window != nil;
}

- (BOOL)inOnline
{
    return _api.apiRouter.inOnline;
}

- (void)showSpinner
{
    [self.view bringSubviewToFront:_spinner];
    [_spinner show];
}

- (void)hideSpinner
{
    [_spinner hide];
}

- (void)showLoadingOverlay
{
    if (_loadingOverlay) {
        [_loadingOverlay hide];
    }
    
    _loadingOverlay = [LoadingOverlay new];
    [_loadingOverlay show];
}

- (void)hideLoadingOverlay
{
    [_loadingOverlay hide];
    _loadingOverlay = nil;
}

- (BOOL)isTransitionAvailable
{
    if (_transitionIsDenied) {
        return NO;
    }
    
    _transitionIsDenied = YES;
    
    DispatchAfter(0.5f, ^{
        _transitionIsDenied = NO;
    });
    
    return YES;
}

#pragma mark PtrCtrlDelegate

- (void)ptrCtrl:(PtrCtrl *)ptr ptrTriggered:(void (^)(BOOL hasMoreData, BOOL tryAgain))onComplete
{
    VCtrlBase * __weak weakSelf = self;
    
    ApiCanceler *canceler = [self ptrReloadContent:^(BOOL hasMoreData, BOOL tryAgain) {
        onComplete(hasMoreData, tryAgain);
        [weakSelf clearPendingRequest];
        [weakSelf configurePtr];
    }];
    
    [self setPendingRequestAfterPtrOrInfs:canceler];
}

- (void)ptrCtrl:(PtrCtrl *)ptr infsTriggered:(void (^)(BOOL hasMoreData, BOOL tryAgain))onComplete
{
    VCtrlBase * __weak weakSelf = self;
    
    ApiCanceler *canceler = [self ptrLoadMoreContent:^(BOOL hasMoreData, BOOL tryAgain){
        onComplete(hasMoreData, tryAgain);
        [weakSelf clearPendingRequest];
        [weakSelf configurePtr];
    }];
    
    [self setPendingRequestAfterPtrOrInfs:canceler];
}

- (void)ptrCtrlDidReloadData:(PtrCtrl *)ptr
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configurePtr];
    });
}

#pragma mark Content related

- (void)configurePtr
{
    if (!self.ptrScrollView) {
        return;
    }
    
    self.ptrScrollView.ptrCtrl.ptrEnabled = [self isNeedPullToRefresh] && self.pullToRefreshEnabled
        && !_blockPtrWhileReload;
    
    self.ptrScrollView.ptrCtrl.infsEnabled = [self isNeedInfiniteScroll] && self.infiniteScrollEnabled
        && !_blockInfWhileReload;
}

- (void)triggerInfiniteScroll
{
    [self.ptrScrollView.ptrCtrl triggerInfs];
}

- (void)setInfiniteScrollEnabled:(BOOL)infinityScrollEnabled
{
    _infiniteScrollEnabled = infinityScrollEnabled;
    [self configurePtr];
}

- (void)setPullToRefreshEnabled:(BOOL)pullToRefreshEnabled
{
    _pullToRefreshEnabled = pullToRefreshEnabled;
    [self configurePtr];
}

- (BOOL)isNeedPullToRefresh
{
    return YES;
}

- (BOOL)isNeedInfiniteScroll
{
    return NO;
}

- (ApiCanceler *)baseReloadContent:(void(^)(BOOL hasMoreData, BOOL tryAgain))onComplete
{
    dispatch_async(dispatch_get_main_queue(), ^{
        onComplete(NO, NO);
    });
    
    return nil;
}

- (ApiCanceler *)ptrReloadContent:(BaseOnLoadMoreComplete)onComplete
{
    dispatch_async(dispatch_get_main_queue(), ^{
        onComplete(NO, NO);
    });
    return nil;
}

- (ApiCanceler *)ptrLoadMoreContent:(BaseOnLoadMoreComplete)onComplete
{
    dispatch_async(dispatch_get_main_queue(), ^{
        onComplete(NO, NO);
    });
    return nil;
}

- (void)triggerReloadContentWithBlockPtr:(BOOL)blockPtr andIs:(BOOL)blockIs
{
    self.pendingRequest = [self baseReloadContent:^(BOOL hasMoreData, BOOL tryAgain) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clearPendingRequest];
            
            _blockPtrWhileReload = NO;
            _blockInfWhileReload = NO;
            
            [self hideSpinner];
            [self configurePtr];
            [self.ptrScrollView.ptrCtrl resetInfiniteScrolling:hasMoreData tryAgain:tryAgain];
        });
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showSpinner];
        
        _blockPtrWhileReload = blockPtr;
        _blockInfWhileReload = blockIs;
        
        [self.ptrScrollView.ptrCtrl resetInfiniteScrolling:NO tryAgain:NO];
        [self configurePtr];
    });
}

- (void)triggerReloadContent
{
    [self triggerReloadContentWithBlockPtr:YES andIs:YES];
}

- (void)clearPendingRequest
{
    _pendingRequest = nil;
}

- (void)setPendingRequest:(ApiCanceler *)canceler
{
    [self.ptrScrollView.ptrCtrl cancelPtrLoading];
    [self.ptrScrollView.ptrCtrl cancelInfsLoading];
    
    [self setPendingRequestAfterPtrOrInfs:canceler];
}

- (void)setPendingRequestAfterPtrOrInfs:(ApiCanceler *)canceler
{
    _blockPtrWhileReload = NO;
    _blockInfWhileReload = NO;
    [self configurePtr];
    
    if (_pendingRequest) {
        [_pendingRequest cancel];
        
        [self hideSpinner];
    }
    
    _pendingRequest = canceler;
}

#pragma mark ApiRouterDelegate

- (void)apiRouter:(ApiRouter *)apiRouter stateChanged:(ApiRouterState)state prevState:(ApiRouterState)prev
{
    if (state == ApiRouterStateOffline) {
        [self appWentOffline];
    } else if (state == ApiRouterStateConnected) {
        [self appWentOnline];
    }
}

@end
