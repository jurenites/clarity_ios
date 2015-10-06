//
//  Shared.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 12/3/13.
//
//

#import "CIContext+Shared.h"

static CIContext * volatile SharedCtx = nil;
static CIContext * volatile SharedSoftwareCtx = nil;

@implementation CIContext (Shared)

+ (CIContext *)shared
{
    if (!SharedCtx) {
        @synchronized(self) {
            if (!SharedCtx) {
//                CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
//                SharedCtx = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace : (__bridge id)cs,
//                                                            kCIContextOutputColorSpace : (__bridge id)cs}];
                
                SharedCtx = [CIContext contextWithOptions:@{}];
            }
        }
    }

    return SharedCtx;
}

+ (CIContext *)sharedSoftware
{
    if (!SharedSoftwareCtx) {
        @synchronized(self) {
            if (!SharedSoftwareCtx) {
                SharedSoftwareCtx = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}];
            }
        }
    }
    
    return SharedSoftwareCtx;
}

@end
