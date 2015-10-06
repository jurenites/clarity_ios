//
//  DateUtils.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/12/14.
//
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

+ (NSString *)timeSince:(NSDate *)date;
+ (NSString *)chatTimeSins:(NSDate *)date;

@end
