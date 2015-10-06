//
//  IOCacheOperation.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 2/17/14.
//
//

#import "IOCacheOperation.h"
#import "InternalError.h"

@interface IOCacheOperation ()
{
    IOCacheRequest *_request;
}
@end

@implementation IOCacheOperation

- (instancetype)initWithRequest:(IOCacheRequest *)request
                       delegate:(id<IOOperationDelegate>)delegate
{
    self = [super initWithDelegate:delegate];
    if (!self)
        return nil;
    
    _request = request;
    
    return self;
}

- (IORequest *)request
{
    return _request;
}

- (void)perform
{
    FileCache *cache = [self.delegate ioOperation:self cacheForName:_request.cache.cacheName];
    
    if (!cache) {
        [self.delegate ioOperationFailed:self withError:[InternalError errorWithDescr:@"Cache not found"]];
        return;
    }
    
    if (_request.cache.writeToFileDirectly) {
        NSString *cachedFilePath = [cache findFileWithRequest:_request.cache];
        
        if (cachedFilePath.length) {
            [self.delegate ioOperationSucceeded:self withFilePath:cachedFilePath httpCode:0];
        } else {
            [self.delegate ioOperationFailed:self withError:[InternalError errorWithDescr:@"File not found"]];
        }
    } else {
        NSMutableData *cachedData = [cache loadFileWithRequest:_request.cache];
        
        if (cachedData) {
            [self.delegate ioOperationSucceeded:self withData:cachedData httpCode:0];
        } else {
            [self.delegate ioOperationFailed:self withError:[InternalError errorWithDescr:@"File not found"]];
        }
    }
}

- (void)cancel
{
}


@end
