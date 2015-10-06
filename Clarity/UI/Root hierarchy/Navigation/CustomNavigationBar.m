//
//  CustomNavigationBar.m
//  TRN
//
//  Created by stolyarov on 18/03/2015.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import "CustomNavigationBar.h"

@implementation CustomNavigationBar

//TR-411
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self pointInside:point withEvent:event]) {
        self.userInteractionEnabled = YES;
    } else {
        self.userInteractionEnabled = NO;
    }
    
    return [super hitTest:point withEvent:event];
}

@end
