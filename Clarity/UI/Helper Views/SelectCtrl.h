//
//  SelectCtrl.h
//  StaffApp
//
//  Created by Alexey Klyotzin on 7/1/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectCtrlItem.h"

@interface SelectCtrl : UIControl

- (void)setItems:(NSArray *)items;
- (void)setSelectedItems:(NSArray *)itemsKeys;
- (void)resetSelection;

@property (strong, nonatomic) IBInspectable UIColor *placeholderColor;

@property (strong, nonatomic) SelectCtrlItem *selectedItem;
@property (readonly, nonatomic) NSArray *selectedItems;

@property (strong, nonatomic) UIView *inputAccessoryView;

@property (assign, nonatomic) BOOL isMultiSelect;
@property (assign, nonatomic) BOOL showsCount;

@property (strong, nonatomic) NSArray *passthroughViews;

@end
