//
//  UIColor+Utils.m
//  Brabble-iOSClient
//
//  Created by Alexey on 2/17/14.
//
//

#import "UIColor+Utils.h"
#import <Foundation/Foundation.h>

@implementation UIColor (Utils)

- (UIColor *)scaledColor:(CGFloat)scale
{
    CGFloat h = 0, s = 0, b = 0, a = 0;
    
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    
    return [UIColor colorWithHue:h saturation:s brightness:MIN(b * scale, 1.0f) alpha:a];
}

+ (UIColor *)tintColor
{
    return [UIColor colorWithRed:185.0f/255 green:36.0f/255 blue:45.0f/255 alpha:1];
}

+ (UIColor *)colorFromHex:(NSString *)hex
{
    return [self colorWithHexCode:hex alpha:1];
}

+ (UIColor *)colorWithHexCode:(NSString *)hex alpha:(CGFloat)kAlpha
{
    uint red = 0, green = 0, blue = 0, alpha = 0;
    
    if (hex.length == 7) {
        sscanf([hex UTF8String], "#%02X%02X%02X", &red, &green, &blue);
        return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:kAlpha];
    } else if (hex.length == 9) {
        sscanf([hex UTF8String], "#%02X%02X%02X%02X", &red, &green, &blue, &alpha);
    }
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

- (UIColor*)blackOrWhiteContrastingColor {
    UIColor *black = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    UIColor *white = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    float blackDiff = [self luminosityDifference:black];
    float whiteDiff = [self luminosityDifference:white];

    return (blackDiff > whiteDiff) ? black : white;
}

- (CGFloat)luminosity {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    
    BOOL success = [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    if (success) {
        return 0.2126 * pow(red, 2.2f) + 0.7152 * pow(green, 2.2f) + 0.0722 * pow(blue, 2.2f);
    }
        
    CGFloat white;
    
    success = [self getWhite:&white alpha:&alpha];
    if (success) {
        return pow(white, 2.2f);
    }
        
    return -1;
}

- (CGFloat)luminosityDifference:(UIColor*)otherColor {
    CGFloat l1 = [self luminosity];
    CGFloat l2 = [otherColor luminosity];
    
    if (l1 >= 0 && l2 >= 0) {
        if (l1 > l2) {
            return (l1+0.05f) / (l2+0.05f);
        } else {
            return (l2+0.05f) / (l1+0.05f);
        }
    }
    
    return 0.0f;
}

- (NSString *)hexString
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

@end
