//
//  CircleProgressBar.h
//  TRN
//
//  Created by stolyarov on 25/12/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleProgressBar : UIView
@property (assign, nonatomic) CGFloat percent;

@property (strong, nonatomic) UIColor *progressColor;
@property (strong, nonatomic) UIColor *trackColor;

@property (assign, nonatomic) CGFloat trackWidth;

@end
