//
//  IOHTTPRequest.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 10/7/13.
//
//

#import "IORequest.h"

typedef enum {
    HttpMethodGet,
    HttpMethodPost,
    HttpMethodPut,
    HttpMethodDelete
} HttpMethod;

typedef enum {
    HttpBodyDefaultEncoding,
    HttpBodyUrlencoded,
    HttpBodyMultipart,
    HttpBodyJSON
} HttpBodyEncoding;

typedef void(^IOHTTPRequestProgressCallback)(int64_t sentBytes, int64_t totalBytes);

@interface IOHTTPRequest : IORequest

- (id)init;

- (void)addHeaders:(NSDictionary *)headers;

- (void)addParams:(NSDictionary *)params;
- (void)addParam:(id)param name:(NSString *)name;

- (void)addData:(NSData *)data name:(NSString *)name;
- (void)addData:(NSData *)data name:(NSString *)name mimeType:(NSString *)mime;
- (void)addData:(NSData *)data name:(NSString *)name mimeType:(NSString *)mime fileName:(NSString *)fileName;

- (void)addFileFromPath:(NSString *)path name:(NSString *)name;
- (void)addFileFromPath:(NSString *)path name:(NSString *)name mimeType:(NSString *)mime;
- (void)addFileFromPath:(NSString *)path name:(NSString *)name mimeType:(NSString *)mime fileName:(NSString *)fileName;

- (NSMutableURLRequest *)makeURLRequest;

- (NSInputStream *)makeNewStream;

- (NSString *)methodAsString;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) HttpMethod method;
@property (nonatomic, assign) HttpBodyEncoding bodyEncoding;
@property (nonatomic, copy) IOHTTPRequestProgressCallback onProgress;
@property (nonatomic, copy) IOHTTPRequestProgressCallback onDlProgress;
@property (nonatomic, strong, readonly) NSDictionary *headers;
@property (nonatomic, strong, readonly) NSDictionary *params;
@property (nonatomic, strong, readonly) NSArray *files;
@property (nonatomic, strong, readonly)	NSArray *datas;

@property (strong, nonatomic) NSString *saveFilePath;

@end
