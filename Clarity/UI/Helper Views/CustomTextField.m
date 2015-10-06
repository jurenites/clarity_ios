//
//  CustomTextField.m
//  TRN
//
//  Created by Oleg Kasimov on 3/16/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (void)awakeFromNib
{
    if (!self.maxSymbolsCount) {
        self.maxSymbolsCount = 255;
    }
}

- (NSString *)validate
{
    if (self.validator) {
        return self.validator(self.text);
    }
    
    return nil;
}

@end
