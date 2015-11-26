//
//  PtrSpinner.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 7/4/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "PtrSpinner.h"

@interface PtrSpinner ()
{
    NSArray *_sticks;
    CALayer *_layer;
    CADisplayLink *_dl;
}
@end

@implementation PtrSpinner

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if (self.superview) {
        _dl = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
        [_dl addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        [_dl removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        _dl = nil;
    }
}

- (void)update
{
    double t = CACurrentMediaTime() ;
    double val = (t - floor(t));//(sin(t / 2) + 1) / 2.0;
    
    double scaledToArray = val * _sticks.count;
    NSUInteger opaqueIndex = MIN(_sticks.count - 1, (NSUInteger)scaledToArray);
    
    
    for (NSInteger i = 0; i < (NSInteger)_sticks.count; i++) {
        NSUInteger index = opaqueIndex + i;
        
        if (index >= _sticks.count) {
            index -= _sticks.count;
        }
        
        CALayer *stick = _sticks[index];
        
        stick.opacity = pow(((double)i / _sticks.count), 1.3);
    }
    
//    _layer.affineTransform = CGAffineTransformMakeRotation(val * M_PI * 2);
//    _layer.opacity = val;
    
//    [self animateFade];
}

- (void)animateFade
{
    double t = CACurrentMediaTime();
    double val = (t - floor(t));//(sin(t / 2) + 1) / 2.0;
    
    double scaledToArray = val * _sticks.count;
    NSInteger semitransparent = scaledToArray;
    
    for (NSInteger i = 0; i < (NSInteger)_sticks.count; i++) {
        CALayer *stick = _sticks[i];
        
        if (i < semitransparent) {
            stick.opacity = 1;
        } else if (i == semitransparent) {
            stick.opacity = scaledToArray - semitransparent;
        } else {
            stick.opacity = 0;
        }
    }
}

- (void)animateSpin
{
    double t = CACurrentMediaTime();
    double val = (t - floor(t));
    
    double scaledToArray = val * _sticks.count;
    
    for (NSInteger i = 0; i < (NSInteger)_sticks.count; i++) {
        CALayer *stick = _sticks[i];
        
        double distance = MIN(fabs(scaledToArray - i), fabs(scaledToArray - _sticks.count - i));
        
        distance = MIN(distance, 2.0);
        
        stick.opacity = 0.2 + (1.0 - pow((distance / 2.0), 3)) * 0.8;
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
//    self.layer.drawsAsynchronously = YES;
    
    CGSize size = self.bounds.size;
    CGFloat radius = MIN(size.width, size.height) * 0.5f;
    CGFloat smallRadius = radius * 0.4f;
    CGSize stickSize = CGSizeMake(radius - smallRadius, 2);
    
    CALayer *layer = [[CALayer alloc] init];
    
    layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    layer.frame = CGRectMake(0, 0, 2.0f * radius, 2.0f * radius);
    
    for (NSInteger i = 0; i < 12; i++) {
        CALayer *stick = [[CALayer alloc] init];
        CALayer *substick = [[CALayer alloc] init];
        
        substick.backgroundColor = [UIColor redColor].CGColor;
        substick.frame = CGRectMake(radius + smallRadius, 0, stickSize.width, stickSize.height);
        substick.shouldRasterize = YES;
        substick.rasterizationScale = [UIScreen mainScreen].scale;
        substick.masksToBounds = YES;
        substick.cornerRadius = 1;
        
        stick.frame = CGRectMake(0, radius - 0.5f * stickSize.height, 2.0f * radius, stickSize.height);
        [stick addSublayer:substick];
        
        stick.affineTransform = CGAffineTransformMakeRotation(-(M_PI_2) + (M_PI * 2.0) * (i / 12.0));
        
        [layer addSublayer:stick];
    }
    
    _layer = layer;
    _sticks = [layer.sublayers copy];
    
    [self.layer.sublayers.lastObject removeFromSuperlayer];
    [self.layer addSublayer:layer];
}



@end
