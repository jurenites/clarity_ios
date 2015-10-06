//
//  CustomButton.m
//  TRN
//
//  Created by stolyarov on 04/12/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "CustomButton.h"

static const NSTimeInterval AnimationIval = 0.33f;
static const CGFloat TouchIndent = 50.0f;


@interface CustomButton ()
{
    UIColor *_defaultTitleColor;
    UIView *_tapOverlay;
    UIColor *_defaultBackgroundColor;
    UIActivityIndicatorView *_spinner;
}

@end


@implementation CustomButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    
    [self awakeFromNib];
    return self;
}

- (void)awakeFromNib
{
    _defaultBackgroundColor = self.backgroundColor;
    _defaultTitleColor = self.uiTitle.textColor;
    if (!self.highlightedColor) {
            self.highlightedColor = [UIColor colorWithWhite:0 alpha:0.3f];
        }
    
    if (!self.selectedTitleColor) {
        if (!_defaultTitleColor) {
            self.selectedTitleColor = [UIColor colorWithWhite:0 alpha:0.5f];
        } else {
            self.selectedTitleColor = [_defaultTitleColor colorWithAlphaComponent:0.7f];
        }
    }
    if (!self.selectedColor) {
        self.selectedColor = [UIColor clearColor];
    }
    
    if (!self.disableColor) {
        self.disableColor = [UIColor clearColor];
    }
    
    if (!self.disableTitleColor) {
        self.disableTitleColor = [UIColor lightGrayColor];
    }
        
    _tapOverlay = [[UIView alloc] initWithFrame:self.bounds];
    _tapOverlay.userInteractionEnabled = NO;
    _tapOverlay.backgroundColor = self.highlightedColor;
    _tapOverlay.alpha = 0;
    [self addSubview:_tapOverlay];
    
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_tapOverlay addSubview:_spinner];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _tapOverlay.frame = self.bounds;
    _spinner.center = CGPointMake(0.5f * _tapOverlay.frame.size.height, 0.5f * _tapOverlay.frame.size.height);
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.backgroundColor = selected ? self.selectedColor : _defaultBackgroundColor;
    self.uiTitle.textColor = selected ? self.selectedTitleColor : _defaultTitleColor;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self setUiForEnabled:enabled];
}

- (void)setUiForEnabled:(BOOL)enabled
{
    self.backgroundColor = enabled ? _defaultBackgroundColor : self.disableColor;
    self.uiTitle.textColor = enabled ? _defaultTitleColor : self.disableTitleColor;
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if (!_disabled) {
        [super sendAction:action to:target forEvent:event];
    }
}

- (void)setLoading:(BOOL)loading
{
    if (loading == _loading) {
        return;
    }
    
    if (loading) {
        _tapOverlay.userInteractionEnabled = YES;
        _tapOverlay.alpha = 1;
        [self bringSubviewToFront:_tapOverlay];
        [_spinner startAnimating];
    } else {
        [_spinner stopAnimating];
        _tapOverlay.alpha = 0;
        _tapOverlay.userInteractionEnabled = NO;
    }
    
    _loading = loading;
    
    [self setNeedsLayout];
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

- (void)highlight
{
    _tapOverlay.alpha = 1;
    self.uiTitle.highlighted = YES;
}

- (void)unHighlightAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:AnimationIval
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             if (!_loading) {
                                 _tapOverlay.alpha = 0;
                             }
                             self.uiTitle.highlighted = NO;
                         }completion:nil];
    } else {
        if (!_loading) {
            _tapOverlay.alpha = 0;
        }
        self.uiTitle.highlighted = NO;
    }
    
}

#pragma marka UIControl action
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_disabled) {
        return NO;
    }
    
    [self highlight];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint loc = [touch locationInView:self];
    CGPoint center = CGPointMake(0.5f * self.bounds.size.width, 0.5f * self.bounds.size.height);
    CGFloat radius = MAX(center.x, center.y);
    
    BOOL shouldContinue = sqrtf(powf(loc.x - center.x, 2) + powf(loc.y - center.y, 2)) < (radius + TouchIndent);
    
    if (!shouldContinue) {
        [self unHighlightAnimated:YES];
    }
    
    return shouldContinue;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self unHighlightAnimated:YES];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [self unHighlightAnimated:NO];
}



@end
