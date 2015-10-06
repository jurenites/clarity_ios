//
//  UniqueNumber.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 6/4/14.
//
//

#import "NonTypedUniqueObject.h"

@interface UniqueNumber : NonTypedUniqueObject

- (instancetype)initWithNumber:(NSNumber *)num;

@property (readonly, nonatomic) NSNumber *number;

@end
