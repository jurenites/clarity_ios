//
//  CustomTextField.h
//  TRN
//
//  Created by Oleg Kasimov on 3/16/15.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSString *(^TextFieldValidator)(NSString *string);

@interface CustomTextField : UITextField

- (NSString *)validate;

@property (copy, nonatomic) TextFieldValidator validator;
@property (assign, nonatomic) IBInspectable NSInteger maxSymbolsCount;

@end
