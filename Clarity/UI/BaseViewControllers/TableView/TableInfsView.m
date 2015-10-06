//
//  TableInfsView.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 5/8/14.
//
//

#import "TableInfsView.h"

@interface TableInfsView ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *uiSpinner;
@property (strong, nonatomic) IBOutlet UIImageView *uiNoMoreIcon;

@end

@implementation TableInfsView

- (void)switchToDefault
{
    self.uiSpinner.hidden = YES;
    [self.uiSpinner stopAnimating];
    self.uiNoMoreIcon.hidden = YES;
}

- (void)switchToLoading
{
    self.uiSpinner.hidden = NO;
    [self.uiSpinner startAnimating];
    self.uiNoMoreIcon.hidden = YES;
}

- (void)switchToNoMore
{
    self.uiSpinner.hidden = YES;
    [self.uiSpinner stopAnimating];
    self.uiNoMoreIcon.hidden = YES;
}

@end
