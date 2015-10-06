//
//  TextUtils.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/16/14.
//
//

#import <Foundation/Foundation.h>

@interface TextUtils : NSObject

+ (NSSet *)extractUrlParamNames:(NSString *)url;

+ (NSString *)getCachesDir;
+ (NSString *)getAppSupportDir;
+ (NSString *)getTempDir;

+ (NSString *)shorterNumber:(NSInteger)inputInt;

+ (NSString *)validateUsernameRegexp;

@end
