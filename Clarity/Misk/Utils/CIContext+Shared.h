//
//  Shared.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 12/3/13.
//
//

#import <CoreImage/CoreImage.h>

@interface CIContext (Shared)

+ (CIContext *)shared;
+ (CIContext *)sharedSoftware;

@end
