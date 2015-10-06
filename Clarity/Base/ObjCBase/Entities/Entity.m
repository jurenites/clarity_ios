//
//  ApiStruct.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/9/13.
//
//

#import "Entity.h"

@implementation Entity

+ (NSArray *)fromApiArray:(NSArray *)apiArray objClass:(Class)objClass
{
    NSMutableArray *array = [NSMutableArray new];
    
    for (NSDictionary *d in AssureIsArray(apiArray)) {
        if ([d isKindOfClass:[NSDictionary class]]) {
            Entity *obj = [objClass new];
            [obj fillWithApiDict:d];
            [array addObject:obj];
        }
    }
    
    return array;
}

- (void)fillWithApiDict:(NSDictionary *)d
{
}

@end
