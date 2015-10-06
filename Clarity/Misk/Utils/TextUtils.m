//
//  TextUtils.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/16/14.
//
//

#import "TextUtils.h"

@implementation TextUtils

+ (NSSet *)extractComponentsInText:(NSString *)text
    withPattern:(NSString *)pattern
    removeFirstChar:(BOOL)removeFirstChar
{
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:0
                                                                        error:nil];
    
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    NSMutableSet *componets = [NSMutableSet set];
    
    for (NSTextCheckingResult *cr in matches) {
        NSRange range =
            removeFirstChar
        ?   NSMakeRange(cr.range.location + 1, cr.range.length - 1)
        :   NSMakeRange(cr.range.location, cr.range.length);
    
        [componets addObject:[text substringWithRange:range]];
    }
    
    return componets;
}

+ (NSSet *)extractUrlParamNames:(NSString *)url
{
    return [self extractComponentsInText:url
                             withPattern:@":[a-z0-9_]+"
                         removeFirstChar:YES];
}

+ (NSString *)getCachesDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (NSString *)getAppSupportDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (NSString *)getTempDir
{
    return NSTemporaryDirectory();
}

+ (NSString *)shorterNumber:(NSInteger)inputInt
{
    if (inputInt > 999) {
        if (inputInt%1000 == 0 | inputInt%1000 < 100) {
            return [NSString stringWithFormat:@"%ldk", (long)(inputInt/1000)];
        } else {
            NSInteger skipedNN = inputInt / 100;
            float r = skipedNN / 10.f;
            NSNumber *decimal = [NSNumber numberWithFloat:r];
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [formatter setRoundingMode:NSNumberFormatterRoundHalfEven];
            [formatter setPositiveFormat:@"0.#k"];
            return [formatter stringFromNumber:decimal];
        }
    }
    return [NSString stringWithFormat:@"%li", (long)inputInt];
}

+ (NSString *)validateUsernameRegexp
{
    return @"^[A-Za-z0-9\\.\\+@_-]+$";
}

@end
