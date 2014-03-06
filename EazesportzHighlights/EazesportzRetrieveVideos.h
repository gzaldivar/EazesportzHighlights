//
//  EazesportzRetrieveVideos.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 3/1/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "User.h"
#import "Team.h"
#import "GameSchedule.h"
#import "Video.h"

@interface EazesportzRetrieveVideos : NSObject

@property(nonatomic, strong) NSMutableArray *videos;

- (void)retrieveVideos:(Sport *)sport Team:(Team *)team Game:(GameSchedule *)game User:(User *)user;

@end
