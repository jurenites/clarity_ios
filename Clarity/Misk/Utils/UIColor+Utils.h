//
//  UIColor+Utils.h
//  Brabble-iOSClient
//
//  Created by Alexey on 2/17/14.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (Utils)

- (UIColor *)scaledColor:(CGFloat)scale;

- (UIColor*)blackOrWhiteContrastingColor;

+ (UIColor *)tintColor;

+ (UIColor *)colorFromHex:(NSString *)hex;

+ (UIColor *)colorWithHexCode:(NSString *)hex alpha:(CGFloat)kAlpha;

- (NSString *)hexString;
@end
