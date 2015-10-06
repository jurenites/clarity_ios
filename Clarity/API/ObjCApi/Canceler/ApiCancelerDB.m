//
//  ApiCancelerDB.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/10/14.
//
//

#import "ApiCancelerDB.h"

#import "ApiManager.h"

@interface ApiCancelerDB ()
{
    ApiManager * __weak m_apm;
    const void *m_db_manager;
    UniqueNumber *m_req_id;
}
@end

@implementation ApiCancelerDB

-(id)initWithApiManager:(ApiManager*)apm
    dbManager:(const void*)dbManager
    reqId:(UniqueNumber*)reqId
{
    self = [super init];
    if (!self)
        return nil;
    
    m_apm = apm;
    m_db_manager = dbManager;
    m_req_id = reqId;
    
    return self;
}

-(void)cancel
{
    [m_apm cancelReqId:m_req_id dbManager:m_db_manager];
}

@end
