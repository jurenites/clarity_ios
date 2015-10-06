//
//  FileCacheRequest.h
//  Brabble-iOSClient
//
//  Created by Alexey on 2/14/14.
//
//

#import <Foundation/Foundation.h>

@interface FileCacheRequest : NSObject

@property (strong, nonatomic) NSString *cacheName;
@property (strong, nonatomic) NSString *fileName;
@property (assign, nonatomic) BOOL writeToFileDirectly;
@property (assign, nonatomic) BOOL onHold;

@end
