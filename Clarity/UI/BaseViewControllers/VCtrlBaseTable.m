//
//  VCtrlBaseTable.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 6/27/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "VCtrlBaseTable.h"
#import "ApiRouter.h"
#import "NSAttributedString+Utils.h"

typedef enum {
    BaseTableCurrentActionNone,
    BaseTableCurrentActionPullToRefresh,
    BaseTableCurrentActionInfiniteScroll
} BaseTableCurrentAction;

@interface VCtrlBaseTable () <ApiRouterDelegate, TableViewDelegate>
{
    BOOL _blockPtrWhileReload;
    BOOL _blockInfWhileReload;
}

@property (assign, nonatomic) BOOL ptrViewEnabled;

@end

@implementation VCtrlBaseTable

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    
    _pullToRefreshEnabled = YES;
    _infiniteScrollEnabled = NO;
    
    return self;
}

- (void)awakeFromNib
{
    _pullToRefreshEnabled = YES;
    _infiniteScrollEnabled = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.ptrDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureTable];
    
    self.contentCtrl.isActive = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.tableView cancelPtrLoading];
    [self.tableView cancelInfsLoading];
    
    self.contentCtrl.isActive = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!_dontAdjustInsets) {
        UIEdgeInsets insets = self.tableView.contentInset;
        insets.bottom = self.bottomInset;
        insets.top = self.topInset;
        self.tableView.contentInset = insets;
        
        UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
        scrollInsets.bottom = self.bottomInset;
        scrollInsets.top = self.topInset;
        self.tableView.scrollIndicatorInsets = insets;
    }
}

- (void)viewDidFirstLayoutSubviews
{
    [super viewDidFirstLayoutSubviews];
    
    [self.tableView scrollToTop];
}

- (void)appDidEnterBackground
{
    [super appDidEnterBackground];
    
    self.contentCtrl.isActive = NO;
}

- (void)appWillEnterForeground
{
    [super appWillEnterForeground];
    
    self.contentCtrl.isActive = YES;
}

- (void)appWentOnline
{
    [super appWentOnline];
    
    [self.contentCtrl restartRequests];
    [self configureTable];
}

- (void)appWentOffline
{
    [super appWentOffline];
    [self configureTable];
}

- (BOOL)needNavBar
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)layoutPlaceholderView:(UIView *)view
{
    const CGFloat yShift = self.tableView.tableHeaderView.height;
    const CGFloat yPos = [self placeholderYPos];
    
    view.frame = CGRectMake(0.5 * (self.tableView.width - view.width),
                            (yPos ? yPos : (0.5 * (self.tableView.height - yShift - view.height))) + yShift,
                            view.width, view.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self.contentCtrl memoryWarningReceived];
}

- (void)scrollToTop
{
    self.tableView.contentOffset = CGPointMake(0, 0);
}

- (UIScrollView *)scrollView
{
    return self.tableView;
}

#pragma mark TableViewDelegate

- (void)tableView:(TableView *)tableView ptrTriggered:(void (^)(BOOL hasMoreData))onComplete
{
    VCtrlBaseTable * __weak weakSelf = self;
    
    ApiCanceler *canceler = [self tableReloadContent:^(BOOL hasMoreData, BOOL tryAgain) {
        onComplete(hasMoreData);
        [weakSelf clearPendingRequest];
        [weakSelf configureTable];
    }];
    
    [self setPendingRequestAfterPtrOrInfs:canceler];
}

- (void)tableView:(TableView *)tableView infsTriggered:(void (^)(BOOL hasMoreData))onComplete
{
    VCtrlBaseTable * __weak weakSelf = self;
    
    ApiCanceler *canceler = [self tableLoadMoreContent:^(BOOL hasMoreData, BOOL tryAgain){
        onComplete(hasMoreData);
        [weakSelf clearPendingRequest];
        [weakSelf configureTable];
    }];
    
    [self setPendingRequestAfterPtrOrInfs:canceler];
}

- (void)tableViewDidReloadData:(TableView *)tableView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configureTable];
    });
}

#pragma mark Content

- (TableContentCtrl *)contentCtrl
{
    return nil;
}

