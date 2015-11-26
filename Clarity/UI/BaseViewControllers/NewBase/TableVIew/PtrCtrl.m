//
//  PtrCtrl.m
//  Yingo Yango
//
//  Created by Alexey Klyotzin on 05/10/15.
//  Copyright © 2015 LucienRucci. All rights reserved.
//

#import "PtrCtrl.h"
#import "TablePtrView.h"
#import "TableInfsView.h"
#import "NibLoader.h"
#import "UIView+Utils.h"
#import "PtrCtrl_Private.h"

static const CGFloat AnimationDuration = 0.33;
static const CGFloat DefaultTriggerTreshold = 1500;

typedef enum {
    PtrStateDefault,
    PtrStateReleasePtr,
    PtrStateLoading,
    PtrStateInfsLoading
} PtrState;

typedef enum {
    InfsStateDefault,
    InfsStateLoading,
    InfsStateTryAgain,
    InfsStateNoMore
} InfsState;

@interface PtrCtrl ()
{
    BOOL _wasTracking;
    UIEdgeInsets _requestedInsets;
    
    CGFloat _prevYOffset;
    
    PtrState _ptrState;
    InfsState _infsState;
    
    TablePtrView *_ptrView;
    TableInfsView *_infsView;
    
    CGFloat _ptrViewHeight;
    CGFloat _infsViewHeight;
    
    UIActivityIndicatorView *_spinner;
    CGFloat _topInset;
    NSUInteger _prevItemsCount;
}

- (void)showSpinner;
- (void)hideSpinner;
- (void)resetInfiniteScrolling:(BOOL)hasData tryAgain:(BOOL)tryAgain;

@end

@implementation PtrCtrl

- (instancetype)initWithScrollView:(UIScrollView<PtrScrollProtocol> *)scroll
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _scroll = scroll;
    _ptrView = loadViewFromNib(@"TablePtrView");
    _ptrViewHeight = _ptrView.height;
    
    _infsView = loadViewFromNib(@"TableInfsView");
    _infsViewHeight = _infsView.height;
    
    _ptrState = PtrStateDefault;
    _infsState = InfsStateDefault;
    
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
    [_scroll addSubview:_spinner];
    return self;
}

- (void)setupPtrPos
{
    if (!self.isReverced) {
        CGFloat offset = -(_scroll.contentOffset.y + _requestedInsets.top);
        
        if (_scroll.subviews.lastObject != _ptrView) {
            [_scroll sendSubviewToBack:_ptrView];
        }
        
        CGRect ptrFrame = _ptrView.frame;
        
        if (offset > _ptrViewHeight) {
            ptrFrame.origin.y = -_requestedInsets.top * (self.shiftPtrByInsets ? 0 : 0) - _ptrViewHeight - 0.5f * (offset - _ptrViewHeight);
        } else {
            ptrFrame.origin.y = -_requestedInsets.top * (self.shiftPtrByInsets ? 0 : 0) - _ptrViewHeight - 0.5f * (offset - _ptrViewHeight) * 0;
        }
        
        ptrFrame.origin.x = 0.5f * (_scroll.width - ptrFrame.size.width);
        _ptrView.frame = ptrFrame;
        
        if (PtrStateLoading != _ptrState) {
            _ptrView.alpha = powf(MAX(MIN(offset / _ptrViewHeight, 1.0f), 0.0f), 0.2f);
        } else {
            _ptrView.alpha = 1;
        }
    } else {
        //new
        _ptrView.y = _scroll.contentSize.height;
        //new
    }
}

- (void)setupInfsPos
{
    //new
    if (self.isReverced) {
        CGFloat offset = -(_scroll.contentOffset.y + _requestedInsets.top);
        if (_scroll.subviews.lastObject != _infsView) {
            [_scroll sendSubviewToBack:_infsView];
        }
        CGRect infsFrame = _infsView.frame;
        if (offset > _infsViewHeight) {
            infsFrame.origin.y = -_requestedInsets.top * (self.shiftPtrByInsets ? 0 : 0) - _infsViewHeight - 0.5f * (offset - _infsViewHeight);
        } else {
            infsFrame.origin.y = -_requestedInsets.top * (self.shiftPtrByInsets ? 0 : 0) - _infsViewHeight - 0.5f * (offset - _infsViewHeight) * 0;
        }
        
        infsFrame.origin.x = 0.5f * (_scroll.width - infsFrame.size.width);
        _infsView.frame = infsFrame;
        
        if (_infsState != InfsStateLoading) {
            _infsView.alpha = powf(MAX(MIN(offset / _infsViewHeight, 1.0f), 0.0f), 0.2f);
        } else {
            _infsView.alpha = 1;
        }
    //new
    } else {
        _infsView.y = _scroll.contentSize.height;
    }
}

