//
//  ApiCancelerIO.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/10/14.
//
//

#import "ApiCancelerImplAbstract.h"
#import "IORequest.h"
#import "UniqueNumber.h"

@class ApiManager;

@interface ApiCancelerIO : ApiCancelerImplAbstract

- (instancetype)initWithApiManager:(ApiManager *)apm
                         ioManager:(const void *)ioManager
                             reqId:(UniqueNumber *)reqId;

@end
