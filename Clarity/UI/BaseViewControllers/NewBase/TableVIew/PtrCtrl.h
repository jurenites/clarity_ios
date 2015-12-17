//
//  PtrCtrl.h
//  Yingo Yango
//
//  Created by Alexey Klyotzin on 05/10/15.
//  Copyright © 2015 LucienRucci. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PtrScrollProtocol.h"

@class PtrCtrl;

@protocol PtrCtrlDelegate <NSObject>

- (void)ptrCtrl:(PtrCtrl *)ptr ptrTriggered:(void(^)(BOOL hasMoreData, BOOL tryAgain))onComplete;
- (void)ptrCtrl:(PtrCtrl *)ptr infsTriggered:(void(^)(BOOL hasMoreData, BOOL tryAgain))onComplete;
- (void)ptrCtrlDidReloadData:(PtrCtrl *)ptr;

@end

@interface PtrCtrl : NSObject

- (instancetype)initWithScrollView:(UIScrollView<PtrScrollProtocol> *)scroll;

- (void)triggerInfs;
- (void)cancelPtrLoading;
- (void)cancelInfsLoading;

- (void)setTopInset:(CGFloat)topInset animated:(BOOL)animated;
- (void)resetInfiniteScrolling:(BOOL)hasData tryAgain:(BOOL)tryAgain;

@property (assign, nonatomic) BOOL shiftPtrByInsets;
@property (assign, nonatomic) BOOL ptrEnabled;
@property (assign, nonatomic) BOOL infsEnabled;
@property (assign, nonatomic) CGFloat infsTriggerTreshold;

@property (readonly, nonatomic) UIScrollView<PtrScrollProtocol> *scroll;
@property (weak, nonatomic) id<PtrCtrlDelegate> delegate;

@end
