//
//  ApiError.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/17/14.
//
//

#import "ApiError.h"

static NSDictionary *ErrorsMap = nil;

@implementation ApiError

+ (instancetype)errorWithCode:(NSInteger)code descr:(NSString *)descr
{
    static NSDictionary *errors = nil;
    
    if (!errors) {
        errors = @{
            //Server error
            @(500)  : NSLocalizedString(@"Something went wrong. Please try again.", nil),
            
            //Api Error
            @(1000)  : NSLocalizedString(@"Invalid request", nil),
            @(1001)  : NSLocalizedString(@"Token is invalid", nil),
            @(1002)  : NSLocalizedString(@"Please update your app", nil), //Same to 50000
            @(1003)  : NSLocalizedString(@"Access denied", nil),
            
            @(2000)  : NSLocalizedString(@"Resource not found.", nil),
            
            @(3000)  : NSLocalizedString(@"User not found.", nil),
            @(3001)  : NSLocalizedString(@"This e-mail address already exists.", nil),
            @(3003)  : NSLocalizedString(@"Invalid email", nil),
            @(3004)  : NSLocalizedString(@"Password is invalid", nil),
            @(3005)  : NSLocalizedString(@"Account is disabled", nil),
            @(3006)  : NSLocalizedString(@"This Specialist has already been registered, please proceed to the login screen.", nil),
            @(3007)  : NSLocalizedString(@"Authorization key doesn't match the email address or your account is not approved yet. Please contact TRN for assistance.", nil),
            
            @(4000)  : NSLocalizedString(@"Session not found", nil),
            @(4001)  : NSLocalizedString(@"Has a booked session", nil),
            @(4002)  : NSLocalizedString(@"Session is already booked", nil),
            @(4003)  : NSLocalizedString(@"Session token expired", nil),
            @(4004)  : NSLocalizedString(@"Payment cannot be processed.  Please check your credit card information or add a new card.", nil),
            @(4005)  : NSLocalizedString(@"Incorrect time", nil),
            @(4006)  : NSLocalizedString(@"Schedule block exists.", nil),
            @(4007)  : NSLocalizedString(@"Schedule block has sessions. Cannot be deleted", nil),
            
            @(5000)  : NSLocalizedString(@"Region is empty", nil),
            @(5001)  : NSLocalizedString(@"This promo code is not valid for your location.", nil),
            
            @(6000)  : NSLocalizedString(@"This promo code has expired.", nil),
            @(6001)  : NSLocalizedString(@"Inactive promo.", nil),
            @(6002)  : NSLocalizedString(@"This promo code is invalid.", nil),
            @(6003)  : NSLocalizedString(@"You have already used this promo code.", nil),
            @(6004)  : NSLocalizedString(@"This promo code is not valid for your location.", nil),
            @(6005)  : NSLocalizedString(@"This promo code is not valid for your region.", nil),
            @(6006)  : NSLocalizedString(@"Max count promo", nil),
            @(6007)  : NSLocalizedString(@"This promo is not valid.", nil),
            
            @(50000)  : NSLocalizedString(@"Please update your app", nil) //still hold this
            };
    }
    
    return [super errorWithCode:code
                          descr:(errors[@(code)] ? errors[@(code)] : descr.length ? descr : @"No description")];
}

- (ErrorType)type
{
    return ErrorTypeApi;
}

@end