- (void)setContentCtrl:(TableContentCtrl *)contentCtrl
{
}

- (void)configureTable
{
    self.tableView.ptrEnabled = [self isNeedPullToRefresh] && self.pullToRefreshEnabled
    && !_blockPtrWhileReload;
    
    self.tableView.infsEnabled = [self isNeedInfiniteScroll] && self.infiniteScrollEnabled
    && !_blockInfWhileReload;
}

- (void)triggerInfiniteScroll
{
    [self.tableView triggerInfs];
}

- (BOOL)isNeedPullToRefresh
{
    return [ApiRouter shared].inOnline;
}

- (BOOL)isNeedInfiniteScroll
{
    return YES;
}

- (void)setInfiniteScrollEnabled:(BOOL)infinityScrollEnabled
{
    _infiniteScrollEnabled = infinityScrollEnabled;
    [self configureTable];
}

- (void)setPullToRefreshEnabled:(BOOL)pullToRefreshEnabled
{
    _pullToRefreshEnabled = pullToRefreshEnabled;
    [self configureTable];
}

- (ApiCanceler *)baseReloadContent:(void (^)(BOOL, BOOL))onComplete
{
    dispatch_async(dispatch_get_main_queue(), ^{
        onComplete(NO, NO);
    });
    return nil;
}

- (ApiCanceler *)tableReloadContent:(BaseTableOnLoadMoreComplete)onComplete
{
    dispatch_async(dispatch_get_main_queue(), ^{
        onComplete(NO, NO);
    });
    return nil;
}

- (ApiCanceler *)tableLoadMoreContent:(BaseTableOnLoadMoreComplete)onComplete
{
    dispatch_async(dispatch_get_main_queue(), ^{
        onComplete(NO, NO);
    });
    return nil;
}


#pragma mark Keyboard

- (void)keyboardWillShowWithSize:(CGSize)kbdSize duration:(NSTimeInterval)duration curve:(UIViewAnimationOptions)curve
{
    [UIView animateWithDuration:duration delay:0 options:curve animations:^{
        UIEdgeInsets insets = self.tableView.contentInset;
        UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
    
        insets.bottom = kbdSize.height;
        scrollInsets.bottom = kbdSize.height;
        
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = scrollInsets;
    } completion:NULL];
}

- (void)keyboardDidShow
{
}

- (void)keyboardWillHideWithDuration:(NSTimeInterval)duration curve:(UIViewAnimationOptions)curve
{
    [UIView animateWithDuration:duration delay:0 options:curve animations:^{
        UIEdgeInsets insets = self.tableView.contentInset;
        UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
        
        insets.bottom = self.bottomInset;
        scrollInsets.bottom = self.bottomInset;
        
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = scrollInsets;
    } completion:NULL];
}

#pragma mark Content related

- (void)triggerReloadContentWithBlockPtr:(BOOL)blockPtr andIs:(BOOL)blockIs
{
    [self showSpinner];

    self.pendingRequest = [self baseReloadContent:^(BOOL hasMoreData, BOOL tryAgain){
        [self clearPendingRequest];
        
        _blockPtrWhileReload = NO;
        _blockInfWhileReload = NO;
        
        [self hideSpinner];
        [self configureTable];
        [self.tableView resetInfiniteScrolling:hasMoreData];
    }];
    
    
    _blockPtrWhileReload = blockPtr;
    _blockInfWhileReload = blockIs;
    
    [self.tableView resetInfiniteScrolling:NO];
    [self configureTable];
}

- (void)triggerReloadContent
{
    [self triggerReloadContentWithBlockPtr:YES andIs:YES];
}

- (void)setPendingRequest:(ApiCanceler *)canceler
{
    [self.tableView cancelPtrLoading];
    [self.tableView cancelInfsLoading];
    
    [self setPendingRequestAfterPtrOrInfs:canceler];
}

- (void)setPendingRequestAfterPtrOrInfs:(ApiCanceler *)req
{
    _blockPtrWhileReload = NO;
    _blockInfWhileReload = NO;
    [self configureTable];
    
    [super setPendingRequest:req];
}

@end
