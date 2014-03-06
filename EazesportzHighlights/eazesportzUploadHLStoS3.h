//
//  eazesportzUploadHLStoS3.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/22/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "User.h"

@interface eazesportzUploadHLStoS3 : NSThread

@property (nonatomic, strong) NSPipe *videopipe;
@property (nonatomic, strong) NSString *videoname;
@property (nonatomic, strong) User *user;

@end
