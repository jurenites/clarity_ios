//
//  VCtrlSelectMultiContent.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 9/23/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "VCtrlSelectMultiContent.h"

@interface VCtrlSelectMultiContent ()

@property (strong, nonatomic) IBOutlet UITableView *uiTable;

@end

@implementation VCtrlSelectMultiContent

- (UITableView *)table
{
    return self.uiTable;
}

@end
