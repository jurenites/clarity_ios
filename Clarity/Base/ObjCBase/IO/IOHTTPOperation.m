//
//  IOHTTPOperation.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/7/13.
//
//

#import "IOHTTPOperation.h"
#import "NetworkError.h"
#import "InternalError.h"
#import "HttpError.h"

@interface IOHTTPOperation () <NSURLConnectionDataDelegate>
{
    IOHTTPRequest *_request;
    NSURLConnection *_connection;
    NSHTTPURLResponse *_response;
    NSMutableData *_receivedData;
    NSFileHandle *_outFileHandle;
    
    long long _downloadedBytes;
}

+ (void)printJsonData:(NSData *)jsonData;
- (void)reportError:(NSError *)error;

@end

@implementation IOHTTPOperation

- (IOHTTPOperation *)initWithRequest:(IOHTTPRequest *)request
                            delegate:(id<IOOperationDelegate>)delegate
{
    self = [super initWithDelegate:delegate];
    if (!self)
        return nil;
    
    _request = request;
    _receivedData = [NSMutableData data];
    
    return self;
}

-(BOOL)canCacheIt
{
    return !(_response.statusCode < 200 || _response.statusCode >= 300);
}

- (IORequest *)request
{
    return _request;
}

- (void)perform
{
    [self.delegate ioOperationNeedNetwork:self];
}

- (void)startNetworkOperation
{
    NSURLRequest *req = [_request makeURLRequest];

    _connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
    
    if (_connection) {
    
#if defined(DEBUG)
        NSLog(@"%@", [self curlString:req]);
#endif
    
        [_connection start];
        [self needSpinner];
    }
    else {
        [self reportError:[NetworkError errorWithCode:NetworkErrorOffline]];
    }
}

- (void)cancel
{
    if (_connection) {
        [_connection cancel];
        _connection = nil;
        [self discardSpinner];
    }
}

- (void)cancelWithError:(NSError *)error
{
    NSAssert(_connection, @"");
    
    [_connection cancel];
    _connection = nil;
    [self discardSpinner];
    [self.delegate ioOperationFailed:self withError:error];
}

- (void)reportError:(NSError *)error
{
    [self.delegate ioOperationFailed:self withError:error];
    [self discardSpinner];
}


#pragma mark NSURLConnection delegates

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request
{
    return [_request makeNewStream];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([error.domain isEqual:NSURLErrorDomain]
        && error.code == NSURLErrorNotConnectedToInternet) {
        [self reportError:[NetworkError errorWithCode:NetworkErrorOffline]];
    } else {
        [self reportError:[NetworkError errorWithCode:NetworkErrorOther]];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
        [self cancel];
        
        NSLog(@"Warning! Non HTTP response in IOHTTPOperation");
        return;
    }
    
    _response = (NSHTTPURLResponse *)response;
    _downloadedBytes = 0;
    
    if (_request.saveFilePath.length) {
        [_outFileHandle closeFile];
        _outFileHandle = nil;
        [[NSFileManager defaultManager] removeItemAtPath:_request.saveFilePath error:nil];
        [[NSFileManager defaultManager] createFileAtPath:_request.saveFilePath contents:nil attributes:nil];
        _outFileHandle = [NSFileHandle fileHandleForWritingAtPath:_request.saveFilePath];
        
        if (!_outFileHandle) {
            [self cancelWithError:[InternalError errorWithDescr:@"Can not open file"]];
        }
        
    } else {
        [_receivedData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_outFileHandle) {
        @try {
            [_outFileHandle writeData:data];
        }
        @catch (NSException *exception) {
            [self cancelWithError:[InternalError errorWithDescr:exception.description]];
        }
    } else {
        [_receivedData appendData:data];
    }
    
    _downloadedBytes += data.length;
    
    if (_response.expectedContentLength != NSURLResponseUnknownLength && _request.onDlProgress) {
        const long long downloaded = _downloadedBytes;
        const long long contentLength = _response.expectedContentLength;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _request.onDlProgress(downloaded, contentLength);
        });
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (_request.onProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _request.onProgress(totalBytesWritten, totalBytesExpectedToWrite);
        });
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
#if defined(DEBUG)
    [[self class] printJsonData:_receivedData];
#endif
    
    if (_outFileHandle) {
        [_outFileHandle closeFile];
        _outFileHandle = nil;
        [self.delegate ioOperationSucceeded:self withFilePath:_request.saveFilePath httpCode:_response.statusCode];
        
    } else {
        [self.delegate ioOperationSucceeded:self withData:_receivedData httpCode:_response.statusCode];
    }
    
    [self discardSpinner];
}

+ (void)printJsonData:(NSData *)jsonData
{
    if (jsonData.length) {
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        
        if (json) {
            NSData *fmtJson = [NSJSONSerialization dataWithJSONObject:json
                                                              options:NSJSONWritingPrettyPrinted
                                                                error:nil];
            
            if (fmtJson) {
                NSString *str = [[NSString alloc] initWithBytes:fmtJson.bytes
                                                         length:fmtJson.length
                                                       encoding:NSUTF8StringEncoding];
                NSLog(@"%@", str);
            }
        } else {
            NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", str);
        }
    }

}

- (NSString *)curlString:(NSURLRequest *)request
{
  __block NSMutableString *displayString = [NSMutableString stringWithFormat:@"curl -X %@", request.HTTPMethod];

    [[request allHTTPHeaderFields] enumerateKeysAndObjectsUsingBlock:^(id key, id val, BOOL *stop)
     {
       [displayString appendFormat:@" -H \'%@: %@\'", key, val];
     }];
  
  [displayString appendFormat:@" \'%@\'",  request.URL.absoluteString];
  
  if ([request.HTTPMethod isEqualToString:@"POST"] ||
      [request.HTTPMethod isEqualToString:@"PUT"] ||
      [request.HTTPMethod isEqualToString:@"PATCH"]){
    
      [displayString
        appendFormat:@" -d \'%@\'",
            [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
    }
  
  return displayString;
}


@end
