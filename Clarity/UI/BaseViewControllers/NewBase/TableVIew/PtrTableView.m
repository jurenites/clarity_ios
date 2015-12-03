//
//  PtrTableView.m
//  Yingo Yango
//
//  Created by Alexey Klyotzin on 05/10/15.
//  Copyright © 2015 LucienRucci. All rights reserved.
//

#import "PtrTableView.h"
#import "PtrCtrl_Private.h"

@implementation PtrTableView

@synthesize ptrCtrl = _ptrCtrl;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _ptrCtrl = [[RevercedPtrCtrl alloc] initRevercedWithScrollView:self];
//    _ptrCtrl = [[PtrCtrl alloc] initWithScrollView:self];
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

- (void)reloadData
{
    [super reloadData];
    [_ptrCtrl reloadData];
}

#pragma mark PtrScrollProtocol

- (NSInteger)elementsCount
{
    NSInteger sum = 0;
    
    for (NSInteger section = 0, sections = [self numberOfSections]; section < sections; section++) {
        sum += [self numberOfRowsInSection:section];
    }
    return sum;
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
