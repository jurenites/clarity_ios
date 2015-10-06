//
//  UILabel+Utils.m
//  Brabble-iOSClient
//
//  Created by stolyarov on 26/02/2014.
//
//

#import "UILabel+Utils.h"

@implementation UILabel (Utils)

- (void)setFontInfo:(NSString *)fontInfo
{
    NSArray *info = [fontInfo componentsSeparatedByString:@";"];
    
    if(info.count != 2) {
        NSLog(@"Error : wrong font!");
        return;
    }
    
    NSString *fontName = info[0];
    CGFloat fontSize = [info[1] floatValue];
    self.font = [UIFont fontWithName:fontName size:fontSize];
}

- (NSString *)fontInfo
{
    NSString *fontInfo = [NSString stringWithFormat:@"%@;%f", [self.font fontName], [self.font pointSize]];
    return  fontInfo;
}

- (void)setStrings:(NSArray *)strings withAttrs:(NSArray *)attrs commonAttrs:(NSDictionary *)commonAttrs
{
    NSMutableAttributedString *result = [NSMutableAttributedString new];
    
    for (NSUInteger i = 0; i < strings.count && i < attrs.count; i++) {
        NSString *string = strings[i];
        NSDictionary *attr = attrs[i];
        
        [result appendAttributedString:
         [[NSAttributedString alloc] initWithString:string
                                         attributes:attr]];
    }
    
    [result addAttributes:commonAttrs range:NSMakeRange(0, result.length)];
    
    self.attributedText = result;
}

- (void)setStrings:(NSArray *)strings withAttrs:(NSArray *)attrs
{
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    paragrapStyle.alignment = NSTextAlignmentCenter;
    
    [self setStrings:strings withAttrs:attrs commonAttrs:@{NSParagraphStyleAttributeName : paragrapStyle}];
}

@end
