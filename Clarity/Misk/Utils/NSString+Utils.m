//
//  NSString+Utils.m
//  Brabble-iOSClient
//
//  Created by Alexey on 4/6/14.
//
//

#import "NSString+Utils.h"
#import "NSArray+DB.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Utils)

- (BOOL)regexpMatch:(NSRegularExpression *)regex
{
    return [regex numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)] > 0;
}

- (NSString *)MD5String
{
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSString *)secureString
{
    NSMutableString *dotString = [NSMutableString new];
    for(int i = 0; i<self.length; i++){
        [dotString appendString:@"•"];
    }
    return dotString;
}

- (NSString *)nameString
{
    NSMutableArray *strings = [[NSMutableArray alloc] initWithArray:[[self.lowercaseString trim] componentsSeparatedByString:@" "]];
    if (!strings.count) {
        return self.capitalizedString;
    }
    [strings replaceObjectAtIndex:0 withObject:((NSString  *)strings.firstObject).capitalizedString];
    [strings replaceObjectAtIndex:strings.count-1 withObject:((NSString  *)strings.lastObject).capitalizedString];
    return [strings componentsJoinedByString:@" "];
}

- (NSString *)nameFirstWord
{
    NSMutableArray *strings = [[NSMutableArray alloc] initWithArray:[[self trim] componentsSeparatedByString:@" "]];
    if (!strings.count) {
        return self;
    }
    return strings.firstObject;
}

- (CGFloat)widthWithFont:(UIFont *)font
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:self
                                                              attributes:@{NSFontAttributeName : font}];
    return ceilf([str size].width);
}

