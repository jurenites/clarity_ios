//
//  Spinner.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 8/28/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "Spinner.h"

@interface Spinner ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *uiSpinner;

@end

@implementation Spinner

- (void)awakeFromNib
{
    self.hidden = YES;
    self.autoresizingMask = UIViewAutoresizingNone;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
}

- (void)show
{
    [self.uiSpinner startAnimating];
    self.hidden = NO;
}

- (void)hide
{
    [self.uiSpinner stopAnimating];
    self.hidden = YES;
}

@end
