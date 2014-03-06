//
//  Video.h
//  smpwlions
//
//  Created by Gilbert Zaldivar on 4/5/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GameSchedule.h"

@interface Video : NSObject

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSString *resolution;
@property (nonatomic, strong) NSString *video_url;
@property (nonatomic, strong) NSNumber *size;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSString *poster_url;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *teamid;
@property (nonatomic, strong) NSString *schedule;
@property (nonatomic, strong) NSMutableArray *players;
@property (nonatomic, strong) NSString *videoid;
@property (nonatomic, strong) NSString *userid;
@property (nonatomic, strong) NSString *gamelog;
@property (nonatomic, assign) BOOL hidden;

@property (nonatomic, strong) GameSchedule *game;
@property (nonatomic, strong) NSMutableArray *athletes;

- (id)initWithDirectory:(NSDictionary *)items;

- (NSImage *)posterImage;

@end
