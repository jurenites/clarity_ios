//
//  UILabel+Utils.h
//  Brabble-iOSClient
//
//  Created by stolyarov on 26/02/2014.
//
//

#import <UIKit/UIKit.h>

@interface UILabel (Utils)

- (void)setStrings:(NSArray *)strings withAttrs:(NSArray *)attrs;
- (void)setStrings:(NSArray *)strings withAttrs:(NSArray *)attrs commonAttrs:(NSDictionary *)commonAttrs;

@property(strong, nonatomic) IBInspectable NSString *fontInfo;

@end
