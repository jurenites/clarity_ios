//
//  NSArray+DB.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/8/14.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (DB)

-(NSString*)join;
-(NSString*)joinBy:(NSString*)str;

-(NSMutableArray*)append:(NSArray*)array;

@end
