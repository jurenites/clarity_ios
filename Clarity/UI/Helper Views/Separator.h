//
//  Separator.h
//  StaffApp
//
//  Created by Alexey Klyotzin on 7/1/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Separator : UIView

@property (assign, nonatomic) BOOL onePixel;
@property (assign, nonatomic) BOOL top;
@property (assign, nonatomic) BOOL left;

@property (assign, nonatomic) BOOL vertical;

@property (strong, nonatomic) UIColor *color;

@end
