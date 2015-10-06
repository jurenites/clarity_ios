//
//  AlertView.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 11/10/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "AlertView.h"
//#import "AppDelegate.h"
#import "DeviceHardware.h"

@interface AlertView () <UIAlertViewDelegate>
{
    UIAlertView *_alertView;
    UIAlertController *_alertController;
    NSURL *_urlToOpen;
    BOOL _singleSignIn;
    AlertView *_loop;
    void(^_onComplete)(NSInteger clickedButtonIndex);
}
@end

@implementation AlertView

+ (NSString *)confirmationText
{
    return NSLocalizedString(@"To continue, you will be redirected to the browser.", nil);
}

+ (NSString *)videoConfirmationText
{
    return NSLocalizedString(@"To continue, you will be redirected to the video app.", nil);
}

- (void)hidePrev
{
    if (_alertView) {
        [_alertView dismissWithClickedButtonIndex:0 animated:NO];
        _alertView.delegate = nil;
        _alertView = nil;
        _loop = nil;
    }
}

- (void)showWithTitle:(NSString *)title
                 text:(NSString *)text
     cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSArray *)otherButtonTitles
           onComplete:(void(^)(NSInteger clickedButtonIndex))onComplete
{
    _onComplete = [onComplete copy];
    
    void(^actionBlock)(NSInteger) = ^(NSInteger index) {
        if (onComplete) {
            _onComplete(index);
        }
    };
    if ([DeviceHardware iOS8AndHiger]) {
        _alertController = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
        if (cancelButtonTitle.length > 0) {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                actionBlock(0);
            }];
            [_alertController addAction:cancelAction];
        }

        for (NSString *title in otherButtonTitles) {
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSInteger indexCorrection = cancelButtonTitle.length > 0 ? 1 : 0;
                actionBlock([otherButtonTitles indexOfObject:title]+indexCorrection);
            }];
            [_alertController addAction:otherAction];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            UIViewController *root = window.rootViewController;
            
            [root presentViewController:_alertController animated:YES completion:NULL];
        });
    } else {
        _alertView = [[UIAlertView alloc] initWithTitle:title message:text delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles: nil];
        
        for (NSString *title in otherButtonTitles) {
            [_alertView addButtonWithTitle:title];
        }
        
        
        _loop = self;
        
        [_alertView show];
    }
}

- (void)confirmOpenUrl:(NSURL *)url confirmationText:(NSString *)confirmationText singleSignIn:(BOOL)singleSignIn
{
    [self hidePrev];
    
    _urlToOpen = url;
    _singleSignIn = singleSignIn;
    _alertView = [[UIAlertView alloc] initWithTitle:@"" message:confirmationText delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [_alertView show];
    _loop = self;
}

- (void)confirmOpenUrl:(NSURL *)url singleSignIn:(BOOL)singleSignIn
{
    [self confirmOpenUrl:url confirmationText:[[self class] confirmationText] singleSignIn:singleSignIn];
}

- (void)confirmOpenVideoUrl:(NSURL *)url
{
    [self confirmOpenUrl:url confirmationText:[[self class] videoConfirmationText] singleSignIn:NO];
}

+ (instancetype)confirmOpenUrl:(NSURL *)url singleSignIn:(BOOL)singleSignIn
{
    AlertView *alert = [AlertView new];
    
    [alert confirmOpenUrl:url singleSignIn:singleSignIn];
    return alert;
}

+ (instancetype)confirmOpenVideoUrl:(NSURL *)url
{
    AlertView *alert = [AlertView new];
    
    [alert confirmOpenVideoUrl:url];
    return alert;
}

- (void)hide
{
    [self hidePrev];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_urlToOpen) {
        if (buttonIndex == 1) {
//            if (_singleSignIn) {
//                [[AppDelegate shared] openStaffUrl:_urlToOpen.absoluteString];
//            } else {
                [[UIApplication sharedApplication] openURL:_urlToOpen];
//            }
        }
    } else if (_onComplete) {
        _onComplete(buttonIndex);
    }    
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    _alertView.delegate = nil;
    _loop = nil;
}

@end
