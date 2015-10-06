//
//  Error.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/5/14.
//
//

#import <Foundation/Foundation.h>
#import "NSError+Brabble.h"

@interface Error : NSError

+ (instancetype)errorWithCode:(NSInteger)code descr:(NSString *)descr;
+ (instancetype)errorWithDescr:(NSString *)descr;

- (void)raise;

@property (readonly, nonatomic) ErrorType type;

@end
