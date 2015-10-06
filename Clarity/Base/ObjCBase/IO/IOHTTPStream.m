//
//  IOHTTPStream2.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 3/12/14.
//
//

#import "IOHTTPStream.h"
#import "NSObject+Api.h"

static NSString * const IsDefMimeType = @"application/octet-stream";
static NSString * const IsDefFileName = @"file";
static NSString * const IsFieldFormat = @"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@";
static NSString * const IsFieldFooter = @"\r\n";
static NSString * const IsDataFormat  = @"--%@\r\nContent-Disposition: form-data; name=\"%@\"; "
                                        @"filename=\"%@\"\r\nContent-Type: %@\r\nContent-Transfer-Encoding: binary\r\n\r\n";
static NSString * const IsFooterFormat = @"--%@--\r\n";
static NSString * const IsBoundary     = @"0xKhTmLbOuNdArY";
static const NSStringEncoding IsEncoding = NSUTF8StringEncoding;
static const NSUInteger IsBufferSize     = 32768;

@interface NSStream (BoundPairAdditions)

+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr
                  outputStream:(NSOutputStream **)outputStreamPtr
                    bufferSize:(NSUInteger)bufferSize;

@end

@implementation NSStream (BoundPairAdditions)

+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr
                  outputStream:(NSOutputStream **)outputStreamPtr
                    bufferSize:(NSUInteger)bufferSize
{
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    
    assert((inputStreamPtr != NULL) || (outputStreamPtr != NULL));
    
    CFStreamCreateBoundPair(
        NULL,
        ((inputStreamPtr  != nil) ? &readStream : NULL),
        ((outputStreamPtr != nil) ? &writeStream : NULL),
        (CFIndex) bufferSize);
    
    
    if (inputStreamPtr != NULL) {
        *inputStreamPtr  = CFBridgingRelease(readStream);
    }
    if (outputStreamPtr != NULL) {
        *outputStreamPtr = CFBridgingRelease(writeStream);
    }
}

@end

//================================
@interface IOHTTPStream () <NSStreamDelegate>
{
    NSData *_footer;
    NSData *_fieldEnd;
    NSMutableData *_fieldsData;
    NSMutableArray *_streamsArray;
    
    NSUInteger _streamIndex;
    unsigned long long _amountSent;
    
    NSInputStream *_consumerStream;
    NSOutputStream *_producerStream;
    
    uint8_t *_buffer;
//    NSUInteger _bufferCapacity;
    NSUInteger _bufferLen;
    NSUInteger _bufferOffset;
    
    
    NSUInteger _totalWritten ;
    
}

- (void)stopSend;

@end

@implementation IOHTTPStream

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _boundary = IsBoundary;
    _streamsArray = [NSMutableArray array];
    _fieldsData = [NSMutableData data];
    _footer = [[NSString stringWithFormat:IsFooterFormat, IsBoundary] dataUsingEncoding:IsEncoding];
    _fieldEnd = [IsFieldFooter dataUsingEncoding:IsEncoding];
    _length = [_footer length];
    _streamIndex = 0;
    _amountSent = 0;
    
    _buffer = calloc(IsBufferSize, sizeof(uint8_t));
    _bufferLen = 0;
    _bufferOffset = 0;
    
    return self;
}

- (void)dealloc
{
    free(_buffer);
}

#pragma mark - IOStreaming global functions

- (void)addParams:(NSDictionary*)dict
{
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self addParam:obj name:key];
    }];
}

- (void)addParam:(id)value name:(NSString *)name
{
    NSParameterAssert(value);
    NSParameterAssert(name.length);
    
    NSData *valueData = nil;
    
    if ([value isKindOfClass:[NSData class]]) {
        [self addData:(NSData *)value name:name];
    } else if ([value isArray] || [value isDict]) {
        valueData = [ToJSON(value) dataUsingEncoding:IsEncoding];
    } else {
        valueData = [ToString(value) dataUsingEncoding:IsEncoding];
    }
    
    NSString *formatted = [NSString stringWithFormat:IsFieldFormat, IsBoundary, name, @""];
    NSData *encoded = [formatted dataUsingEncoding:IsEncoding];
    
    [_fieldsData appendData:encoded];
    [_fieldsData appendData:valueData];
    [_fieldsData appendData:_fieldEnd];
    
    _length += [encoded length] + [valueData length] + [_fieldEnd length];
}

- (void)addData:(NSData*)data name:(NSString *)name
{
    NSParameterAssert(data);
    NSParameterAssert(name.length);
    
    [self addData:data name:name mimeType:IsDefMimeType];
}

- (void)addData:(NSData*)data name:(NSString *)name mimeType:(NSString *)mime
{
    NSParameterAssert(data);
    NSParameterAssert(name.length);
    
    [self addData:data name:name mimeType:mime fileName:IsDefFileName];
}

