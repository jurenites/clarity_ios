//
//  TableView.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 4/30/14.
//
//

#import "TableView.h"
#import "TablePtrView.h"
#import "TableInfsView.h"
#import "NibLoader.h"
#import "UIView+Utils.h"
#import "DelegatesHolder.h"

static const NSInteger MaxNoHeihgtChangesAfterInfs = 5;
static const CGFloat AnimationDuration = 0.33;
static const CGFloat DefaultTriggerTreshold = 1500;

typedef enum {
    TableViewPtrStateDefault,
    TableViewPtrStateReleasePtr,
    TableViewPtrStateLoading,
    TableViewPtrStateInfsLoading
} TableViewPtrState;

typedef enum {
    TableViewInfsStateDefault,
    TableViewInfsStateLoading,
    TableViewInfsStateNoMore
} TableViewInfsState;

@interface TableView ()
{
    BOOL _loaded;
    
    BOOL _wasTracking;
    UIEdgeInsets _requestedInsets;
    
    CGFloat _prevYOffset;
    
    NSInteger _noHeihgtChangesAfterInfs;
    
    TableViewPtrState _ptrState;
    TableViewInfsState _infsState;
    
    TablePtrView *_ptrView;
    TableInfsView *_infsView;
    
    CGFloat _ptrViewHeight;
    CGFloat _infsViewHeight;
    
    UIActivityIndicatorView *_spinner;
    
    CGFloat _topInset;
}

- (void)setup;
- (void)setupInsetsAnimated:(BOOL)animated;

- (void)contentOffsetDidChange:(CGPoint)contentOffset;
- (void)trackingDidEnd;

- (void)enablePtr;
- (void)disablePtr;

@end

@implementation TableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    [self setup];
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    _ptrView = loadViewFromNib(@"TablePtrView");
    _ptrViewHeight = _ptrView.height;
    
    _infsView = loadViewFromNib(@"TableInfsView");
    _infsViewHeight = _infsView.height;
    
    _ptrState = TableViewPtrStateDefault;
    _infsState = TableViewInfsStateDefault;
    
    if (self.ptrEnabled) {
        [self enablePtr];
    }
    
    if (self.infsEnabled) {
        [self enableInfs];
    }
    
    if (self.infsTriggerTreshold == 0) {
        self.infsTriggerTreshold = DefaultTriggerTreshold;
    }
    
    [self setupInsetsAnimated:NO];
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _spinner.hidden = YES;
    [self addSubview:_spinner];
    
    _loaded = YES;
}

- (void)setupPtrPos
{
    CGFloat offset = -(self.contentOffset.y + _requestedInsets.top);
    
    if (self.subviews.lastObject != _ptrView) {
        [self sendSubviewToBack:_ptrView];
    }
    
    CGRect ptrFrame = _ptrView.frame;
    
    if (offset > _ptrViewHeight) {
        ptrFrame.origin.y = -_requestedInsets.top * (self.shiftPtrByInsets ? 0 : 0) - _ptrViewHeight - 0.5f * (offset - _ptrViewHeight);
    } else {
        ptrFrame.origin.y = -_requestedInsets.top * (self.shiftPtrByInsets ? 0 : 0) - _ptrViewHeight - 0.5f * (offset - _ptrViewHeight) * 0;
    }
    
    ptrFrame.origin.x = 0.5f * (self.width - ptrFrame.size.width);
    _ptrView.frame = ptrFrame;

    if (TableViewPtrStateLoading != _ptrState) {
        _ptrView.alpha = powf(MAX(MIN(offset / _ptrViewHeight, 1.0f), 0.0f), 0.5f);
    } else {
        _ptrView.alpha = 1;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_wasTracking && !self.tracking) {
        [self trackingDidEnd];
    }
    _wasTracking = self.tracking;
    
    if (fabs(self.contentOffset.y - _prevYOffset) > 0.1f) {
        _prevYOffset = self.contentOffset.y;
        [self contentOffsetDidChange:self.contentOffset];
    }
    
    if (self.ptrEnabled) {
        [self setupPtrPos];
    }
    
    if (!_spinner.hidden) {
        _spinner.center = CGPointMake(0.5f * self.width, 0.5f * self.height + self.contentOffset.y);
        if (self.subviews.lastObject != _spinner) {
            [self bringSubviewToFront:_spinner];
        }
    }
}

- (void)showSpinner
{
    _spinner.hidden = NO;
    [_spinner startAnimating];
    [self setNeedsLayout];
}

- (void)hideSpinner
{
    [_spinner stopAnimating];
    _spinner.hidden = YES;
}

