//
//  SelectCtrlCell.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 7/2/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "SelectCtrlCell.h"
#import "DeviceHardware.h"

@interface SelectCtrlCell ()

@property (strong, nonatomic) IBOutlet UIImageView *uiCheckmark;
@property (strong, nonatomic) IBOutlet UILabel *uiTitle;

@end

@implementation SelectCtrlCell

+ (NSString *)nibName
{
    return [DeviceHardware isIpad] ? @"SelectCtrlCellIpad" : @"SelectCtrlCell";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
}

- (void)setItem:(SelectCtrlItem *)item
{
    _item = item;
    
    self.uiTitle.text = item.name;
}

- (void)setChecked:(BOOL)checked
{
    _checked = checked;
    self.uiCheckmark.hidden = !checked;
}

- (IBAction)actTap
{
    if ([self.delegate respondsToSelector:@selector(selectCtrlCellTap:)]) {
        [self.delegate selectCtrlCellTap:self];
    }
}

@end
