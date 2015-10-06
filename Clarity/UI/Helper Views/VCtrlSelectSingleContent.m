//
//  VCtrlSelectSingleContentViewController.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 9/19/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "VCtrlSelectSingleContent.h"

@interface VCtrlSelectSingleContent ()

@property (strong, nonatomic) IBOutlet UIPickerView *uiPicker;

@end

@implementation VCtrlSelectSingleContent

- (instancetype)init
{
    return [self initWithNibName:@"VCtrlSelectSingleContent" bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (UIPickerView *)picker
{
    return self.uiPicker;
}


@end
