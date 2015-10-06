//
//  DeviceHardware.m
//  TRN
//
//  Created by stolyarov on 19/11/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//
#import "DeviceHardware.h"
#include <sys/types.h>
#include <sys/sysctl.h>

static int const CropImageSizeLimit4thIpod = 20;
static int const CropImageSizeLimit4thIphone5thIpod = 40;
static int const CropImageSizeLimit5thIphone = 80;

@implementation DeviceHardware

+ (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

+ (NSString *) platformString{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad-3G (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad-3G (4G)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad-3G (4G)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad-4G (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad-4G (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad-4G (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad mini-1G (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad mini-1G (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad mini-1G (GSM+CDMA)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

+(float) platformScore {
    // This is a semi-arbitraty point system, but it sorta reflects the level of hardware on the device
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return 1.0;
    if ([platform isEqualToString:@"iPod1,1"])      return 1.0;
    if ([platform isEqualToString:@"iPad1,1"])      return 1.0;
    if ([platform isEqualToString:@"iPhone1,2"])    return 2.0;
    if ([platform isEqualToString:@"iPod2,1"])      return 2.0;
    if ([platform isEqualToString:@"iPad2,1"])      return 2.0;
    if ([platform isEqualToString:@"iPad2,2"])      return 2.0;
    if ([platform isEqualToString:@"iPad2,3"])      return 2.0;
    if ([platform isEqualToString:@"iPad2,4"])      return 2.0;
    if ([platform isEqualToString:@"iPod3,1"])      return 3.0;
    if ([platform isEqualToString:@"iPhone2,1"])    return 3.0;
    if ([platform isEqualToString:@"iPhone3,1"])    return 4.0;
    if ([platform isEqualToString:@"iPhone3,3"])    return 4.0;
    if ([platform isEqualToString:@"iPod4,1"])      return 4.0;
    if ([platform isEqualToString:@"iPad3,1"])      return 4.0;
    if ([platform isEqualToString:@"iPad3,2"])      return 4.0;
    if ([platform isEqualToString:@"iPad3,3"])      return 4.0;
    if ([platform isEqualToString:@"iPad2,5"])      return 4.0;
    if ([platform isEqualToString:@"iPad2,6"])      return 4.0;
    if ([platform isEqualToString:@"iPad2,7"])      return 4.0;
    if ([platform isEqualToString:@"iPad3,4"])      return 4.5;
    if ([platform isEqualToString:@"iPad3,5"])      return 4.5;
    if ([platform isEqualToString:@"iPad3,6"])      return 4.5;
    if ([platform isEqualToString:@"iPhone4,1"])    return 4.5;
    if ([platform isEqualToString:@"iPhone5,1"])    return 5.0;
    if ([platform isEqualToString:@"iPhone5,2"])    return 5.0;
    if ([platform isEqualToString:@"iPod5,1"])      return 5.0;
    
    
    if ([platform isEqualToString:@"i386"])         return 0;
    if ([platform isEqualToString:@"x86_64"])       return 0;
    
    return 5.0;
}

+ (float)memoryScore
{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return 1.0;
    if ([platform isEqualToString:@"iPod1,1"])      return 1.0;
    if ([platform isEqualToString:@"iPad1,1"])      return 1.0;
    if ([platform isEqualToString:@"iPhone1,2"])    return 2.0;
    if ([platform isEqualToString:@"iPod2,1"])      return 2.0;
    if ([platform isEqualToString:@"iPad2,1"])      return 2.0;
    if ([platform isEqualToString:@"iPad2,2"])      return 2.0;
    if ([platform isEqualToString:@"iPad2,3"])      return 2.0;
    if ([platform isEqualToString:@"iPad2,4"])      return 2.0;
    if ([platform isEqualToString:@"iPod3,1"])      return 3.0;
    if ([platform isEqualToString:@"iPhone2,1"])    return 3.0;
    if ([platform isEqualToString:@"iPod4,1"])      return 3.0;
    if ([platform isEqualToString:@"iPhone3,1"])    return 4.0;
    if ([platform isEqualToString:@"iPhone3,3"])    return 4.0;
    if ([platform isEqualToString:@"iPad3,1"])      return 4.0;
    if ([platform isEqualToString:@"iPad3,2"])      return 4.0;
    if ([platform isEqualToString:@"iPad3,3"])      return 4.0;
    if ([platform isEqualToString:@"iPad2,5"])      return 4.0;
    if ([platform isEqualToString:@"iPad2,6"])      return 4.0;
    if ([platform isEqualToString:@"iPad2,7"])      return 4.0;
    if ([platform isEqualToString:@"iPhone4,1"])    return 4.0;
    if ([platform isEqualToString:@"iPod5,1"])      return 4.0;
    if ([platform isEqualToString:@"iPad3,4"])      return 5.0;
    if ([platform isEqualToString:@"iPad3,5"])      return 5.0;
    if ([platform isEqualToString:@"iPad3,6"])      return 5.0;
    if ([platform isEqualToString:@"iPhone5,1"])    return 5.0;
    if ([platform isEqualToString:@"iPhone5,2"])    return 5.0;
    
    if ([platform isEqualToString:@"i386"])         return 0;
    if ([platform isEqualToString:@"x86_64"])       return 0;
    
    return 5.0;
}

+(int)photoSizeLimit
{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return 0;
    if ([platform isEqualToString:@"iPod1,1"])      return 0;
    if ([platform isEqualToString:@"iPad1,1"])      return 0;
    if ([platform isEqualToString:@"iPhone1,2"])    return 0;
    if ([platform isEqualToString:@"iPod2,1"])      return 0;
    if ([platform isEqualToString:@"iPad2,1"])      return 0;
    if ([platform isEqualToString:@"iPad2,2"])      return 0;
    if ([platform isEqualToString:@"iPad2,3"])      return 0;
    if ([platform isEqualToString:@"iPad2,4"])      return 0;
    if ([platform isEqualToString:@"iPod3,1"])      return CropImageSizeLimit4thIpod;
    if ([platform isEqualToString:@"iPhone2,1"])    return CropImageSizeLimit4thIpod;
    if ([platform isEqualToString:@"iPod4,1"])      return CropImageSizeLimit4thIpod;
    if ([platform isEqualToString:@"iPhone3,1"])    return CropImageSizeLimit4thIphone5thIpod;
    if ([platform isEqualToString:@"iPhone3,3"])    return CropImageSizeLimit4thIphone5thIpod;
    if ([platform isEqualToString:@"iPad3,1"])      return CropImageSizeLimit4thIphone5thIpod;
    if ([platform isEqualToString:@"iPad3,2"])      return CropImageSizeLimit4thIphone5thIpod;
    if ([platform isEqualToString:@"iPad3,3"])      return CropImageSizeLimit4thIphone5thIpod;
    if ([platform isEqualToString:@"iPad2,5"])      return CropImageSizeLimit4thIphone5thIpod;
    if ([platform isEqualToString:@"iPad2,6"])      return CropImageSizeLimit4thIphone5thIpod;
    if ([platform isEqualToString:@"iPad2,7"])      return CropImageSizeLimit4thIphone5thIpod;
    if ([platform isEqualToString:@"iPhone4,1"])    return CropImageSizeLimit4thIphone5thIpod;
    if ([platform isEqualToString:@"iPod5,1"])      return CropImageSizeLimit4thIphone5thIpod;
    
    if ([platform isEqualToString:@"i386"])         return 0;
    if ([platform isEqualToString:@"x86_64"])       return 0;
    
    return CropImageSizeLimit5thIphone;
}

+ (BOOL)phone4S
{
    return [[self platform] isEqualToString:@"iPhone4,1"];
}

+ (BOOL)phone4AndLower
{
    return [self platformScore] < 4.49f;
}

+ (BOOL)lowerThaniOS7
{
    return [UIDevice currentDevice].systemVersion.floatValue < 6.99f;
}

+ (BOOL)lowerThaniOS8
{
    return [UIDevice currentDevice].systemVersion.floatValue < 7.99f;
}


+ (BOOL)iOS8AndHiger
{
    return [UIDevice currentDevice].systemVersion.floatValue > 7.99f;
}

+ (BOOL)phone5Screen
{
    return [UIScreen mainScreen].bounds.size.height > 567;
}

+ (BOOL)canCropImage:(UIImage *)image
{
    int sizeMeg = (image.size.height * image.size.width * 4) / (1024 * 1024);
    if ([self photoSizeLimit] < sizeMeg) {
        return NO;
    }
    
    return YES;
}

+ (BOOL)isIpad
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

+ (BOOL)isIphone
{
    return [[UIDevice currentDevice].model isEqualToString:@"iPhone"];
}

@end
