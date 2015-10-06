//
//  CustomSearchBar.m
//  TRN
//
//  Created by stolyarov on 06/04/2015.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import "CustomSearchBar.h"
@interface CustomSearchBar() <UITextFieldDelegate>
{
    NSTimer *_searchTimer;
    NSString *_lastSearch;
}
@property (strong, nonatomic) IBOutlet UITextField *uiTextField;
@property (strong, nonatomic) IBOutlet UIImageView *uiGlass;
@end

@implementation CustomSearchBar

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.uiTextField.delegate = self;
    if (self.tintColor) {
        self.uiTextField.tintColor = self.tintColor;
    }
    
    _lastSearch = @"";
}

- (void)dealloc
{
    [_searchTimer invalidate];
    _searchTimer = nil;
}

- (void)makeSearch
{
    _searchTimer = nil;
//    if ([self.uiTextField.text isEqualToString:_lastSearch]) {
//        return;
//    }
//    _lastSearch = self.uiTextField.text;
    if (self.uiTextField.text.length >= self.charactersForSearch) {
        if ([self.delegate respondsToSelector:@selector(customSearchBar:searchWithText:)]) {
            [self.delegate customSearchBar:self searchWithText:self.uiTextField.text];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(customSearchBarClear:)]) {
            [self.delegate customSearchBarClear:self];
        }
    }
    
}

- (BOOL)isFirstResponder
{
    return [self.uiTextField isFirstResponder];
}

- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    [self.uiTextField resignFirstResponder];
    return YES;
}

- (NSString *)text
{
    return self.uiTextField.text;
}

- (void)setText:(NSString *)text
{
    [self.uiTextField setText:text];
}


#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self makeSearch];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [_searchTimer invalidate];
    _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self
                                                  selector:@selector(makeSearch) userInfo:nil repeats:NO];
    return YES;
}@end
