//
//  SharingHelper.m
//  StaffApp
//
//  Created by Alexey Klyotzin on 8/13/14.
//  Copyright (c) 2014 OysterLabs. All rights reserved.
//

#import "SharingHelper.h"
#import "VCtrlBase.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "BBDeviceHardware.h"
#import "VCtrlShare.h"
#import "EventsTracker.h"
#import "VCtrlTwitterDialog.h"
#import "VCtrlVideoUpload.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

static NSString * const GPlusClientId = @"184337902451-cu3t3sm8k9g3h2f5544t5mtubkfvuuu2.apps.googleusercontent.com";
static NSString * const InstagramUrl = @"instagram://location?id=1";

@interface SharingHelper () <GPPSignInDelegate, GPPShareDelegate,
                             UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate, ABNewPersonViewControllerDelegate, VCtrlTwitterDialogDelegate>
{
    id<GPPNativeShareBuilder> _gplusShareController;
    GPPSignIn *_gplusSignIn;
    
    UIDocumentInteractionController *_igDocController;
    BOOL _manuallyHiding;
    
    MFMailComposeViewController *mailer;
}

- (void)showAlert:(NSString *)alert;
- (NSString *)titleWithText;

@property (nonatomic, strong) SharingHelper *strongSelf;

@end

@implementation SharingHelper

+ (void)setupGPlus
{
    GPPSignIn *gpls = [GPPSignIn sharedInstance];
    [gpls setClientID:GPlusClientId];
    [gpls setScopes:@[kGTLAuthScopePlusLogin]];
    [gpls trySilentAuthentication];
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.trackActionCategory = @"";
    return self;
}

- (void)dealloc
{
    [GPPSignIn sharedInstance].delegate = nil;
}

- (NSArray *)availShareDestinations
{
    NSMutableArray *availDsts = [NSMutableArray arrayWithArray:@[
                                @(ShareDstFacebook), @(ShareDstGoogle), @(ShareDstEmail),
                                @(ShareDstClipboard), @(ShareDstTwitter)]];
    
    if (self.image
        && ((NSInteger)self.image.size.width == (NSInteger)self.image.size.height)
        && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:InstagramUrl]]) {
        [availDsts addObject:@(ShareDstInstagram)];
    } else if (self.videoUrl.length && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:InstagramUrl]]) {
        [availDsts addObject:@(ShareDstInstagram)];
    }
    
    if (self.image) {
        [availDsts addObject:@(ShareDstCameraRoll)];
    }
    
    return availDsts;
}

- (void)showAlert:(NSString *)alert
{
    if ([self.presentingViewController isKindOfClass:[VCtrlBase class]]) {
        [(VCtrlBase *)self.presentingViewController showNotice:alert];
    }
}

- (NSString *)titleWithText
{
    NSString *text = @"";
    
    if (self.title.length && self.text.length) {
        text = [NSString stringWithFormat:@"%@\n%@", self.title, self.text];
    } else if (self.title.length) {
        text = self.title;
    } else {
        text = self.text;
    }
    
    return text;
}

- (void)shareToFBOrTW:(NSString *)servicerType noServiceAlert:(NSString *)noServiceAlert onSuccess:(void(^)())onSuccess
{
    //if ([SLComposeViewController isAvailableForServiceType:servicerType]) {
        SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:servicerType];
        
        if (!composeViewController) {
            [self showAlert:@"Unknown error"];
            return;
        }
        
        NSString *text = [self titleWithText];
        
        if (text.length) {
            [composeViewController setInitialText:text];
        }
        
        if (self.image) {
            [composeViewController addImage:self.image];
        }
        
        if (self.videoUrl) {
            [composeViewController addURL:[NSURL URLWithString:self.videoUrl]];
        }
        
        [composeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result == SLComposeViewControllerResultDone) {
                    [self showAlert:NSLocalizedString(@"Post has been shared.", nil)];
                    if (onSuccess) {
                        onSuccess();
                    }
                } else if (result == SLComposeViewControllerResultCancelled) {
                    [self showAlert:NSLocalizedString(@"Message cancelled.", nil)];
                }
                
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            });
        }];
        
        [self.presentingViewController presentViewController:composeViewController animated:YES completion:nil];
