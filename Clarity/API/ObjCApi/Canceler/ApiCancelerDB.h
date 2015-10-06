//
//  ApiCancelerDB.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/10/14.
//
//

#import "ApiCancelerImplAbstract.h"

@class ApiManager;

@interface ApiCancelerDB : ApiCancelerImplAbstract

- (instancetype)initWithApiManager:(ApiManager *)apm
                         dbManager:(const void *)dbManager
                             reqId:(UniqueNumber *)reqId;

@end
