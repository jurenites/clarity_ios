//
//  DBTranslatedResult.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/6/13.
//
//

#import <Foundation/Foundation.h>
#import "FMResultSet+DB.h"

@interface DBTranslatedResult : NSObject <DBResultProtocol>

-(id)initWithResult:(FMResultSet*)res translateDict:(NSDictionary*)dict;

@end
