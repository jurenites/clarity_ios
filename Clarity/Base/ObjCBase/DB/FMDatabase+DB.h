//
//  FMDatabase+DB.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/5/13.
//
//

#import "FMDatabase.h"

@interface FMDatabase (DB)

-(void)execUpdate:(NSArray*)sql withParams:(NSDictionary *)arguments;
-(void)execUpdate:(NSArray*)sql;

-(FMResultSet*)exec:(NSArray*)sql withParams:(NSDictionary *)arguments;
-(FMResultSet*)exec:(NSArray*)sql;

-(void)execUpdateWithString:(NSString*)sql withParams:(NSDictionary *)arguments;
-(void)execUpdateWithString:(NSString*)sql;

-(FMResultSet*)execWithString:(NSString*)sql withParams:(NSDictionary *)arguments;
-(FMResultSet*)execWithString:(NSString*)sql;

@end
