//
//  UIImage+Transform.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/5/14.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Transform)

+ (CGSize)convertSize:(CGSize)size forOrientation:(UIImageOrientation)orientation;
+ (CGFloat)angleForOrientation:(UIImageOrientation)orientation;
+ (CGAffineTransform)transform:(CGAffineTransform)transform withOrientation:(UIImageOrientation)orientation;

+ (UIImageOrientation)orientationForTransformYDown:(CGAffineTransform)transform;

+ (UIImageOrientation)orientationForTransform:(CGAffineTransform)transform;

+ (UIImageOrientation)orientationForTransform:(CGAffineTransform)transform isMirrored:(BOOL)mirrored;

+ (BOOL)isOrientationMirrored:(UIImageOrientation)orientation;

@end
