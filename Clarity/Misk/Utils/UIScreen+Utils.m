//
//  UIScreen+Utils.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 8/6/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "UIScreen+Utils.h"
#import "DeviceHardware.h"

@implementation UIScreen (Utils)

+ (CGSize)screenSize
{
    CGSize sz = [UIScreen mainScreen].bounds.size;
    
    return CGSizeMake(MIN(sz.width, sz.height), MAX(sz.width, sz.height));
}

+ (CGFloat)sideMenuWidthForOirentation:(InterfaceOrientation)orientation
{
    if ([DeviceHardware isIpad]) {
        if (orientation == InterfaceOrientationPortrait) {
            return 0;
        } else {
            return 320 - 64;
        }
    }
    
    return 0;
}

+ (CGSize)interfaceSizeForOrientation:(InterfaceOrientation)orientation
{
    CGSize screenSize = [self screenSize];
    
    if (orientation == InterfaceOrientationLandscape) {
        screenSize = CGSizeMake(screenSize.height, screenSize.width);
    }
    
    screenSize.width -= [self sideMenuWidthForOirentation:orientation];
    
    return screenSize;
}

@end
