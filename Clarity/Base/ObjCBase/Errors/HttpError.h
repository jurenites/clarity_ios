//
//  HttpError.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/19/14.
//
//

#import "Error.h"

@interface HttpError : Error

+ (instancetype)errorWithCode:(NSInteger)code;

@end
