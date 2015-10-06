//
//  CustomTextView.m
//  TRN
//
//  Created by stolyarov on 30/04/2015.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import "CustomTextView.h"

@implementation CustomTextView

- (void)awakeFromNib
{
    if (!self.maxSymbolsCount) {
        self.maxSymbolsCount = 255;
    }
    if (!self.placeholderColor) {
        self.placeholderColor = [UIColor lightTextColor];
    }
    if (!self.placeholder) {
        self.placeholder = @"";
    }
}

@end
