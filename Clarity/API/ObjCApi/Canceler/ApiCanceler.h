//
//  ApiCanceller.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/12/13.
//
//

#import <Foundation/Foundation.h>
#import "IORequest.h"
#import "ApiCancelerImplAbstract.h"
#import "ApiCancelerIO.h"
#import "ApiCancelerDB.h"
#import "UniqueNumber.h"

@interface ApiCanceler : NSObject

- (instancetype)initEmpty;

- (instancetype)initWithGroup:(NSArray *)group;

- (instancetype)initWithImpl:(ApiCancelerImplAbstract *)impl;

- (instancetype)initWithApiManager:(ApiManager *)apm
                         ioManager:(const void *)ioManager
                             reqId:(UniqueNumber *)reqId;

- (instancetype)initWithApiManager:(ApiManager *)apm
                         dbManager:(const void *)dbManager
                             reqId:(UniqueNumber *)reqId;

@property (readonly, nonatomic) ApiCancelerImplAbstract *impl;
@property (strong, atomic) ApiCanceler *chained;

- (void)cancel;

@end
