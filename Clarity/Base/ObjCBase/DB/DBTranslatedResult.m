//
//  DBTranslatedResult.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 11/6/13.
//
//

#import "DBTranslatedResult.h"

@interface DBTranslatedResult ()
{
    FMResultSet *m_res;
    NSDictionary *m_translation;
}

@end

@implementation DBTranslatedResult

-(id)initWithResult:(FMResultSet*)res translateDict:(NSDictionary*)dict
{
    self = [super init];
    if (!self)
        return nil;
    
    m_res = res;
    m_translation = dict;
    
    return self;
}

-(NSString*)translateName:(NSString*)name
{
    NSString *translated = m_translation[name];
    
    return translated ? translated : name;
}

-(NSString*)stringCol:(NSString*)colName
{
    return [m_res stringCol:[self translateName:colName]];
}

-(int)intCol:(NSString*)colName
{
    return [m_res intCol:[self translateName:colName]];
}

-(BOOL)boolCol:(NSString*)colName
{
    return [m_res boolCol:[self translateName:colName]];
}

-(float)floatCol:(NSString*)colName
{
    return [m_res floatCol:[self translateName:colName]];
}

-(NSDate*)dateCol:(NSString*)colName
{
    return [m_res dateCol:[self translateName:colName]];
}

-(BOOL)isNull:(NSString*)columnName
{
    return [m_res isNull:[self translateName:columnName]];
}

@end
