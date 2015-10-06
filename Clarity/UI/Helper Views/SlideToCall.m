//
//  SlideView.m
//  TRN
//
//  Created by stolyarov on 26/12/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "SlideToCall.h"
#import "UIView+Utils.h"

const CGFloat kSwipeVelocity = 1000.0f;
const CGFloat kSwipeTranslation = 150.0f;

@interface SlideToCall()
{
    CGRect _defaultFrame;
}
@property (strong, nonatomic) IBOutlet UIImageView *uiMovingView;
@property (strong, nonatomic) IBOutlet UIView *uiDefaultBG;
@property (strong, nonatomic) IBOutlet UIView *uiMovingBG;


@end;
@implementation SlideToCall

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.uiDefaultBG.alpha = 1.0;
    self.uiMovingBG.alpha = 0.0;
    
    _defaultFrame = self.uiMovingView.frame;
}

- (void)setDefaultState:(BOOL)animated
{
    if (!animated) {
        self.uiMovingView.frame = _defaultFrame;
        self.uiMovingBG.alpha = 0.0;
        self.uiDefaultBG.alpha = 1.0;
    } else{
        [UIView animateWithDuration:0.33
                         animations:^{
                             self.uiMovingView.frame = _defaultFrame;
                             self.uiMovingBG.alpha = 0.0;
                             self.uiDefaultBG.alpha = 1.0;
                         } completion:nil];
    }
    
}

- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

- (IBAction)actHandlePan:(UIPanGestureRecognizer *)panGesture
{
    CGFloat velocity = [panGesture velocityInView:[panGesture.view superview]].x;
    CGFloat translation = [panGesture translationInView:self.uiMovingView].x;
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:

            
            break;
            
        case UIGestureRecognizerStateChanged:{
            CGFloat newPosition = _defaultFrame.origin.x + translation;
            if (newPosition + _defaultFrame.size.width > self.width) {
                translation = self.width - _defaultFrame.size.width;
            } else if (newPosition < 0) {
                translation = 0;
            }
            self.uiMovingView.frame = CGRectOffset(_defaultFrame, translation, 0.0);
            self.uiMovingBG.alpha = translation / (self.width - _defaultFrame.size.width);
            self.uiDefaultBG.alpha = 1 - self.uiMovingBG.alpha;
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            if (velocity > kSwipeVelocity || translation >= self.width - _defaultFrame.size.width){
                if ([self.delegate respondsToSelector:@selector(makeCallOnComplete:)]) {
                    [self.delegate makeCallOnComplete:^(){
                        [UIView animateWithDuration:0.1
                                         animations:^{
                                             self.uiMovingView.frame = CGRectOffset(_defaultFrame, self.width - _defaultFrame.size.width, 0.0);
                                             self.uiMovingBG.alpha = 1.0;
                                             self.uiDefaultBG.alpha = 0.0;
                                         } completion:^(BOOL finished){
                                             [self setDefaultState:YES];
                                         }];
                    }];
                }
                
            } else {
                [self setDefaultState:YES];
            }
            break;
            
        default:
            break;
    }
}


@end
