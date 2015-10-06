//
//  DBResultProtocol.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/6/13.
//
//

#import <Foundation/Foundation.h>

@protocol DBResultProtocol <NSObject>

@required
-(NSString*)stringCol:(NSString*)colName;
-(int)intCol:(NSString*)colName;
-(BOOL)boolCol:(NSString*)colName;
-(float)floatCol:(NSString*)colName;
-(NSDate*)dateCol:(NSString*)colName;

-(BOOL)isNull:(NSString*)columnName;

@end
