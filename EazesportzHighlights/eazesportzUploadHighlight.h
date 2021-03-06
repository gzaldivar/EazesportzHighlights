//
//  eazesportzUploadHighlight.h
//  EazesportzHighlights
//
//  Created by Gilbert Zaldivar on 3/6/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "Team.h"
#import "GameSchedule.h"
#import "User.h"
#import "Video.h"

#import <AWSiOSSDK/S3/AmazonS3Client.h>

@interface eazesportzUploadHighlight : NSObject

@property (nonatomic, strong) Sport *sport;
@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) GameSchedule *game;
@property (nonatomic, strong) NSMutableArray *players;
@property (nonatomic, strong) User *user;
@property (nonatomic, assign) int clipindex;

@property (nonatomic, strong) NSString *bucket;
@property (nonatomic, strong) AmazonS3Client *s3;

- (void)uploadVideo:(NSString *)pathname Video:(Video *)video Hidden:(BOOL)hidden;

@end
