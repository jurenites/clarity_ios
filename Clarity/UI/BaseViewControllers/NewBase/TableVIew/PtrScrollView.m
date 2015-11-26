//
//  PtrScrollView.m
//  Yingo Yango
//
//  Created by Alexey Klyotzin on 05/10/15.
//  Copyright © 2015 LucienRucci. All rights reserved.
//

#import "PtrScrollView.h"
#import "PtrCtrl_Private.h"

@implementation PtrScrollView

@synthesize ptrCtrl = _ptrCtrl;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _ptrCtrl = [[PtrCtrl alloc] initWithScrollView:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_ptrCtrl layoutSubviews];
}

- (UIEdgeInsets)contentInset
{
    return [_ptrCtrl contentInset];
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    [_ptrCtrl setContentInset:contentInset];
}

- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    [_ptrCtrl setContentSize:contentSize];
}

#pragma mark PtrScrollProtocol

- (NSInteger)elementsCount
{
    return 1;
}

- (UIEdgeInsets)superContentInsets
{
    return [super contentInset];
}

- (void)setSuperContentInsets:(UIEdgeInsets)insets
{
    [super setContentInset:insets];
}


@end
