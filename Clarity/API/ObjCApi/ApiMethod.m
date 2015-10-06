//
//  ApiMethod.m
//  Brabble-iOSClient
//
//  Created by Alexey Klyotzin on 1/15/14.
//
//

#import "ApiMethod.h"
#import "NSObject+Api.h"

@interface ApiMethod ()
{
    NSString *_url;
}
@end

@implementation ApiMethod

+ (instancetype)srv:(AMServer)server
             method:(HttpMethod)httpMethod
                url:(NSString*)url
{
    return [[ApiMethod alloc] initWithServer:server httpMethod:httpMethod url:url];
}

+ (instancetype)method:(HttpMethod)httpMethod
                   url:(NSString *)url
{
    return [[ApiMethod alloc] initWithServer:AMSUser httpMethod:httpMethod url:url];
}

- (instancetype)initWithServer:(AMServer)server
                    httpMethod:(HttpMethod)httpMethod
                           url:(NSString*)url
{
    self = [super init];
    if (!self)
        return nil;
    
    _server = server;
    _httpMethod = httpMethod;
    _url = url;
    
    return self;
}

- (NSSet *)extractUrlParamNames:(NSString*)url
{
    static NSRegularExpression *regex = nil;
    
    if (!regex) {
        regex = [[NSRegularExpression alloc] initWithPattern:@":[a-z0-9_]+"
                                                     options:0
                                                       error:nil];
    }
    
    NSArray *matches = [regex matchesInString:url options:0 range:NSMakeRange(0, url.length)];
    
    NSMutableSet *names = [NSMutableSet set];
    
    for (NSTextCheckingResult *cr in matches) {
        [names addObject:
            [url substringWithRange:
                NSMakeRange(cr.range.location + 1, cr.range.length - 1)]];
    }
    
    return names;
}

- (NSString *)buildUrlWithParams:(NSDictionary*)params
{
    NSMutableString *url = [_url mutableCopy];
    NSSet *paramNames = [self extractUrlParamNames:url];
    
    for (NSString *paramName in paramNames) {
        NSAssert(params[paramName], @"buildUrlWithParams: no param %@ supplied", paramName);
        
        [url replaceOccurrencesOfString:[NSString stringWithFormat:@":%@", paramName]
                             withString:ToString(params[paramName])
                                options:0
                                  range:NSMakeRange(0, url.length)];
    }

    return url;
}

@end