//    } else {
//        [self showAlert:noServiceAlert];
//    }
}

- (void)shareToFB
{
    [self shareToFBOrTW:SLServiceTypeFacebook
         noServiceAlert:NSLocalizedString(@"Please login to FB in device settings and try again.", nil)
            onSuccess:^{
                [EventsTracker trackAction:ETActionFacebook cat:self.trackActionCategory];
            }];
}

- (void)shareToTW
{
    [self shareToFBOrTW:SLServiceTypeTwitter
         noServiceAlert:NSLocalizedString(@"Please login to Twitter in device settings and try again.", nil)
              onSuccess:^{
                  [EventsTracker trackAction:ETActionTwitter cat:self.trackActionCategory];
              }];
    
//    VCtrlTwitterDialog *twDialog = [[VCtrlTwitterDialog alloc] initWithText:[self titleWithText]
//                                                                  withImage:self.image];
//    twDialog.delegate = self;
//    [twDialog show];
}

#pragma mark VCtrlTwitterDialogDelegate
- (void)twitterDialogCancelled:(VCtrlTwitterDialog *)twDialog
{
    [self showAlert:NSLocalizedString(@"Message cancelled.", nil)];
}

- (void)twitterDialogPosted:(VCtrlTwitterDialog *)twDialog
{
    [self showAlert:NSLocalizedString(@"Post has been shared.", nil)];
}


#pragma mark GPlus
- (void)shareToGPlus
{
    GPPShare *shareCtrl = [GPPShare sharedInstance];
    shareCtrl.delegate = self;
    
    if (_gplusShareController) {
        [shareCtrl closeActiveNativeShareDialog];
    }
    
    _gplusShareController = [shareCtrl nativeShareDialog];
    
    [_gplusShareController setPrefillText:[self titleWithText]];
    
    if (self.image) {
        [_gplusShareController attachImage:self.image];
    } else if (self.url.length) {
        [_gplusShareController setURLToShare:[NSURL URLWithString:self.url]];
    }
    
    
    GPPSignIn *signinCtrl = [GPPSignIn sharedInstance];
    if (signinCtrl.authentication == nil) {
        signinCtrl.delegate = self;
        [signinCtrl authenticate];
    } else if (![_gplusShareController open]) {
        [self showAlert:NSLocalizedString(@"Cannot share via Google+", @"")];
    }
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    if (error) {
        [self showAlert:NSLocalizedString(@"Cannot share via Google+", @"")];
        _gplusShareController = nil;
    } else if (_gplusShareController) {
        if (![_gplusShareController open]) {
            [self showAlert:NSLocalizedString(@"Cannot share via Google+", @"")];
            _gplusShareController = nil;
        }
    }
}

- (void)finishedSharingWithError:(NSError *)error
{
    [GPPSignIn sharedInstance].delegate = nil;
    
    if (!error) {
        [self showAlert:NSLocalizedString(@"Post has been shared.", @"")];
        [EventsTracker trackAction:ETActionGPlus cat:self.trackActionCategory];
    } else if (error.code == -401) {
        [self showAlert:NSLocalizedString(@"Message cancelled.", @"")];
    } else {
        [self showAlert:NSLocalizedString(@"Data send failed.", @"")];
    }
}

#pragma mark Instagram

- (void)shareVideoToInstagram
{
    VCtrlVideoUpload *vu = [[VCtrlVideoUpload alloc] initWithUrl:self.videoUrl fileLen:self.videoFileLen];
    
    [vu show];
}

