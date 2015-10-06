//
//  IOHTTPRequest.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/7/13.
//
//

#import "IOHTTPRequest.h"
#import "IOHTTPOperation.h"
#import "NSString+Api.h"
#import "NSObject+Api.h"
#import "IOHTTPStream.h"
#import "IORequestDataContainer.h"
#import "IOHTTPStream.h"

@interface IOHTTPRequest ()
{
    NSMutableDictionary *_headers;
    NSMutableDictionary *_params;
    NSMutableArray *_files;
    NSMutableArray *_datas;
    
    IOHTTPRequestProgressCallback _onProgress;
    
    IOHTTPStream *_stream;
}

- (NSString *)paramsAsURLWithDelimeter:(BOOL)delimeter;
- (NSData *)paramsAsJSON;

@end

NSString *const BBDefaultMimeType = @"application/octet-stream";
NSString *const BBDefaultFileName = @"file";

@implementation IOHTTPRequest

@synthesize headers = _headers, params = _params, files = _files, datas = _datas;

-(id)init
{
    self = [super init];
    if (!self)
        return nil;
    
    _bodyEncoding = HttpBodyDefaultEncoding;
    _headers = [NSMutableDictionary dictionary];
    _params = [NSMutableDictionary dictionary];
    _files = [NSMutableArray array];
    _datas = [NSMutableArray array];
    self.method = HttpMethodGet;
    
    return self;
}

- (IOOperation *)makeOperationWithDelegate:(id<IOOperationDelegate>)delegate
{
    return [[IOHTTPOperation alloc] initWithRequest:self delegate:delegate];
}

- (void)addHeaders:(NSDictionary *)headers
{
    NSParameterAssert(headers);
    
    [_headers addEntriesFromDictionary:headers];
}

- (void)addParams:(NSDictionary *)params
{
    NSParameterAssert(params);
    
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self addParam:obj name:key];
     }];
}

- (void)addParam:(id)param name:(NSString *)name
{
    NSParameterAssert(name.length);
    NSParameterAssert(param);
	
    [_params addEntriesFromDictionary:@{name : param}];
}

- (void)addData:(NSData *)data name:(NSString *)name
{
    [self addData:data name:name mimeType:BBDefaultMimeType];
}

- (void)addData:(NSData *)data name:(NSString *)name mimeType:(NSString *)mime
{
    [self addData:data name:name mimeType:mime fileName:BBDefaultFileName];
}

- (void)addData:(NSData *)data name:(NSString *)name mimeType:(NSString *)mime fileName:(NSString *)fileName
{
    NSParameterAssert(name.length);
    NSParameterAssert(data);
    
    if (fileName.length == 0) {
        fileName = BBDefaultFileName;
    }
    if (mime.length == 0) {
        mime = BBDefaultMimeType;
    }

    NSAssert(self.method != HttpMethodGet, @"GET method does not allow adding data");
    
    IODataContainer *dataContainer = [IODataContainer new];
    dataContainer.data = data;
    dataContainer.name = name;
    dataContainer.mime = mime;
    dataContainer.fileName = fileName;
    
    [_datas addObject:dataContainer];
}

- (void)addFileFromPath:(NSString *)path name:(NSString *)name
{
    [self addFileFromPath:path name:name mimeType:BBDefaultMimeType];
}

- (void)addFileFromPath:(NSString *)path name:(NSString *)name mimeType:(NSString *)mime
{
    [self addFileFromPath:path name:name mimeType:mime fileName:BBDefaultFileName];
}

- (void)addFileFromPath:(NSString *)path name:(NSString *)name mimeType:(NSString *)mime fileName:(NSString *)fileName
{
    NSParameterAssert(path.length);
    NSAssert([path isAbsolutePath], @"String is not a valid file path");
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:path], @"File does not exist");
    NSParameterAssert(name.length);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return;
    }
    
    if (fileName.length == 0) {
        fileName = BBDefaultFileName;
    }
    if (mime.length == 0) {
        mime = BBDefaultMimeType;
    }
    
    NSAssert(self.method != HttpMethodGet, @"GET method does not allow adding data");
    
    IOFileContainer *fileContainer = [IOFileContainer new];
    fileContainer.filePath = path;
    fileContainer.name = name;
    fileContainer.mime = mime;
    fileContainer.fileName = fileName;
    
    [_files addObject:fileContainer];
}

