//
//  ApiCancelerImplAbstract.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/10/14.
//
//

#import <Foundation/Foundation.h>
#include "UniqueNumber.h"

@interface ApiCancelerImplAbstract : NSObject

- (void)cancel;
- (const void *)ioManager;
- (UniqueNumber *)requestId;

@end
