//
//  UIView+Utils.h
//  TRN
//
//  Created by stolyarov on 19/11/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Utils)

+  (void)placeholderTransition:(UIImageView *)placeholder
                     imageView:(UIImageView *)imageView
                         image:(UIImage *)image
                      animated:(BOOL)animated;

- (NSArray *)constaintsForAttribute:(NSLayoutAttribute)attribute;
- (NSLayoutConstraint *)constraintForAttribute:(NSLayoutAttribute)attribute;
- (id)cloneView;

- (UIView *)findFirstResponder;

@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (readonly, nonatomic) CGFloat right;
@property (readonly, nonatomic) CGFloat bottom;

@end
