//
//  ApiCancelerFlag.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/28/14.
//
//

#import "ApiCancelerImplAbstract.h"

@interface ApiCancelerFlag : ApiCancelerImplAbstract

@property (readonly, atomic) BOOL isCanceled;

@end
