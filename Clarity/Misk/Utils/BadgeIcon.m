//
//  BadgeIcon.m
//  StaffApp
//
//  Created by Oleg Kasimov on 7/8/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "BadgeIcon.h"
#define SYSTEM_VERSION_EQUAL_OR_GREATER_7 ([UIDevice currentDevice].systemVersion.floatValue > 6.99f)

@implementation BadgeIcon

//+ (UIImage *)drawText:(NSString *)text
//             withFont:(UIFont *)font
//             withHorizontalPading:(float)horizontalPadding
//             withVerticalPadding:(float)verticalPadding
//             withBorder:(BOOL)withBorder
//             withBackgroundColor:(UIColor *)backgroundColor
//{
//    float textWidth;
//    float textHeight;
//    if (SYSTEM_VERSION_EQUAL_OR_GREATER_7) {
//        CGRect rect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
//                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                      attributes:@{NSFontAttributeName:font}
//                                         context:nil];
//        textWidth = ceilf(rect.size.width);
//        textHeight = ceilf(rect.size.height);
//    } else {
//        CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
//        textWidth = size.width;
//        textHeight = size.height;
//    }
//    
//    CGRect textRect = CGRectMake(horizontalPadding,  verticalPadding, textWidth, textHeight);
//    CGSize sizeImage = CGSizeMake(2 * horizontalPadding + textWidth,
//                                  2 * verticalPadding + textHeight);
//    
//    sizeImage.width = (text && text.length == 1) ? sizeImage.height : sizeImage.width;
//    textRect.origin.x = sizeImage.width / 2.0 - textRect.size.width / 2.0;
//    
//    sizeImage.width = (!text || text.length == 0) ? 0 : sizeImage.width;
//    
//    float scale = [UIScreen mainScreen].scale;
//    
//    float cornerRadius = sizeImage.height / 2.0;
//    
//    if (MIN(sizeImage.width, sizeImage.height) == 0) {
//        return nil;
//    }
//    
//    UIGraphicsBeginImageContextWithOptions(sizeImage, NO, scale);
//    
//    CGRect finalRect = CGRectMake(0, 0, sizeImage.width, sizeImage.height);
//    
//    //for correct stroke width
//    if (withBorder) {
//        float lineWidth  = 0.5;
//        finalRect.size.width -= lineWidth * 2.0;
//        finalRect.size.height -= lineWidth * 2.0;
//        finalRect.origin.x += lineWidth / 2.0;
//        finalRect.origin.y += lineWidth / 2.0;
//    }
//    
//    UIBezierPath *path;
//    
//    path = [UIBezierPath bezierPathWithRoundedRect:finalRect cornerRadius:cornerRadius];
//    
//    if (backgroundColor) {
//        [backgroundColor setFill];
//    }
//    else {
//        [[UIColor redColor] setFill];//Default Red
//    }
//    
//    [path fill];
//    
//    if (withBorder) {
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
//        CGContextSetLineWidth(context, 0.5f);
//        
//        CGContextAddPath(context, path.CGPath);
//        CGContextStrokePath(context);
//    }
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    //set text
//    UIGraphicsBeginImageContextWithOptions(sizeImage, NO, scale);
//    
//    [image drawInRect:CGRectMake(0, 0, sizeImage.width,sizeImage.height)];
//    
//    if (SYSTEM_VERSION_EQUAL_OR_GREATER_7) {
//        [text drawInRect:textRect withAttributes:@{NSFontAttributeName:font,
//                                                   NSForegroundColorAttributeName:[UIColor whiteColor]}];
//    } else {
//        [[UIColor whiteColor] set];
//        [text drawInRect:textRect withFont:font];
//    }
//    
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    return newImage;
//}

+ (UIImage *)drawNumber:(NSNumber *)number
                 inSize:(CGSize)size
               withFont:(UIFont *)font
          withTextColor:(UIColor*)tColor
    withBackgroundColor:(UIColor *)backColor
         andBorderColor:(UIColor *)borderColor
{
    float wordSize = 0;

    CGRect rr = [@"0" boundingRectWithSize:size
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{
                                             NSFontAttributeName : font,
                                             NSForegroundColorAttributeName : tColor
                                             }
                                   context:nil];
    wordSize = rr.size.height;
    
    float scale = [UIScreen mainScreen].scale;
    float borderWidth = 2.0;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGSize badgeSize = size;
    if (borderColor) {
        CGRect backCircleRect = CGRectMake(0, 0, size.width, size.height);
        [borderColor setFill];
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:backCircleRect];
        [path fill];
        badgeSize = CGSizeMake(size.width - borderWidth, size.height - borderWidth);
    }
    
    
    CGRect badgeCircleRect = CGRectMake(borderColor?borderWidth/2 : 0,
                                        borderColor?borderWidth/2 : 0,
                                        badgeSize.width,
                                        badgeSize.height);
    
    [backColor setFill];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:badgeCircleRect];
    [path fill];
    
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    paragrapStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString *str =
    [[NSAttributedString alloc] initWithString:[number stringValue]
                                    attributes:@{
                                                 NSFontAttributeName : font,
                                                 NSForegroundColorAttributeName : tColor,
                                                 NSParagraphStyleAttributeName : paragrapStyle
                                                 }];
    
    [str drawInRect:CGRectMake(0, (size.height - wordSize)/2, size.width, wordSize)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)withRadius:(float)radius
{
    CGSize sizeImage = CGSizeMake(radius, radius);
    
    float scale = [UIScreen mainScreen].scale;
    
    UIGraphicsBeginImageContextWithOptions(sizeImage, NO, scale);
    
    CGRect rect = CGRectMake(0, 0, sizeImage.width, sizeImage.height);
    
    //for correct stroke width
    float lineWidth  = 1.0;
    rect.size.width -= lineWidth;
    rect.size.height -= lineWidth;
    rect.origin.x += lineWidth / 2.0;
    rect.origin.y += lineWidth / 2.0;
    
    UIBezierPath *path;
    
    path = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    [[UIColor clearColor] setFill];
    [path fill];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.8, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(context, 1.0f);
    
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
