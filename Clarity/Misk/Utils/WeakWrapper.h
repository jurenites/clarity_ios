//
//  WeakWrapper.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 12/2/13.
//
//

#import <Foundation/Foundation.h>

@interface WeakWrapper : NSObject

-(id)initWithObj:(id)object;

@property (weak, nonatomic) id object;

@end
