//
//  IOHTTPStream2.h
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/12/14.
//
//

#import <Foundation/Foundation.h>

@interface IOHTTPStream : NSObject

- (void)addParams:(NSDictionary *)dict;
- (void)addParam:(id)value name:(NSString *)name;

- (void)addData:(NSData *)data name:(NSString *)name;
- (void)addData:(NSData *)data name:(NSString *)name mimeType:(NSString *)mime;
- (void)addData:(NSData *)data name:(NSString *)name mimeType:(NSString *)mime fileName:(NSString *)fileName;

- (void)addFileFromPath:(NSString *)path;
- (void)addFileFromPath:(NSString *)path name:(NSString *)name;
- (void)addFileFromPath:(NSString *)path name:(NSString *)name mimeType:(NSString *)mime;
- (void)addFileFromPath:(NSString *)path name:(NSString *)name mimeType:(NSString *)mime fileName:(NSString *)fileName;

- (NSString *)encoding;

- (void)start;

@property (nonatomic, readonly) NSInputStream *stream;
@property (nonatomic, readonly) unsigned long long length;
@property (nonatomic, readonly) NSString *boundary;

@end
