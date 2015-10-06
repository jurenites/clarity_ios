//
//  DBHelper.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/5/13.
//
//

#import <Foundation/Foundation.h>

#import "NSMutableArray+DB.h"
#import "NSArray+DB.h"
#import "NSMutableDictionary+DB.h"
#import "NSDictionary+DB.h"

@interface DBHelper : NSObject

+(NSString*)makeInsertPart:(NSArray*)fieldNames;
+(NSString*)makeUpdatePart:(NSArray*)fieldNames;

@end
