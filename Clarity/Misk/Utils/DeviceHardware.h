//
//  DeviceHardware.h
//  TRN
//
//  Created by stolyarov on 19/11/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceHardware : NSObject

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

+ (BOOL)phone5Screen;

+ (BOOL)canCropImage:(UIImage *)image;

@end
