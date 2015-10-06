//
//  SharingHelper.h
//  StaffApp
//
//  Created by Alexey Klyotzin on 8/13/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ShareDstFacebook,
    ShareDstTwitter,
    ShareDstGoogle,
    ShareDstInstagram,
    ShareDstEmail,
    ShareDstCameraRoll,
    ShareDstClipboard
} ShareDst;

@class StaffUser;
@class SharingHelper;

@protocol SharingHelperDelegate <NSObject>

@optional
- (void)sharingHelperContactWasAdded:(SharingHelper *)helper;
@end

@interface SharingHelper : NSObject

+ (void)setupGPlus;

- (void)shareToFB;
- (void)shareToTW;
- (void)shareToGPlus;
- (void)shareToInstagramFromRect:(CGRect)dialogRect;
- (void)shareVideoToInstagram;
- (void)sendViaEmail;
- (void)saveToCameraRoll;
- (void)copyToClopBoard;
- (void)saveContact;

- (void)dismissInstagramDialog;


- (NSArray *)availShareDestinations;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) StaffUser *user;

@property (strong, nonatomic) NSString *videoUrl;
@property (assign, nonatomic) NSUInteger videoFileLen;

@property (strong, nonatomic) UIViewController *presentingViewController;

@property (strong, nonatomic) NSString *trackActionCategory;

@property (weak, nonatomic) id <SharingHelperDelegate> delegate;

@end
