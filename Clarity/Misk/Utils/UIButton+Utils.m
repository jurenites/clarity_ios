//
//  UIButton+Utils.m
//  Brabble-iOSClient
//
//  Created by stolyarov on 26/02/2014.
//
//

#import "UIButton+Utils.h"

@implementation UIButton (Utils)
-(void)setTitleLabelFontInfo:(NSString *)titleLabelFontInfo
{
    NSArray *info = [titleLabelFontInfo componentsSeparatedByString:@";"];
    if(info.count!=2){
        NSLog(@"Error : wrong font!");
        return;
    }
    NSString *fontName = info[0];
    CGFloat fontSize = [info[1] floatValue];
    self.titleLabel.font = [UIFont fontWithName:fontName size:fontSize];
}

-(NSString *)titleLabelFontInfo
{
    NSString *titleLabelfontInfo = [NSString stringWithFormat:@"%@;%f", [self.titleLabel.font fontName], [self.titleLabel.font pointSize]];
    return  titleLabelfontInfo;
}
@end
