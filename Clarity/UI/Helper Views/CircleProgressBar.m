//
//  CircleProgressBar.m
//  TRN
//
//  Created by stolyarov on 25/12/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "CircleProgressBar.h"
@interface CircleProgressBar ()
{
    CGFloat _startAngle;
    CGFloat _endAngle;
}
@property(strong, nonatomic)IBOutlet UILabel *uiTitle;
@end

@implementation CircleProgressBar

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    [self defaultSetup];
    return self;
}

- (void)awakeFromNib
{
    [self defaultSetup];
}

- (void)defaultSetup
{
    _startAngle = -M_PI_2;
    _percent = 0.0;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat radius = MIN(rect.size.width, rect.size.height)/2.0 - _trackWidth;
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius: radius
                      startAngle:0
                        endAngle:2*M_PI
                       clockwise:YES];
    
    
    bezierPath.lineWidth = _trackWidth;
    [_progressColor setStroke];
    [bezierPath stroke];
    
    if (_percent >= 0) {
        UIBezierPath* bezierPathTrack = [UIBezierPath bezierPath];
        [bezierPathTrack addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                                   radius: radius
                               startAngle:_startAngle
                                 endAngle:_startAngle + 2*M_PI * _percent
                                clockwise:YES];
        
        
        // Set the display for the path, and stroke it
        bezierPathTrack.lineWidth = _trackWidth;
        [_trackColor setStroke];
        [bezierPathTrack stroke];
    }
}
@end
