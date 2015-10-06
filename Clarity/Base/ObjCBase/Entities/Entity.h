//
//  ApiStruct.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/9/13.
//
//

#import <Foundation/Foundation.h>
#import "NSObject+Api.h"
#import "NSString+Utils.h"
#import "UniqueObject.h"

@interface Entity : UniqueObject

- (void)fillWithApiDict:(NSDictionary *)d;

+ (NSArray *)fromApiArray:(NSArray *)apiArray objClass:(Class)objClass;

@end
