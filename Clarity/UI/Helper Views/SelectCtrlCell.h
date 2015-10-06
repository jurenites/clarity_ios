//
//  SelectCtrlCell.h
//  StaffApp
//
//  Created by Alexey Klyotzin on 7/2/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectCtrlItem.h"

@class SelectCtrlCell;

@protocol SelectCtrlCellDelegate <NSObject>
- (void)selectCtrlCellTap:(SelectCtrlCell *)cell;
@end

@interface SelectCtrlCell : UITableViewCell

+ (NSString *)nibName;

@property (strong, nonatomic) SelectCtrlItem *item;
@property (assign, nonatomic) BOOL checked;
@property (weak, nonatomic) id<SelectCtrlCellDelegate> delegate;

@end
