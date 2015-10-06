//
//  ImageWrapper.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/14/13.
//
//

#import <Foundation/Foundation.h>

@interface ImageWrapper : NSObject

-(id)initWithImage:(UIImage*)image;

@property (strong, nonatomic) UIImage *image;

@end
