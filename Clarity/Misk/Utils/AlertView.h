//
//  AlertView.h
//  StaffApp
//
//  Created by Alexey Klyotzin on 11/10/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertView : NSObject

+ (NSString *)confirmationText;

+ (instancetype)confirmOpenUrl:(NSURL *)url singleSignIn:(BOOL)singleSignIn;
+ (instancetype)confirmOpenVideoUrl:(NSURL *)url;

- (void)showWithTitle:(NSString *)title
                 text:(NSString *)text
     cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSArray *)otherButtonTitles
           onComplete:(void(^)(NSInteger clickedButtonIndex))onComplete;

- (void)confirmOpenUrl:(NSURL *)url singleSignIn:(BOOL)singleSignIn;
- (void)confirmOpenVideoUrl:(NSURL *)url;

- (void)hide;

@end
