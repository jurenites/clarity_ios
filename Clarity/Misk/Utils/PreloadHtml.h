//
//  PreloadWebView.h
//  StaffApp
//
//  Created by stolyarov on 13/10/2014.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreloadHtml : NSObject

- (instancetype)initWithViewController:(UIViewController *)vc;

- (void)preloadHtmls:(NSArray *)html_array
          withFrames:(NSArray *)webViewFrames
           onSuccess:(void(^)(NSArray *))onSuccess
             onError:(void(^)(NSError *error))onError;
@end
