//
//  TablePtrView.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 5/5/14.
//
//

#import "TablePtrView.h"

@interface TablePtrView ()

- (UIImage *)makeArrowImage;

@property (strong, nonatomic) IBOutlet UIImageView *uiArrow;
@property (strong, nonatomic) IBOutlet UILabel *uiTitle;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *uiSpinner;

@property (assign, nonatomic) UIColor *arrowColor;

@end

@implementation TablePtrView

- (void)awakeFromNib
{
    self.arrowColor = [UIColor grayColor];
    self.uiArrow.image = [self makeArrowImage];
    self.uiSpinner.hidden = NO;
}

- (void)switchToDefaultStateAnimated:(BOOL)animated
{
    self.uiArrow.hidden = NO;
    self.uiSpinner.hidden = YES;
    [self.uiSpinner stopAnimating];
    self.uiTitle.text = NSLocalizedString(@"Pull to refresh...", nil);
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.uiArrow.transform = CGAffineTransformIdentity;
        }];
    } else {
        self.uiArrow.transform = CGAffineTransformIdentity;
    }
}

- (void)switchToReleaseState
{
    self.uiArrow.hidden = NO;
    self.uiSpinner.hidden = YES;
    [self.uiSpinner stopAnimating];
    self.uiTitle.text = NSLocalizedString(@"Release to refresh...", nil);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.uiArrow.transform = CGAffineTransformMakeRotation(-M_PI);
    }];
}

- (void)switchToLoadingState
{
    self.uiArrow.hidden = YES;
    self.uiSpinner.hidden = NO;
    [self.uiSpinner startAnimating];
    self.uiTitle.text = NSLocalizedString(@"Loading...", nil);
    
    self.uiArrow.transform = CGAffineTransformIdentity;
}

- (UIImage *)makeArrowImage
{
    CGRect rect = CGRectMake(0, 0, 22, 48);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef c = UIGraphicsGetCurrentContext();
	
	// the rects above the arrow
	CGContextAddRect(c, CGRectMake(5, 0, 12, 4)); // to-do: use dynamic points
	CGContextAddRect(c, CGRectMake(5, 6, 12, 4)); // currently fixed size: 22 x 48pt
	CGContextAddRect(c, CGRectMake(5, 12, 12, 4));
	CGContextAddRect(c, CGRectMake(5, 18, 12, 4));
	CGContextAddRect(c, CGRectMake(5, 24, 12, 4));
	CGContextAddRect(c, CGRectMake(5, 30, 12, 4));
	
	// the arrow
	CGContextMoveToPoint(c, 0, 34);
	CGContextAddLineToPoint(c, 11, 48);
	CGContextAddLineToPoint(c, 22, 34);
	CGContextAddLineToPoint(c, 0, 34);
	CGContextClosePath(c);
	
	CGContextSaveGState(c);
	CGContextClip(c);
	
	// Gradient Declaration
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGFloat alphaGradientLocations[] = {0, 0.8f};
    
	CGGradientRef alphaGradient = nil;
    if([[[UIDevice currentDevice] systemVersion]floatValue] >= 5){
        NSArray* alphaGradientColors = [NSArray arrayWithObjects:
                                        (id)[self.arrowColor colorWithAlphaComponent:0].CGColor,
                                        (id)[self.arrowColor colorWithAlphaComponent:1].CGColor,
                                        nil];
        alphaGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)alphaGradientColors, alphaGradientLocations);
    }else{
        const CGFloat * components = CGColorGetComponents([self.arrowColor CGColor]);
        int numComponents = (int)CGColorGetNumberOfComponents([self.arrowColor CGColor]);
        CGFloat colors[8];
        switch(numComponents){
            case 2:{
                colors[0] = colors[4] = components[0];
                colors[1] = colors[5] = components[0];
                colors[2] = colors[6] = components[0];
                break;
            }
            case 4:{
                colors[0] = colors[4] = components[0];
                colors[1] = colors[5] = components[1];
                colors[2] = colors[6] = components[2];
                break;
            }
        }
        colors[3] = 0;
        colors[7] = 1;
        alphaGradient = CGGradientCreateWithColorComponents(colorSpace,colors,alphaGradientLocations,2);
    }
	
	
	CGContextDrawLinearGradient(c, alphaGradient, CGPointZero, CGPointMake(0, rect.size.height), 0);
    
	CGContextRestoreGState(c);
	
	CGGradientRelease(alphaGradient);
	CGColorSpaceRelease(colorSpace);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return img;
}

@end
