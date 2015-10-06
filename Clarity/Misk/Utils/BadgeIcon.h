//
//  BadgeIcon.h
//  StaffApp
//
//  Created by Oleg Kasimov on 7/8/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadgeIcon : UIImage

//+ (UIImage *)drawText:(NSString *)text
//             withFont:(UIFont *)font
//             withHorizontalPading:(float)horizontalPadding
//             withVerticalPadding:(float)verticalPadding
//             withBorder:(BOOL)withBorder
//             withBackgroundColor:(UIColor*)backgroundColor;

+ (UIImage *)drawNumber:(NSNumber *)number
                 inSize:(CGSize)size
               withFont:(UIFont *)font
          withTextColor:(UIColor*)tColor
    withBackgroundColor:(UIColor *)backColor
         andBorderColor:(UIColor *)borderColor;

+ (UIImage *)withRadius:(float)radius;

@end
