//
//  CustomSearchBar.h
//  TRN
//
//  Created by stolyarov on 06/04/2015.
//  Copyright (c) 2015 OysterLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomSearchBar;
@protocol CustomSearchBarDelegate <NSObject>

- (void)customSearchBar:(CustomSearchBar *)customSearchBar searchWithText:(NSString *)text;
- (void)customSearchBarClear:(CustomSearchBar *)customSearchBar;


@end
@interface CustomSearchBar : UIView
@property (weak, nonatomic) id <CustomSearchBarDelegate> delegate;

@property (assign, nonatomic) IBInspectable NSUInteger charactersForSearch;

- (NSString *)text;
- (void)setText:(NSString *)text;
@end
