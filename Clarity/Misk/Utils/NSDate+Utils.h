//
//  NSDate+Utils.h
//  TRN
//
//  Created by stolyarov on 03/02/2015.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Time.h"

@interface NSDate (Utils)
+ (NSDate *)localDate;

- (NSDate *)toApiDate;
- (NSString *)toApiString;
- (NSDate *)toLocalDate;

- (BOOL)isEqualDay:(NSDate *)date;
- (BOOL)isEqualDay:(NSDate *)date withCustomTimeZone:(NSTimeZone *)tz;

- (NSInteger)minutes;
- (NSInteger)seconds;

@end