- (void)layoutSubviews
{
    if (_wasTracking && !_scroll.tracking) {
        [self trackingDidEnd];
    }
    _wasTracking = _scroll.tracking;
    
    const CGFloat shift = _scroll.contentOffset.y - _prevYOffset;
    
    if (fabs(shift) > 0.1f) {
        _prevYOffset = _scroll.contentOffset.y;
        [self contentOffsetDidChange:_scroll.contentOffset isForward:shift > 0];
    }
    
    if (self.ptrEnabled) {
        [self setupPtrPos];
    }
    
    if (self.infsEnabled) {
        [self setupInfsPos];
    }
    
    if (!_spinner.hidden) {
        _spinner.center = CGPointMake(0.5f * _scroll.width, 0.5f * _scroll.height + _scroll.contentOffset.y);
        if (_scroll.subviews.lastObject != _spinner) {
            [_scroll bringSubviewToFront:_spinner];
        }
    }
}

- (void)showSpinner
{
    _spinner.hidden = NO;
    [_spinner startAnimating];
    [_scroll setNeedsLayout];
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
        if (PtrStateLoading == _ptrState) {
            CGFloat shift = MAX(0, MIN(-_scroll.contentOffset.y, _ptrViewHeight));
            actualInsets.top += shift;
        }
    }
    
    if (self.infsEnabled) {
        if (InfsStateLoading == _infsState || InfsStateDefault == _infsState) {
            actualInsets.bottom += _infsViewHeight;
        }
    }
    
    if (UIEdgeInsetsEqualToEdgeInsets([_scroll superContentInsets], actualInsets)) {
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
                             [_scroll setSuperContentInsets:actualInsets];
                             [self setupPtrPos];
                         }
                         completion:^(BOOL completed){
                             if (onComplete) {
                                 onComplete();
                             }
                         }];
    } else {
        [_scroll setSuperContentInsets:actualInsets];
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
    
    [self setupInsetsAnimated:NO];
}

- (void)setContentSize:(CGSize)contentSize
{
    if (self.infsEnabled) {
        _infsView.y = _scroll.contentSize.height;
    }
}

- (void)reloadData
{
    [self.delegate ptrCtrlDidReloadData:self];
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

//=============== Pull to refresh ========================
- (void)enablePtr
{
    _ptrState = PtrStateDefault;
    [_ptrView switchToDefaultStateAnimated:NO];
    _ptrView.alpha = 0;
    [_scroll addSubview:_ptrView];
    [self setupInsetsAnimated:NO];
    [_scroll setNeedsLayout];
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
    
    if (ptrEnabled && !prevPtrEnabled) {
        [self enablePtr];
    } else if (!ptrEnabled && prevPtrEnabled) {
        [self disablePtr];
    }
}

- (void)switchToPtrDefaultState
{
    _ptrState = PtrStateDefault;
    [_ptrView switchToDefaultStateAnimated:YES];
    
    [self setupInsetsAnimated:YES];
}

- (void)switchToPtrDefaultStateAfterLoading
{
    _ptrState = PtrStateDefault;
    
    [self setupInsetsAnimated:YES onComplete:^{
        [_ptrView switchToDefaultStateAnimated:NO];
    }];
}

- (void)switchToPtrReleaseState
{
    _ptrState = PtrStateReleasePtr;
    [_ptrView switchToReleaseState];
}

- (void)switchToPtrLoadState
{
    _ptrState = PtrStateLoading;
    [_ptrView switchToLoadingState];
    
    [self switchToInfsDefaultState];
    [self switchToNoMoreState];
    [self setupInsetsAnimated:YES];
    
    [self.delegate ptrCtrl:self ptrTriggered:^(BOOL hasMoreData, BOOL tryAgain){
        if (_ptrState == PtrStateLoading) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self switchToPtrDefaultStateAfterLoading];
                
                if (_infsEnabled) {
                    if (hasMoreData) {
                        [self switchToInfsDefaultState];
                    } else if (tryAgain) {
                        [self switchToTryAgainState];
                    } else {
                        [self switchToNoMoreState];
                    }
                }
            });
        }
    }];
}

- (void)processPtrContentOffsetChange:(CGPoint)contentOffset
{
//    (_scroll.contentSize.height - _scroll.contentOffset.y - _scroll.height) < self.infsTriggerTreshold
    
    if (self.isReverced) {
        if (PtrStateDefault == _ptrState) {
            if (_scroll.tracking && contentOffset.y < (-_ptrViewHeight*1.1f - _requestedInsets.top)) {
                [self switchToPtrReleaseState];
            }
        } else if (PtrStateReleasePtr == _ptrState) {
            if (_scroll.tracking && contentOffset.y > (-_ptrViewHeight*1.1f - _requestedInsets.top)) {
                [self switchToPtrDefaultState];
            }
        } else if (PtrStateLoading == _ptrState) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupInsetsAnimated:NO];
            });
        }
    } else {
        if (PtrStateDefault == _ptrState) {
            if (_scroll.tracking && contentOffset.y < (-_ptrViewHeight*1.1f - _requestedInsets.top)) {
                [self switchToPtrReleaseState];
            }
        } else if (PtrStateReleasePtr == _ptrState) {
            if (_scroll.tracking && contentOffset.y > (-_ptrViewHeight*1.1f - _requestedInsets.top)) {
                [self switchToPtrDefaultState];
            }
        } else if (PtrStateLoading == _ptrState) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupInsetsAnimated:NO];
            });
        }
    }
}

