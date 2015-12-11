//
//  BBDeviceHardware.h
//  Brabble-iOSClient
//
//  Created by Justin Martin on 6/26/13.
//
//

#import <Foundation/Foundation.h>

@interface BBDeviceHardware : NSObject

+ (NSString *)platform;
+ (NSString *)platformString;

+ (BOOL)isIpad;
+ (BOOL)isIphone;

+ (float)platformScore;

+ (BOOL)phone4AndLower;

+ (BOOL)phone4S;

+ (BOOL)lowerThaniOS7;
+ (BOOL)lowerThaniOS8;
+ (BOOL)iOS8AndHiger;

+ (BOOL)lowerThaniOS9;

+ (BOOL)phone5Screen;

+ (BOOL)canCropImage:(UIImage *)image;

@end