//=================== Content insets =====================
- (void)setupInsetsAnimated:(BOOL)animated onComplete:(void(^)())onComplete
{
    UIEdgeInsets actualInsets = _requestedInsets;
    
    actualInsets.top += _topInset;
    
    if (self.ptrEnabled) {
        if (TableViewPtrStateLoading == _ptrState) {
            CGFloat shift = MAX(0, MIN(-self.contentOffset.y, _ptrViewHeight));
            actualInsets.top += shift;
        }
    }
    
    if (self.infsEnabled) {
        if (TableViewInfsStateLoading != _infsState && TableViewInfsStateDefault != _infsState) {
            actualInsets.bottom -= _infsViewHeight;
        }
    }
    
    if (UIEdgeInsetsEqualToEdgeInsets([super contentInset], actualInsets)) {
        if (onComplete) {
            onComplete();
        }
        return;
    }
    
    if (animated) {
        [UIView animateWithDuration:AnimationDuration
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [super setContentInset:actualInsets];
                             [self setupPtrPos];
                         }
                         completion:^(BOOL completed){
                             if (onComplete) {
                                 onComplete();
                             }
                         }];
    } else {
        [super setContentInset:actualInsets];
        [self setupPtrPos];
        if (onComplete) {
            onComplete();
        }
    }
}

- (void)setupInsetsAnimated:(BOOL)animated
{
    [self setupInsetsAnimated:animated onComplete:NULL];
}

- (UIEdgeInsets)contentInset
{
    return _requestedInsets;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    _requestedInsets = contentInset;
    
    if (_loaded) {
        [self setupInsetsAnimated:NO];
    }
}

- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    
    if (_loaded && self.infsEnabled) {
        _infsView.y = self.contentSize.height;
    }
}

- (void)setInfsTriggerTreshold:(CGFloat)infsTriggerTreshold
{
    _infsTriggerTreshold = MAX(10, infsTriggerTreshold);
}

- (void)setTopInset:(CGFloat)topInset animated:(BOOL)animated
{
    _topInset = topInset;
    
    [self setupInsetsAnimated:animated];
}

- (void)scrollToTop
{
    self.contentOffset = CGPointMake(0, -[super contentInset].top);
}

- (void)reloadData
{
    [super reloadData];
    
    [self.ptrDelegate tableViewDidReloadData:self];
}

//=============== Pull to refresh ========================
- (void)enablePtr
{
    _ptrState = TableViewPtrStateDefault;
    [_ptrView switchToDefaultStateAnimated:NO];
    _ptrView.alpha = 0;
    [self addSubview:_ptrView];
    [self setupInsetsAnimated:NO];
    [self setNeedsLayout];
}

- (void)disablePtr
{
    _ptrView.alpha = 0;
    [_ptrView removeFromSuperview];
    [self setupInsetsAnimated:NO];
}

- (void)setPtrEnabled:(BOOL)ptrEnabled
{
    const BOOL prevPtrEnabled = _ptrEnabled;
    
    _ptrEnabled = ptrEnabled;
    
    if (_loaded) {
        if (ptrEnabled && !prevPtrEnabled) {
            [self enablePtr];
        } else if (!ptrEnabled && prevPtrEnabled) {
            [self disablePtr];
        }
    }
}

- (void)switchToPtrDefaultState
{
    _ptrState = TableViewPtrStateDefault;
    [_ptrView switchToDefaultStateAnimated:YES];
    
    [self setupInsetsAnimated:YES];
}

- (void)switchToPtrDefaultStateAfterLoading
{
    _ptrState = TableViewPtrStateDefault;
    
    [self setupInsetsAnimated:YES onComplete:^{
        [_ptrView switchToDefaultStateAnimated:NO];
    }];
}

- (void)switchToPtrReleaseState
{
    _ptrState = TableViewPtrStateReleasePtr;
    [_ptrView switchToReleaseState];
}

- (void)switchToPtrLoadState
{
    _ptrState = TableViewPtrStateLoading;
    [_ptrView switchToLoadingState];
    
    [self switchToInfsDefaultState];
    [self switchToNoMoreState];
    [self setupInsetsAnimated:YES];
    
    [self.ptrDelegate tableView:self ptrTriggered:^(BOOL hasMoreData){
        if (_ptrState == TableViewPtrStateLoading) {
            [self switchToPtrDefaultStateAfterLoading];
            
            if (_infsEnabled) {
                if (hasMoreData) {
                    [self switchToInfsDefaultState];
                } else {
                    [self switchToNoMoreState];
                }
            }
        }
    }];
}

- (void)processPtrContentOffsetChange:(CGPoint)contentOffset
{
    if (TableViewPtrStateDefault == _ptrState) {
        if (self.tracking && contentOffset.y < (-_ptrViewHeight*1.5f - _requestedInsets.top)) {
            [self switchToPtrReleaseState];
        }
    } else if (TableViewPtrStateReleasePtr == _ptrState) {
        if (self.tracking && contentOffset.y > (-_ptrViewHeight*1.5f - _requestedInsets.top)) {
            [self switchToPtrDefaultState];
        }
    } else if (TableViewPtrStateLoading == _ptrState) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupInsetsAnimated:NO];
        });
    }
}

