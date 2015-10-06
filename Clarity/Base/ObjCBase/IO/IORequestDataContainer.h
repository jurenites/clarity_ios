//
//  DataContainer.h
//  Brabble-iOSClient
//
//  Created by V1tol on 13.01.14.
//
//

#import <Foundation/Foundation.h>

@interface IODataContainer : NSObject

@property (nonatomic,strong) NSData *data;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *mime;
@property (nonatomic,strong) NSString *fileName;

@end

@interface IOFileContainer : NSObject

@property (nonatomic,strong) NSString *filePath;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *mime;
@property (nonatomic,strong) NSString *fileName;

@end

