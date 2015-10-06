//
//  IOCachedHTTPOperation.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/9/13.
//
//

#import "IOCachedHTTPOperation.h"
#import "IOHTTPOperation.h"
#import "NSError+IO.h"
#import "InternalError.h"

@interface IOCachedHTTPOperation () <IOOperationDelegate>
{
    IOCachedHTTPRequest *_request;
    IOHTTPOperation *_httpOperation;
}
@end

@implementation IOCachedHTTPOperation

@synthesize request = _request;

- (IOCachedHTTPOperation *)initWithRequest:(IOCachedHTTPRequest *)request
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
    
    if (_request.offlineMode) {
        if (!cache || _request.failIfInCache) {
            [self.delegate ioOperationFailed:self
                                   withError:[InternalError errorWithDescr:@"Caching error"]];
            return;
        }
        
        if (_request.cache.writeToFileDirectly) {
            NSString *cachedFilePath = [cache findFileWithName:_request.cache.fileName];
            
            if (cachedFilePath.length) {
                [self.delegate ioOperationSucceeded:self withFilePath:cachedFilePath httpCode:HTTPCodeCached];
            } else {
                [self.delegate ioOperationFailed:self
                                       withError:[InternalError errorWithDescr:@"FileNotFound"]];
            }
        } else {
            NSMutableData *cachedData = [cache loadFileWithName:_request.cache.fileName];
            
            if (cachedData) {
                [self.delegate ioOperationSucceeded:self withData:cachedData httpCode:HTTPCodeCached];
            } else {
                [self.delegate ioOperationFailed:self
                                       withError:[InternalError errorWithDescr:@"FileNotFound"]];
            }
        }
        
        return;
    }
    
    if (_request.cache.writeToFileDirectly) {
        if (!cache) {
            [self.delegate ioOperationFailed:self
                                   withError:[InternalError errorWithDescr:@"Caching error"]];
            return;
        }
        
        NSString *cachedFilePath = [cache findFileWithRequest:_request.cache];
        
        if (cachedFilePath.length) {
            if (_request.failIfInCache) {
                [self.delegate ioOperationFailed:self
                                       withError:[InternalError errorWithDescr:@"In cache"]];
            } else {
                [self.delegate ioOperationSucceeded:self withFilePath:cachedFilePath httpCode:HTTPCodeCached];
            }
        } else {
            NSString *tempFileName = [NSString stringWithFormat:@"%@_%lld.tmp",
                                      _request.cache.fileName,
                                      _request.requestId.number.longLongValue];
            
            _request.saveFilePath = [cache pathForFileName:tempFileName];
            [self.delegate ioOperationNeedNetwork:self];
        }
    } else {
        if (!cache) {
            [self.delegate ioOperationNeedNetwork:self];
            return;
        }
        
        NSMutableData *cachedData = [cache loadFileWithRequest:_request.cache];
        
        if (cachedData) {
            if (_request.failIfInCache) {
                [self.delegate ioOperationFailed:self
                                       withError:[InternalError errorWithDescr:@"In cache"]];
            } else {
                [self.delegate ioOperationSucceeded:self withData:cachedData httpCode:HTTPCodeCached];
            }
        } else {
            [self.delegate ioOperationNeedNetwork:self];
        }
    }
}

- (void)cancel
{
    [_httpOperation cancel];
}

- (void)startNetworkOperation
{
    _httpOperation = [[IOHTTPOperation alloc] initWithRequest:_request delegate:self];
    [_httpOperation perform];
}

#pragma mark - IOOperationDelegate

- (void)ioOperationSucceeded:(IOOperation *)operation withData:(NSData *)data httpCode:(NSInteger)httpCode
{
    FileCache *cache = [self.delegate ioOperation:self cacheForName:_request.cache.cacheName];
    IOHTTPOperation *httpOp = (IOHTTPOperation*)operation;
    const BOOL canCacheIt = cache && [httpOp isKindOfClass:[IOHTTPOperation class]] && [httpOp canCacheIt];
    
    if (canCacheIt) {
        [cache saveFile:data withRequest:_request.cache];
    }
    
    [self.delegate ioOperationSucceeded:self withData:data httpCode:httpCode];
}

- (void)ioOperationSucceeded:(IOOperation *)operation withFilePath:(NSString *)filePath httpCode:(NSInteger)httpCode
{
    FileCache *cache = [self.delegate ioOperation:self cacheForName:_request.cache.cacheName];
    IOHTTPOperation *httpOp = (IOHTTPOperation*)operation;
    const BOOL canCacheIt = cache && [httpOp isKindOfClass:[IOHTTPOperation class]] && [httpOp canCacheIt];
    
    if (canCacheIt) {
        [cache saveFilePath:filePath withRequest:_request.cache];
        [self.delegate ioOperationSucceeded:self withFilePath:[cache pathForFileName:_request.cache.fileName] httpCode:httpCode];
    } else {
        [self.delegate ioOperationSucceeded:self withFilePath:filePath httpCode:httpCode];
    }
}

- (void)ioOperationFailed:(IOOperation *)operation withError:(NSError *)error
{
    if (!_request.cache.writeToFileDirectly) {
        FileCache *cache = [self.delegate ioOperation:self cacheForName:_request.cache.cacheName];
        
        if (cache) {
            NSMutableData *cachedData = [cache loadFileWithName:_request.cache.fileName];
            
            if (cachedData) {
                [self.delegate ioOperationSucceeded:self withData:cachedData httpCode:HTTPCodeCached];
                return;
            }
        }
    }

    [self.delegate ioOperationFailed:self withError:error];
}

- (void)ioOperationNeedNetwork:(IOOperation *)operation
{
    [operation startNetworkOperation];
}

- (FileCache *)ioOperation:(IOOperation *)operation cacheForName:(NSString *)name
{
    return [self.delegate ioOperation:operation cacheForName:name];
}

- (BOOL)ioOperationInOnline
{
    return [self.delegate ioOperationInOnline];
}


@end
