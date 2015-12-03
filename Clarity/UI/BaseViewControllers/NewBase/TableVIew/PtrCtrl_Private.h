//
//  PtrCtrl_Private.h
//  Yingo Yango
//
//  Created by Alexey Klyotzin on 05/10/15.
//  Copyright © 2015 LucienRucci. All rights reserved.
//

#import "PtrCtrl.h"

@interface PtrCtrl ()

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

- (void)layoutSubviews;
- (UIEdgeInsets)contentInset;
- (void)setContentInset:(UIEdgeInsets)contentInset;
- (void)setContentSize:(CGSize)contentSize;
- (void)reloadData;

////Ptr
//- (void)setupPtrPos;
//- (void)setupInfsPos;
//- (void)setupInsetsAnimated:(BOOL)animated onComplete:(void(^)())onComplete;
//- (void)setupInsetsAnimated:(BOOL)animated;
//
//- (void)enablePtr;
//- (void)disablePtr;
//- (void)setPtrEnabled:(BOOL)ptrEnabled;
//- (void)switchToPtrDefaultState;
//- (void)switchToPtrDefaultStateAfterLoading;
//- (void)switchToPtrReleaseState;
//- (void)switchToPtrLoadState;
//- (void)processPtrContentOffsetChange:(CGPoint)contentOffset;
//- (void)cancelPtrLoading;
////Infs
//- (void)enableInfs;
//- (void)disableInfs;
//- (void)setInfsEnabled:(BOOL)infsEnabled;
//- (void)switchToInfsDefaultState;
//- (void)switchToTryAgainState;
//- (void)switchToNoMoreState;
//- (void)switchToInfsLoadingState;
//- (void)processInfScroll;
//- (void)triggerInfs;
//- (void)cancelInfsLoading;
//- (void)resetInfiniteScrolling:(BOOL)hasData tryAgain:(BOOL)tryAgain;
//
//
//- (void)contentOffsetDidChange:(CGPoint)contentOffset isForward:(BOOL)isForward;
//- (void)trackingDidEnd;



@end
