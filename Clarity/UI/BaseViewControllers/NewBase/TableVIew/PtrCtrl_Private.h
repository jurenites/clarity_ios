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

@end
