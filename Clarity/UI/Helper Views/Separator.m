//
//  Separator.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 7/1/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "Separator.h"

@interface Separator ()

@end

@implementation Separator

- (void)awakeFromNib
{
    _color = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    if (self.onePixel && [UIScreen mainScreen].scale > 1.1f) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(context, 0.5f);
        CGContextSetStrokeColorWithColor(context, _color.CGColor);
        
        if (!self.vertical) {
            if (self.top) {
                CGContextMoveToPoint(context, 0, 0.25f);
                CGContextAddLineToPoint(context, CGRectGetWidth(rect), 0.25f);
            } else {
                CGContextMoveToPoint(context, 0, CGRectGetHeight(rect) - 0.25f);
                CGContextAddLineToPoint(context, CGRectGetWidth(rect), CGRectGetHeight(rect) - 0.25f);
            }
        } else {
            if (self.left) {
                CGContextMoveToPoint(context, 0.25f, 0);
                CGContextAddLineToPoint(context, 0.25f, CGRectGetHeight(rect));
            } else {
                CGContextMoveToPoint(context, CGRectGetWidth(rect) - 0.25f, 0);
                CGContextAddLineToPoint(context, CGRectGetWidth(rect) - 0.25f, CGRectGetHeight(rect));
            }
        }
    
        CGContextStrokePath(context);
    } else {
        [_color set];
        UIRectFill(rect);
    }
}

- (void)setColor:(UIColor *)color
{
    if (!color) {
        color = [UIColor whiteColor];
    }
    
    _color = color;
    [self setNeedsDisplay];
}

@end