- (NSString *)paramsAsURLWithDelimeter:(BOOL)delimeter
{
    NSMutableArray *parts = [NSMutableArray array];
    NSEnumerator *en = self.params.keyEnumerator;
    
    for (NSString *key = [en nextObject]; key; key = [en nextObject]) {
        if (![key isKindOfClass:[NSString class]]) {
            continue;
        }
        
        id value = self.params[key];
        NSString *stringValue = @"";
        
        if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
            stringValue = ToJSON(value);
        } else {
            stringValue = ToString(value);
        }
        
        [parts addObject: [NSString stringWithFormat: @"%@=%@", key, [stringValue urlEncode]]];
    }
    
    if (parts.count == 0) {
        return @"";
    }
    
    NSString *params = [parts componentsJoinedByString:@"&"];
    
    if (delimeter) {
        return [NSString stringWithFormat:@"?%@", params];
    }
    
    return params;
}

- (NSData *)paramsAsJSON
{
    if (!self.params) {
        return nil;
    }
    
    return [NSJSONSerialization dataWithJSONObject:self.params options:0 error:nil];
}

- (NSString *)methodAsString
{
    switch (self.method) {
        case HttpMethodGet:
            return @"GET";
            
        case HttpMethodPost:
            return @"POST";
            
        case HttpMethodDelete:
            return @"DELETE";
            
        case HttpMethodPut:
            return @"PUT";
    }
    
    return @"GET";
}

- (NSInputStream *)makeNewStream
{
    IOHTTPStream *ioStreamBuilder = [[IOHTTPStream alloc] init];
    
    [ioStreamBuilder addParams:_params];
    
    for (IODataContainer *container in _datas) {
        [ioStreamBuilder addData:container.data
                            name:container.name
                        mimeType:container.mime
                        fileName:container.fileName];
    }
    
    for (IOFileContainer *container in _files) {
        [ioStreamBuilder addFileFromPath:container.filePath
                                    name:container.name
                                mimeType:container.mime
                                fileName:container.fileName];
    }
    
    [ioStreamBuilder start];
    
    _stream = ioStreamBuilder;
    return ioStreamBuilder.stream;
}

- (NSMutableURLRequest *)makeURLRequest
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]
                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                   timeoutInterval:30];
    
    if (self.method == HttpMethodGet || self.method == HttpMethodDelete) {
        [req setURL:[NSURL URLWithString:[self.url stringByAppendingString:
                                          [self paramsAsURLWithDelimeter:YES]]]];
    }
    else if (self.method == HttpMethodPost || self.method == HttpMethodPut) {
        HttpBodyEncoding bodyEncoding = self.bodyEncoding;
        
        if (bodyEncoding == HttpBodyDefaultEncoding) {
            if (_datas.count > 0 || _files.count > 0) {
                bodyEncoding = HttpBodyMultipart;
            } else {
                bodyEncoding = HttpBodyUrlencoded;
            }
        }
        
        if (HttpBodyJSON == bodyEncoding) {
            [_headers addEntriesFromDictionary:@{@"Content-Type": @"application/json"}];
            [req setHTTPBody:[self paramsAsJSON]];
        } else if (HttpBodyMultipart == bodyEncoding) {
            [self makeNewStream];
            [req setHTTPBodyStream:_stream.stream];
            
            NSString *multipart = [NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@",
                                   _stream.encoding,
                                   _stream.boundary];
            
            NSString *length = [NSString stringWithFormat:@"%llu", _stream.length];
            
            [_headers addEntriesFromDictionary:@{
                 @"Content-Type": multipart,
                 @"Content-Length": length}];
        } else {
            [_headers addEntriesFromDictionary:@{@"Content-Type": @"application/x-www-form-urlencoded"}];
            [req setHTTPBody:[[self paramsAsURLWithDelimeter:NO] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    NSString *body = [[NSString alloc] initWithData:req.HTTPBody encoding:NSUTF8StringEncoding];
    NSLog(@"Body : %@", body);
    [req setHTTPMethod:[self methodAsString]];
    [req setAllHTTPHeaderFields:self.headers];
    
    return req;
}

@end