- (void)cancelPtrLoading
{
    if (_ptrState == TableViewPtrStateLoading) {
        [self switchToPtrDefaultStateAfterLoading];
    }
}

//=================== Infinite scrolling ============================
- (void)enableInfs
{
    _noHeihgtChangesAfterInfs = 0;
    _infsState = TableViewInfsStateDefault;
    _infsView.frame = CGRectMake(0, 0, self.width, _infsViewHeight);
    [self setupInsetsAnimated:NO];
    self.tableFooterView = _infsView;
}

- (void)disableInfs
{
    self.tableFooterView = nil;
    [self setupInsetsAnimated:NO];
}

- (void)setInfsEnabled:(BOOL)infsEnabled
{
    const BOOL prevInfsEnabled = _infsEnabled;
    
    _infsEnabled = infsEnabled;
    
    if (_loaded) {
        if (infsEnabled && !prevInfsEnabled) {
            [self enableInfs];
        } else if (!infsEnabled && prevInfsEnabled) {
            [self disableInfs];
        }
    }
}

- (void)switchToInfsDefaultState
{
    _infsState = TableViewInfsStateDefault;
    [_infsView switchToDefault];
    [self setupInsetsAnimated:YES onComplete:NULL];
}

- (void)switchToNoMoreState
{
    _infsState = TableViewInfsStateNoMore;
    [_infsView switchToNoMore];
    [self setupInsetsAnimated:YES onComplete:NULL];
}

- (void)switchToInfsLoadingState
{
    _infsState = TableViewInfsStateLoading;
    [_infsView switchToLoading];
    [self setupInsetsAnimated:YES onComplete:NULL];
    
    const CGFloat prevTbHeight = self.contentSize.height;
    
    [self.ptrDelegate tableView:self infsTriggered:^(BOOL hasMoreData){
        if (_infsState == TableViewInfsStateLoading) {
            
            // To prevent infinite loop of infinite scroll loads
            if (hasMoreData && fabs(self.contentSize.height - prevTbHeight) < 5) {
                _noHeihgtChangesAfterInfs++;
            } else {
                _noHeihgtChangesAfterInfs = 0;
            }
            
            if (hasMoreData && _noHeihgtChangesAfterInfs < MaxNoHeihgtChangesAfterInfs) {
                [self switchToInfsDefaultState];
            } else {
                [self switchToNoMoreState];
            }
        }
    }];
}

- (void)processInfScroll
{
    if (TableViewInfsStateDefault == _infsState) {
        if ((self.contentSize.height - self.contentOffset.y - self.height) < self.infsTriggerTreshold) {
            [self switchToInfsLoadingState];
        }
    }
}

- (void)triggerInfs
{
    if (self.infsEnabled && _ptrState != TableViewInfsStateLoading) {
        [self switchToInfsLoadingState];
    }
}

- (void)checkForInfs
{
    if (self.infsEnabled && (!self.ptrEnabled || _ptrState == TableViewPtrStateDefault)) {
        [self processInfScroll];
    }
}

- (void)cancelInfsLoading
{
    if (_infsState == TableViewInfsStateLoading) {
        [self switchToInfsDefaultState];
    }
}

- (void)resetInfiniteScrolling:(BOOL)hasData
{
    if (_infsState == TableViewInfsStateNoMore) {
        _noHeihgtChangesAfterInfs = 0;
    }
    
    if (hasData) {
        [self switchToInfsDefaultState];
    } else {
        [self switchToNoMoreState];
    }
}

//==================================

- (void)contentOffsetDidChange:(CGPoint)contentOffset
{
    if (self.ptrEnabled) {
        [self processPtrContentOffsetChange:contentOffset];
    }
    
    if (self.infsEnabled && (!self.ptrEnabled || _ptrState == TableViewPtrStateDefault)) {
        [self processInfScroll];
    }
}

- (void)trackingDidEnd
{
    if (self.ptrEnabled) {
        if (TableViewPtrStateReleasePtr == _ptrState) {
            [self switchToPtrLoadState];
        }
    }
    
    if (self.infsEnabled && (!self.ptrEnabled || _ptrState == TableViewPtrStateDefault)) {
        if (TableViewInfsStateNoMore == _infsState) {
            CGFloat diff = self.contentOffset.y;
            
            if ((self.contentSize.height + super.contentInset.bottom) > self.height) {
                diff -= (self.contentSize.height + super.contentInset.bottom - self.height);
            } else {
                diff += super.contentInset.top;
            }
      
            if (diff > _infsViewHeight*1.5f) {
                [self switchToInfsLoadingState];
            }
        }
    }
}


@end