- (CGFloat)heightWithFont:(UIFont *)font forWidth:(CGFloat)width
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:self
                                                              attributes:@{NSFontAttributeName : font}];
    
    CGRect rc = [str boundingRectWithSize:CGSizeMake(width, 8000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return ceil(rc.size.height);
}

- (CGFloat)heightWithFont:(UIFont *)font forWidth:(CGFloat)width forMaxHeight:(CGFloat) maxHeight
{
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:self
                                                              attributes:@{NSFontAttributeName : font}];
    
    CGRect rc = [str boundingRectWithSize:CGSizeMake(width, maxHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return ceil(rc.size.height);
}

+ (NSString *)calcUsernamesStringForWidth:(CGFloat)width
                                   height:(CGFloat)height
                                     tail:(NSString*)tail
                                     font:(UIFont *)font
                                    users:(NSArray *)users
                            maxUsersCount:(NSUInteger)maxCount
{
    if (users.count == 0) {
        return @"";
    }
    
    NSString *approxTail = [NSString stringWithFormat:@", + xxx %@", tail];
    const CGFloat approxTailWidth = [approxTail widthWithFont:font];
    NSMutableArray *usernames = [NSMutableArray array];
    
    [usernames addObject:[NSString stringWithFormat:@"@%@", [users objectAtIndex:0]]];
    
    for (NSUInteger i = 1; i < users.count; i++) {
        if (i == maxCount) {
            break;
        }
        NSString *userName = [NSString stringWithFormat:@"@%@", users[i]];
        CGFloat ff = [[usernames joinBy:@", "] widthWithFont:font] + [userName widthWithFont:font] + approxTailWidth;
        if (ff >= width) {
            break;
        }
        [usernames addObject:userName];
    }
    
    NSMutableString *result = [NSMutableString stringWithString:[usernames joinBy:@", "]];
    
    if (usernames.count < [users count]) {
        [result appendFormat:@", +%lu %@", (unsigned long)([users count] - usernames.count), tail];
    }
    
    return result;
}

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)trimInChanging
{
    BOOL saveSpace = self.length>1 && [[self substringFromIndex:self.length-1] isEqualToString:@" "];
    NSString *result = [self trim];
    if (saveSpace) {
        result = [NSString stringWithFormat:@"%@ ", [self trim]];
    }
    return result;
}

- (UniqueString *)uniqueString
{
    return [[UniqueString alloc] initWithString:self];
}

- (BOOL)hasSubstring:(NSString *)substring
{
    return [self rangeOfString:substring].location != NSNotFound;
}

- (BOOL)isValidEmail
{
    if (self.length == 0) {
        return NO;
    } else if (![self validateWithRegex: @"^[A-Z0-9a-z]+([._-][A-Z0-9a-z]+)*@[A-Za-z0-9]+([.-][A-Za-z0-9]+)*\\.[A-Za-z]{2,6}$"]) {
        return NO;
    }
    return YES;
}

- (NSString *)validateEmail
{
    /*Old regex
     ^[A-Z0-9a-z]+[A-Z0-9a-z._-]{1,19}@[A-Za-z0-9]+([.-]*[A-Za-z0-9]+){1,12}\\.[A-Za-z]{2,6}$
     */
    NSString *errorDescription = nil;
    if (self.length == 0) {
        errorDescription = NSLocalizedString(@"Missing Information:\nPlease enter your e-mail address.", nil);
    } else if (![self validateWithRegex:@"^[A-Z0-9a-z]+([._-][A-Z0-9a-z]+)*@[A-Za-z0-9]+([.-][A-Za-z0-9]+)*\\.[A-Za-z]{2,6}$"]) {
        errorDescription = NSLocalizedString(@"Please enter a valid e-mail address.", nil);
    }
    return errorDescription;
}

- (NSString *)validatePass
{
    const int minPassLength = 5;
    const int maxPassLength = 20;
    NSString *errorDescription = nil;
    if (self.length == 0) {
        errorDescription = NSLocalizedString(@"Missing Information:\nPlease enter your password.", nil);
    } else if (self.length < minPassLength) {
        errorDescription = NSLocalizedString(@"Password is too short.", nil);
    } else if (self.length > maxPassLength) {
        errorDescription = NSLocalizedString(@"Password is too long.", nil);
    } else {
         NSString *regex = [NSString stringWithFormat:@"[A-Z0-9a-z]{%d,%d}$", minPassLength, maxPassLength];
        if (![self validateWithRegex:regex]) {
            errorDescription = NSLocalizedString(@"Password contains restricted symbols.", nil);
        }
    }
    
    return errorDescription;
}

- (NSString *)validateAuthorizationKey
{
    const int authorizationKeyLength = 7;
    NSString *errorDescription = nil;
    if (self.length == 0) {
        errorDescription = NSLocalizedString(@"Missing Information:\nPlease enter your authorization key.", nil);
    } else if (self.length < authorizationKeyLength || self.length > authorizationKeyLength) {
        errorDescription = NSLocalizedString(@"Authorization key must be a 7 characters long.", nil);
    } else {
        NSString *regex = [NSString stringWithFormat:@"[0-9]{%d,%d}$", authorizationKeyLength, authorizationKeyLength];
        if (![self validateWithRegex:regex]) {
            errorDescription = NSLocalizedString(@"Key must be 7 digits.", nil);
        }
    }
    
    return errorDescription;
}

- (NSString *)validatePin
{
    const int pinLength = 4;
    NSString *errorDescription = nil;
    if (self.length == 0) {
        errorDescription = NSLocalizedString(@"Missing Information:\nPlease enter a 4-digit PIN code.", nil);
    } else if (self.length < pinLength || self.length > pinLength) {
        errorDescription = NSLocalizedString(@"PIN code must be 4-digits.\nPlease try again.", nil);
    } else {
        NSString *regex = [NSString stringWithFormat:@"[0-9]{%d,%d}$", pinLength, pinLength];
        if (![self validateWithRegex:regex]) {
            errorDescription = NSLocalizedString(@"PIN code must be 4-digits.\nPlease try again.", nil);
        }
    }
    
    return errorDescription;
}

- (NSString *)validateFullNameWithMaxLength:(NSInteger)maxLength
{
    NSString *errorDescription = nil;
    if (self.length < 2) {
        errorDescription = NSLocalizedString(@"Full name is too small.", nil);
    } else if (self.length > maxLength) {
        errorDescription = NSLocalizedString(@"Full name is too long.", nil);
    } else {
        NSString *regex = [NSString stringWithFormat:@"[A-Z0-9a-z\\s'\"_-]{2,%d}$", maxLength];
        if (![self validateWithRegex:regex]) {
            errorDescription = NSLocalizedString(@"Full name is incorrect.", nil);
        }
    }
    return errorDescription;
}

- (NSString *)validateStreet
{
    NSString *errorDescription = nil;
    if (self.length == 0) {
        errorDescription = NSLocalizedString(@"Missing Information:\nPlease enter street name.", nil);
    } else if (self.length < 2) {
        errorDescription = NSLocalizedString(@"Street address must be 2 or more characters.\nPlease try again.", nil);
    } else if (self.length > 30) {
        errorDescription = NSLocalizedString(@"Street address must be 30 or less characters.\nPlease try again.", nil);
    }
    return errorDescription;
}

- (NSString *)validateCity
{
    NSString *errorDescription = nil;
    if (self.length == 0) {
        errorDescription = NSLocalizedString(@"Missing Information:\nPlease enter city name.", nil);
    } else if (self.length < 3) {
        errorDescription = NSLocalizedString(@"City name must be 3 or more characters.\nPlease try again.", nil);
    } else if (self.length > 30) {
        errorDescription = NSLocalizedString(@"City name must be 30 or less characters.\nPlease try again.", nil);
    }
    return errorDescription;
}

- (NSString *)validateZip
{
    const int zipLength = 5;
    NSString *errorDescription = nil;
    if (self.length == 0) {
        errorDescription = NSLocalizedString(@"Missing Information:\nPlease enter zip code.", nil);
    } else if (self.length < zipLength || self.length > zipLength) {
        errorDescription = NSLocalizedString(@"Zip code must be 5-digits.\nPlease try again.", nil);
    } else {
        NSString *regex = [NSString stringWithFormat:@"[0-9]{%d,%d}$", zipLength, zipLength];
        if (![self validateWithRegex:regex]) {
            errorDescription = NSLocalizedString(@"Zip code must be 5-digits.\nPlease try again.", nil);
        }
    }
    
    return errorDescription;
}

- (NSString *)validateTextView
{
    NSString *errorDescription = nil;
    if (self.length < 2 && self.length != 0) {
        errorDescription = NSLocalizedString(@"Full name is too small.", nil);
    }
    
    return errorDescription;
}

- (BOOL)validateWithRegex:(NSString *)regex
{
    NSPredicate *validateTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [validateTest evaluateWithObject:self];
}
@end
