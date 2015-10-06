//
//  UIView+Utils.m
//  TRN
//
//  Created by stolyarov on 19/11/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "UIView+Utils.h"

@implementation UIView (Utils)

+  (void)placeholderTransition:(UIImageView *)placeholder
                     imageView:(UIImageView *)imageView
                         image:(UIImage *)image
                      animated:(BOOL)animated
{
    imageView.hidden = image == nil;
    imageView.image = image;
    
    [placeholder.layer removeAllAnimations];
    [imageView.layer removeAllAnimations];
    
    if (animated && image) {
        imageView.alpha = 0;
        placeholder.hidden = NO;
        
        [UIView animateWithDuration:0.4f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             imageView.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 placeholder.hidden = YES;
                                 placeholder.opaque = YES;
                                 imageView.opaque = YES;
                             }
                         }
         ];
    } else {
        placeholder.hidden = !imageView.hidden;
        //        placeholder.opaque = YES;
        //        imageView.opaque = YES;
    }
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x
{
    self.frame = CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y
{
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}


- (NSArray *)constaintsForAttribute:(NSLayoutAttribute)attribute
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstAttribute = %d", attribute];
    NSArray *filteredArray = [[self constraints] filteredArrayUsingPredicate:predicate];
    
    return filteredArray;
}

- (NSLayoutConstraint *)constraintForAttribute:(NSLayoutAttribute)attribute
{
    NSArray *constraints = [self constaintsForAttribute:attribute];
    
    if (constraints.count) {
        return constraints[0];
    }
    
    return nil;
}

- (id)cloneView
{
    NSData *archivedViewData = [NSKeyedArchiver archivedDataWithRootObject: self];
    id clone = [NSKeyedUnarchiver unarchiveObjectWithData:archivedViewData];
    return clone;
}

- (UIView *)findFirstResponder
{
    if (self.isFirstResponder) {
        return self;
    }
    
    for (UIView *v in self.subviews) {
        UIView *fr = [v findFirstResponder];
        
        if (fr) {
            return fr;
        }
    }
    
    return nil;
}

- (CGFloat)right
{
    return self.x + self.width;
}

- (CGFloat)bottom
{
    return self.y + self.height;
}

@end