- (void)addData:(NSData*)data name:(NSString *)name mimeType:(NSString *)mime fileName:(NSString *)fileName
{
    NSParameterAssert(data);
    NSParameterAssert(name.length);
    
    if (mime.length == 0) {
        mime = IsDefMimeType;
    }
    if (fileName.length == 0) {
        fileName = IsDefFileName;
    }
    
    NSData *valueData;
    if ([data isKindOfClass:[NSData class]]) {
        valueData = data;
	} else {
        valueData = [ToString(data) dataUsingEncoding:IsEncoding];
    }
    
    NSString *formatted = [NSString stringWithFormat:IsDataFormat, IsBoundary, name, fileName, mime];
    NSData *encoded = [formatted dataUsingEncoding:IsEncoding];
    [_streamsArray addObject:[NSInputStream inputStreamWithData:encoded]];
    [_streamsArray addObject:[NSInputStream inputStreamWithData:valueData]];
    [_streamsArray addObject:[NSInputStream inputStreamWithData:_fieldEnd]];
    
    _length += [encoded length] + [valueData length] + [_fieldEnd length];
}

- (void)addFileFromPath:(NSString *)path
{
    [self addFileFromPath:path name:IsDefFileName];
}

- (void)addFileFromPath:(NSString *)path name:(NSString *)name
{
    [self addFileFromPath:path name:name mimeType:IsDefMimeType];
}

- (void)addFileFromPath:(NSString *)path name:(NSString *)name mimeType:(NSString *)mime
{
    [self addFileFromPath:path name:name mimeType:mime fileName:IsDefFileName];
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
    
    if (mime.length == 0) {
        mime = IsDefMimeType;
    }
    if (fileName.length == 0) {
        fileName = IsDefFileName;
    }
    
    NSString* formatted = [NSString stringWithFormat:IsDataFormat, IsBoundary, name, fileName, mime];
    NSData* encoded = [formatted dataUsingEncoding:IsEncoding];
    
    [_streamsArray addObject:[NSInputStream inputStreamWithData:encoded]];
    [_streamsArray addObject:[NSInputStream inputStreamWithFileAtPath:path]];
    [_streamsArray addObject:[NSInputStream inputStreamWithData:_fieldEnd]];
    
    unsigned long long fileLen = [[[NSFileManager defaultManager]
                                   attributesOfItemAtPath:path error:NULL] fileSize];
    
    _length += [encoded length] + fileLen + [_fieldEnd length];
}

- (NSString*)encoding
{
    return (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(IsEncoding));
}

- (NSInputStream *)stream
{
    return _consumerStream;
}

//===========================================
- (void)start
{
    if (_fieldsData.length) {
        [_streamsArray insertObject:[NSInputStream inputStreamWithData:_fieldsData] atIndex:0];
    }
    
    [_streamsArray addObject:[NSInputStream inputStreamWithData:_footer]];
    
    NSInputStream *consStream = nil;
    NSOutputStream *prodStream = nil;
    
    [NSStream createBoundInputStream:&consStream outputStream:&prodStream bufferSize:IsBufferSize];
    
    _consumerStream = consStream;
    _producerStream = prodStream;
    
    _producerStream.delegate = self;
    [_producerStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_producerStream open];
}

- (NSInputStream *)currentStream
{
    if (_streamIndex >= _streamsArray.count) {
        return nil;
    }
    
    NSInputStream *stream = [_streamsArray objectAtIndex:_streamIndex];
    
    if (stream.streamStatus == NSStreamStatusNotOpen) {
        [stream open];
    } else if (stream.streamStatus == NSStreamStatusAtEnd) {
        [stream close];
        _streamIndex++;
        
        return [self currentStream];
    }
    
    return stream;
}

- (void)sendMoreData
{
    if (_bufferOffset >= _bufferLen) {
        NSInputStream *currentStream = [self currentStream];
        
        if (!currentStream) { //No more data
            _producerStream.delegate = nil;
            [_producerStream close];
            return;
        }
        
        NSInteger readed = [currentStream read:_buffer maxLength:IsBufferSize];
        
        if (readed == -1) {
            [self stopSend];
            return;
        } else if (readed == 0) {
            [self sendMoreData];
            return;
        } else {
            _bufferLen = readed;
            _bufferOffset = 0;
        }
    }
    
    NSInteger written = [_producerStream write:(_buffer + _bufferOffset)
                                     maxLength:(_bufferLen - _bufferOffset)];
    
    if (written <= 0) {
        [self stopSend];
        return;
    }
    
    _bufferOffset += written;
    _totalWritten += written;
}

- (void)stopSend
{
    if (_producerStream) {
        _producerStream.delegate = nil;
        [_producerStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_producerStream close];
        _producerStream = nil;
    }
    
    _consumerStream = nil;
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    assert(aStream == _producerStream);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasSpaceAvailable:
            [self sendMoreData];
            break;
        case NSStreamEventErrorOccurred:
            [self stopSend];
            break;
        default:
            [self stopSend];
            break;
    }
}

@end
