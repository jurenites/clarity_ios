//
//  SecurityHelper.h
//  TRN
//
//  Created by Oleg Kasimov on 11/24/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecurityHelper : NSObject

+ (NSString *)encryptString:(NSString *)aString;
+ (NSString *)decryptData:(NSData *)data;

@end
