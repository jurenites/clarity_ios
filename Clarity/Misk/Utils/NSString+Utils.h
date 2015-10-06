//
//  NSString+Utils.h
//  Brabble-iOSClient
//
//  Created by Alexey on 4/6/14.
//
//

#import <Foundation/Foundation.h>
#import "UniqueString.h"

@interface NSString (Utils)

- (BOOL)regexpMatch:(NSRegularExpression *)regex;
- (NSString *)MD5String;

- (NSString *)secureString;

- (CGFloat)widthWithFont:(UIFont *)font;
- (CGFloat)heightWithFont:(UIFont *)font forWidth:(CGFloat)width;

- (CGFloat)heightWithFont:(UIFont *)font forWidth:(CGFloat)width forMaxHeight:(CGFloat) maxHeight;


+ (NSString *)calcUsernamesStringForWidth:(CGFloat)width
                                   height:(CGFloat)height
                                     tail:(NSString*)tail
                                     font:(UIFont *)font
                                    users:(NSArray *)users
                            maxUsersCount:(NSUInteger)maxCount;
- (NSString *)trim;
- (NSString *)trimInChanging;

- (BOOL)hasSubstring:(NSString *)substring;

- (BOOL)validateWithRegex:(NSString *)regex;

- (BOOL)isValidEmail;
- (NSString *)validateEmail;
- (NSString *)validatePass;
- (NSString *)validateAuthorizationKey;
- (NSString *)validatePin;
- (NSString *)validateStreet;
- (NSString *)validateCity;
- (NSString *)validateZip;

- (NSString *)validateFullNameWithMaxLength:(NSInteger)maxLength;
- (NSString *)validateTextView;

- (NSString *)nameString;
- (NSString *)nameFirstWord;

@property (readonly, nonatomic) UniqueString *uniqueString;

@end
