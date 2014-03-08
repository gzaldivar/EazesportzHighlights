//
//  eazesportzAVClip.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/11/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "Video.h"

#import <AWSiOSSDK/S3/AmazonS3Client.h>

@interface eazesportzAVClip : NSObject

@property (nonatomic, strong) NSNumber *clipNumber;
@property (nonatomic, strong) NSString *clipName;
@property (nonatomic, strong) AVAssetExportSession *clip;
@property (nonatomic, strong) NSString *awsvideoobject;
@property (nonatomic, strong) NSString *awsposterobject;
@property (nonatomic, strong) Video *video;
@property (nonatomic, strong) NSImage *posterImage;
@property (nonatomic, assign) NSString *uploaded;

- (NSString *)getFilepathFromOutputUrl;

@end
