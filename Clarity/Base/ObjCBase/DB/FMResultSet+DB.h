//
//  FMResultSet+DB.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/5/13.
//
//

#import "FMResultSet.h"
#import "DBResultProtocol.h"

@interface FMResultSet (DB) <DBResultProtocol>

-(NSString*)stringCol:(NSString*)colName;
-(int)intCol:(NSString*)colName;
-(BOOL)boolCol:(NSString*)colName;
-(float)floatCol:(NSString*)colName;
-(NSDate*)dateCol:(NSString*)colName;

-(BOOL)isNull:(NSString*)columnName;

@end
