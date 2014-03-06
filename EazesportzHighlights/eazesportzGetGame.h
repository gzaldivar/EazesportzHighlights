//
//  eazesportzGetGame.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/27/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GameSchedule.h"
#import "Sport.h"
#import "Team.h"
#import "User.h"

@interface eazesportzGetGame : NSObject

- (void)retrieveGame:(Sport *)sport Team:(Team *)team Game:(NSString *)gameid User:(User *)user;

- (GameSchedule *)getGameSynchronous:(Sport *)sport Team:(Team *)team Game:(NSString *)gameid User:(User *)user;

@property(nonatomic, strong, readonly) GameSchedule *game;

@end
