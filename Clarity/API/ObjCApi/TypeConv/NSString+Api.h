//
//  NSString+Api.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/8/13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Api)

- (NSDate *)dateValue;
- (NSDate *)dateTimeValue;

- (NSDate *)apiDateValue;


- (NSString *)stringValue;

- (NSString *)urlEncode;

- (NSString *)toYoutubeThumb;

- (NSDate *)dateValueInScheduleFormat;

@end
