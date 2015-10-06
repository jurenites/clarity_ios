//
//  NSError+Brabble.h
//  Brabble-iOSClient
//
//  Created by Alexey on 4/6/14.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    ErrorTypeDefault,
    ErrorTypeApi,
    ErrorTypeInternal
} ErrorType;

@interface NSError (Brabble)

@property (readonly, nonatomic) ErrorType type;

@end