- (void)shareToInstagramFromRect:(CGRect)dialogRect
{
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:InstagramUrl]]
        || !self.image) {
        [self showAlert:NSLocalizedString(@"Cannot share via Instagram", nil)];
        return;
    }
    
    NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *saveImagePath = [documentDirectory stringByAppendingPathComponent:@"Image.igo"];
    NSData *imageData = UIImagePNGRepresentation(self.image);
    
    if (![imageData writeToFile:saveImagePath atomically:YES]) {
        [self showAlert:NSLocalizedString(@"Unknown error", nil)];
        return;
    }
    
    NSURL *imageURL = [NSURL fileURLWithPath:saveImagePath];
    
    _igDocController = [UIDocumentInteractionController new];
    _igDocController.delegate = self;
    _igDocController.UTI = @"com.instagram.exclusivegram";
    _igDocController.annotation = [NSDictionary dictionaryWithObjectsAndKeys:@"Image Taken via UC",@"InstagramCaption", nil];
    [_igDocController setURL:imageURL];
    
    _manuallyHiding = NO;
    [_igDocController presentOpenInMenuFromRect:dialogRect inView:self.presentingViewController.view animated:YES];
    [EventsTracker trackAction:ETActionInstagram cat:self.trackActionCategory];
}

- (void)dismissInstagramDialog
{
    _manuallyHiding = YES;
    if (_igDocController) {
        [_igDocController dismissMenuAnimated:YES];
    }
}

- (UIDocumentInteractionController *)setupControllerWithURL:(NSURL *) fileURL usingDelegate:(id <UIDocumentInteractionControllerDelegate>)interactionDelegate
{
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

#pragma mark UIDocumentInteractionControllerDelegate
- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    if([self.presentingViewController isKindOfClass:[VCtrlShare class]] && !_manuallyHiding){
        [(VCtrlShare *)self.presentingViewController hide];
    }
}

#pragma mark Email

- (void)sendViaEmail
{
    if (![MFMailComposeViewController canSendMail]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"]];
        return;
    }
    
    mailer = [MFMailComposeViewController new];
    mailer.mailComposeDelegate = self;
    
    if (self.title.length) {
        [mailer setSubject:self.title];
    }
    
    if (self.text.length) {
        [mailer setMessageBody:self.text isHTML:NO];
    }
    
    if (self.image) {
        NSData *imageData = UIImagePNGRepresentation(self.image);
        [mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"staffImage.png"];
    }
    
    [self.presentingViewController presentViewController:mailer animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            [self showAlert:NSLocalizedString(@"Mail has been cancelled.", @"")];
            break;
        case MFMailComposeResultSaved:
            [self showAlert:NSLocalizedString(@"Mail has been saved.", @"")];
            break;
        case MFMailComposeResultSent:
            [self showAlert:NSLocalizedString(@"Mail has been sent.", @"")];
            [EventsTracker trackAction:ETActionMail cat:self.trackActionCategory];
            break;
        case MFMailComposeResultFailed:
            [self showAlert:NSLocalizedString(@"Mail has failed.", @"")];
            break;
        default:
            [self showAlert:NSLocalizedString(@"Mail has failed to send.", @"")];
            break;
    }
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark CameraRoll

- (void)saveToCameraRoll
{
    if (self.videoUrl.length && self.videoFileLen) {
        VCtrlVideoUpload *vu = [[VCtrlVideoUpload alloc] initWithUrl:self.videoUrl fileLen:self.videoFileLen];
        [vu show];
        return;
    }
    
    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    [lib writeImageToSavedPhotosAlbum:self.image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self showAlert:error.localizedDescription];
            } else {
                [self showAlert:NSLocalizedString(@"Image has been downloaded.", nil)];
                [EventsTracker trackAction:ETActionDownload cat:self.trackActionCategory];
            }
        });
    }];
}

#pragma mark Clipboard