- (void)cancelPtrLoading
{
    if (_ptrState == PtrStateLoading) {
        [self switchToPtrDefaultStateAfterLoading];
    }
}

//=================== Infinite scrolling ============================
- (void)enableInfs
{
    _infsState = InfsStateDefault;
    _infsView.frame = CGRectMake(0, 0, _scroll.width, _infsViewHeight);
    [self setupInsetsAnimated:NO];
    [_scroll addSubview:_infsView];
}

- (void)disableInfs
{
    [_infsView removeFromSuperview];
    [self setupInsetsAnimated:NO];
}

- (void)setInfsEnabled:(BOOL)infsEnabled
{
    const BOOL prevInfsEnabled = _infsEnabled;
    
    _infsEnabled = infsEnabled;
    
    if (infsEnabled && !prevInfsEnabled) {
        [self enableInfs];
    } else if (!infsEnabled && prevInfsEnabled) {
        [self disableInfs];
    }
}

- (void)switchToInfsDefaultState
{
    _infsState = InfsStateDefault;
    [_infsView switchToDefault];
    [self setupInsetsAnimated:YES onComplete:NULL];
}

- (void)switchToTryAgainState
{
    _infsState = InfsStateTryAgain;
    [_infsView switchToNoMore];
    [self setupInsetsAnimated:YES onComplete:NULL];
}

- (void)switchToNoMoreState
{
    _infsState = InfsStateNoMore;
    [_infsView switchToNoMore];
    [self setupInsetsAnimated:YES onComplete:NULL];
}

- (void)switchToInfsLoadingState
{
    _infsState = InfsStateLoading;
    [_infsView switchToLoading];
    [self setupInsetsAnimated:YES onComplete:NULL];
    
    _prevItemsCount = [_scroll elementsCount];
    
    [self.delegate ptrCtrl:self infsTriggered:^(BOOL hasMoreData, BOOL tryAgain){
        if (_infsState == InfsStateLoading) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (hasMoreData) {
                    const NSUInteger itemsCount = [_scroll elementsCount];
                    
                    if (itemsCount != _prevItemsCount) {
                        [self switchToInfsDefaultState];
                    } else {
                        [self switchToTryAgainState];
                    }
                } else if (tryAgain) {
                    [self switchToTryAgainState];
                } else {
                    [self switchToNoMoreState];
                }
            });
        }
    }];
}

- (void)processInfScroll
{
    if (InfsStateDefault == _infsState) {
        if ((_scroll.contentSize.height - _scroll.contentOffset.y - _scroll.height) < self.infsTriggerTreshold) {
            [self switchToInfsLoadingState];
        }
    }
}

- (void)triggerInfs
{
    if (self.infsEnabled && _ptrState != InfsStateLoading) {
        [self switchToInfsLoadingState];
    }
}

- (void)cancelInfsLoading
{
    if (_infsState == InfsStateLoading) {
        [self switchToInfsDefaultState];
    }
}

- (void)resetInfiniteScrolling:(BOOL)hasData tryAgain:(BOOL)tryAgain
{
    if (hasData) {
        [self switchToInfsDefaultState];
    } else if (tryAgain) {
        [self switchToTryAgainState];
    } else {
        [self switchToNoMoreState];
    }
}

//==================================

- (void)contentOffsetDidChange:(CGPoint)contentOffset isForward:(BOOL)isForward
{
    if (self.ptrEnabled) {
        [self processPtrContentOffsetChange:contentOffset];
    }
    
    if (self.infsEnabled && isForward
        && (!self.ptrEnabled || _ptrState == PtrStateDefault)) {
        [self processInfScroll];
    }
}

- (void)trackingDidEnd
{
    if (self.ptrEnabled) {
        if (PtrStateReleasePtr == _ptrState) {
            [self switchToPtrLoadState];
        }
    }
    
    if (self.infsEnabled && (!self.ptrEnabled || _ptrState == PtrStateDefault)) {
        if (InfsStateTryAgain == _infsState) {
            CGFloat diff = _scroll.contentOffset.y;
            
            if ((_scroll.contentSize.height + [_scroll superContentInsets].bottom) > _scroll.height) {
                diff -= (_scroll.contentSize.height + [_scroll superContentInsets].bottom - _scroll.height);
            } else {
                diff += [_scroll superContentInsets].top;
            }
            
            if (diff > _infsViewHeight * 1.2f) {
                [self switchToInfsLoadingState];
            }
        }
    }
}


@end
