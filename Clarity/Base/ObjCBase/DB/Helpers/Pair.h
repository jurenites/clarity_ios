//
//  Pair.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/5/13.
//
//

#import <Foundation/Foundation.h>

@interface Pair : NSObject

+(Pair*)pairWithName:(NSString*)name value:(id)value;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) id value;

@end
