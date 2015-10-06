//
//  UIScreen+Utils.h
//  StaffApp
//
//  Created by Alexey Klyotzin on 8/6/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    InterfaceOrientationPortrait = 0,
    InterfaceOrientationLandscape = 1
} InterfaceOrientation;

@interface UIScreen (Utils)

+ (CGSize)screenSize;

+ (CGFloat)sideMenuWidthForOirentation:(InterfaceOrientation)orientation;
+ (CGSize)interfaceSizeForOrientation:(InterfaceOrientation)orientation;

@end
