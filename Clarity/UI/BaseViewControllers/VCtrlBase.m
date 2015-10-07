//
//  VCtrlBase.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 6/25/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "VCtrlBase.h"
#import "DeviceHardware.h"
#import "Spinner.h"
#import "UIView+Utils.h"
#import "NetworkError.h"

#import "NSAttributedString+Utils.h"

#import "PLICropAndBlur.h"
#import "UIImage+Utils.h"
//#import "TRN-Swift.h"
#import "Clarity-Swift.h"

static const CGFloat PlaceholderWidth = 270;


@interface VCtrlBase () <ApiRouterDelegate, AppDelegateDelegate>
{
    BOOL _wasFirstAppear;
    BOOL _wasFirstLayout;
    
    Spinner *_spinner;
    
    UIFont *_placehoderFont;
    UIColor *_placehoderColor;
    UILabel *_placehoderLabel;
    
    LoadingOverlay *_loadingOverlay;
    
    BOOL _transitionIsDenied;
}
@end

@implementation VCtrlBase

- (void)goBack
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showSettings
{

//    VCtrlSettings *settingsVC = [VCtrlSettings new];
//    if (settingsVC) {
//        [settingsVC show];
//    }
}

+ (CGFloat)statusBarHeight
{
    return [DeviceHardware lowerThaniOS7] ? 0 : [UIApplication sharedApplication].statusBarFrame.size.height;
}

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
    
    self.isNeedAvatarButton = YES;
    
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Raleway-semiBold" size:16]}];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[ApiRouter shared] addDelegate:self];
    
    if (self.isNeedAvatarButton) {
        UIButton *avatarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
        
        avatarButton.backgroundColor = [UIColor greenColor];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:avatarButton];
    }
    
    [self kbdSubscribe];
        
    if (!_wasFirstAppear) {
        _wasFirstAppear = YES;
        [self viewWillFirstAppear];
    }
    [self.view setNeedsLayout];
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
//    [[AGAppDelegate shared] removeDelegate:self];

    [self kbdUnsubscribe];
    
    [self hideLoadingOverlay];
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

- (NSString *)GAITrackName
{
    return NSStringFromClass([self class]);
}

#pragma mark StatusBar
- (BOOL)prefersStatusBarHidden
{
    return NO;
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
//    if ([GlobalEntitiesCtrl shared].currentUser.isTrainer) {
//        [self updateSessionInfo];
//    }
}

- (void)appWentOffline
{
//    [[AlertView new] showWithTitle:@"No internet connection."
//                              text:@""
//                 cancelButtonTitle:@"Ok"
//                 otherButtonTitles:@[]
//                        onComplete:nil];
}

- (BOOL)needNavBar
{
    return YES;
}

- (BOOL)needBackButton
{
    return YES;
}

- (BOOL)needMenu
{
    return NO;
}

- (void)checkPromoAndShow
{
}

- (BOOL)needTimer
{
    return NO;
}

- (BOOL)needLock
{
    return NO;
}

- (BOOL)needTrackGAI
{
    return YES;
}

- (NSArray *)needCustomButtons
{
    return nil;
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

//- (void)setAvatarFromUrl:(NSString *)avatarUrl
//          withAvatarData:(NSData *)notUpdatedAvatarData
//                  sizeOf:(CGSize)size
//               onSuccess:(void(^)(UIImage *image, BOOL animated))onSuccess
//{
//    NSData *avatarData = [[ApiRouter shared].avatarFileCache loadFileWithName:[AvatarFileCache avatarNameFromUrl:avatarUrl]];
//    if (notUpdatedAvatarData.length) {
//        avatarData = notUpdatedAvatarData;
//    }
//    
//    void (^setAvatarImage)(UIImage *image, BOOL animated) = ^(UIImage *image, BOOL animated) {
//        if (!image) {
//            return;
//        }
//        
//        CIImage *ciImg = [CIImage imageWithCGImage:image.CGImage];
//        UIImage *circleImg = [[PLICropAndBlur processAvatar:ciImg
//                                            withOrientation:image.imageOrientation
//                                                    dstSize:size
//                                                   avatarId:[AvatarFileCache avatarNameFromUrl:avatarUrl]
//                                                 updateTime:nil] applyCircleMask];
//        
//        if (onSuccess) {
//            onSuccess(circleImg, animated);
//        }
//    };
//    
//    if (avatarData) {
//        setAvatarImage([UIImage imageWithData:avatarData], NO);
//    } else {
//        self.pendingRequest = [self.api avatarFromUrl:avatarUrl pipeline:@[] onSuccess:^(UIImage *image){
//            setAvatarImage(image, YES);
//        } onError:^(NSError *error) {
//        }];
//    }
//}
//
//- (void)setAvatarFromUrl:(NSString *)avatarUrl
//          withAvatarData:(NSData *)notUpdatedAvatarData
//             toImageView:(UIImageView *)avatarView
//         withPlaceholder:(UIImageView *)placeholder
//{
//    [self setAvatarFromUrl:avatarUrl withAvatarData:notUpdatedAvatarData sizeOf:avatarView.frame.size onSuccess:^(UIImage *image, BOOL animated) {
//        [UIView placeholderTransition:placeholder
//                            imageView:avatarView
//                                image:image
//                             animated:animated];
//    }];
//}


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

- (void)hideSpinner
{
    [_spinner hide];
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

#pragma mark Content related

- (ApiCanceler *)baseReloadContent:(void(^)(BOOL hasMoreData, BOOL tryAgain))onComplete
{
    dispatch_async(dispatch_get_main_queue(), ^{
        onComplete(NO, NO);
    });
    
    return nil;
}

- (void)triggerReloadContent
{
    VCtrlBase * __weak weakSelf = self;
    
    self.pendingRequest = [self baseReloadContent:^(BOOL hasMoreData, BOOL tryAgain){
        weakSelf.pendingRequest = nil;
    }];
    
    [self showSpinner];
}

- (void)clearPendingRequest
{
    _pendingRequest = nil;
}

- (void)setPendingRequest:(ApiCanceler *)canceler
{
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
