//
//  UniqueString.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 6/4/14.
//
//

#import "NonTypedUniqueObject.h"

@interface UniqueString : NonTypedUniqueObject

- (instancetype)initWithString:(NSString *)string;

@property (readonly, nonatomic) NSString *string;

@end