- (void)copyToClopBoard
{
    [UIPasteboard generalPasteboard].persistent = YES;
    
    NSString *text = [self titleWithText];
    
    NSMutableArray *clipboardItems = [NSMutableArray new];
    
    if (text.length > 0) {
        [clipboardItems addObject:@{(__bridge NSString *)kUTTypeUTF8PlainText : text}];
    }
    
    if (self.image) {
        [clipboardItems addObject:@{(__bridge NSString *)kUTTypePNG : self.image}];
    }
    
    if (clipboardItems.count > 0) {
        [[UIPasteboard generalPasteboard] setItems:clipboardItems];
    }
    
    if (clipboardItems.count) {
        [self showAlert:NSLocalizedString(@"Data has been copied.", nil)];
        [EventsTracker trackAction:ETActionCopy cat:self.trackActionCategory];
    } else {
        [self showAlert:NSLocalizedString(@"Nothing to copy.", nil)];
    }
}

#pragma mark Contact

- (void)saveContact
{
    NSAssert(self.user, @"sharingHelper.user == nil;" );
    if (!self.user) {
        return;
    }
    
    ABRecordRef newPerson = ABPersonCreate();
    CFErrorRef error = NULL;
    
    //First name
    if ([self.user.firstName length]) {
        ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFTypeRef)self.user.firstName, &error);
    }
    
    //Last name
    if ([self.user.lastName length]) {
        ABRecordSetValue(newPerson, kABPersonLastNameProperty, (__bridge CFTypeRef)self.user.lastName, &error);
    }
    
    //Organization
    NSString *position = NSLocalizedString(@"LifeChurch.tv", nil);
//    NSMutableString *position  = [NSMutableString stringWithFormat:@"Life church"];
//    if ([self.user.position length]) {
//        [position appendFormat:@", %@", self.user.position];
//    }
    ABRecordSetValue(newPerson, kABPersonOrganizationProperty, (__bridge CFTypeRef)position, &error);
    
    //Email
    if ([self.user.email length]) {
        ABMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(emailMultiValue, (__bridge CFTypeRef)self.user.email, kABOtherLabel, NULL);
        ABRecordSetValue(newPerson, kABPersonEmailProperty, emailMultiValue, &error);
        CFRelease(emailMultiValue);
    }
    
    //Phone Work
    ABMultiValueRef phoneMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    if ([self.user.phoneWork length]) {
        ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFTypeRef)self.user.phoneWork, kABPersonPhoneMainLabel, NULL);
    }
    
    //Phone Mobile
    if ([self.user.phoneMobile length]) {
        ABMultiValueAddValueAndLabel(phoneMultiValue, (__bridge CFTypeRef)self.user.phoneMobile, kABPersonPhoneMobileLabel, NULL);
    }
    
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, phoneMultiValue, &error);
    CFRelease(phoneMultiValue);
    
    //Image
    if (self.image) {
        NSData *dataRef = UIImagePNGRepresentation(self.image);
        ABPersonSetImageData(newPerson, (__bridge CFDataRef)dataRef, nil);
    }
    
    if (error) {
        [self showAlert:CFBridgingRelease(CFErrorCopyDescription(error))];
    }
    
    ABNewPersonViewController* newPersonViewController = [[ABNewPersonViewController alloc] init];
    newPersonViewController.displayedPerson = newPerson;
    newPersonViewController.newPersonViewDelegate = self;
    
    //According to guidelines from Apple it should be wrapped in Navigation
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
    [self.presentingViewController presentViewController:navController animated:YES completion:NULL];
    
    //Hold self to make delegate work
    self.strongSelf = self;
    
    CFRelease(newPerson);
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    
    if (person) {
        if ([self.delegate respondsToSelector:@selector(sharingHelperContactWasAdded:)]) {
            [self.delegate sharingHelperContactWasAdded:self];
        }
    }
    
    //Release self
    self.strongSelf = nil;
}

@end
