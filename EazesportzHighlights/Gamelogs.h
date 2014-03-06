//
//  Gamelogs.h
//  smpwlions
//
//  Created by Gilbert Zaldivar on 3/26/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sport.h"
#import "Team.h"
#import "User.h"

@interface Gamelogs : NSObject

@property(nonatomic, strong) NSString *gamelogid;
@property(nonatomic, strong) NSString *logentry;
@property(nonatomic, strong) NSString *logentrytext;
@property(nonatomic, strong) NSString *period;
@property(nonatomic, strong) NSString *score;
@property(nonatomic, strong) NSString *time;
@property(nonatomic, assign) BOOL hasphotos;
@property(nonatomic, assign) BOOL hasvideos;
@property(nonatomic, strong) NSString *player;
@property(nonatomic, strong) NSString *assistplayer;
@property(nonatomic, strong) NSNumber *yards;

@property(nonatomic, strong) NSString *football_passing_id;
@property(nonatomic, strong) NSString *football_rushing_id;
@property(nonatomic, strong) NSString *football_returner_id;
@property(nonatomic, strong) NSString *football_defense_id;
@property(nonatomic, strong) NSString *football_place_kicker_id;

@property(nonatomic, strong) NSString *gameschedule_id;

@property(nonatomic, strong) NSString *httperror;

- (id)initWithDictionary:(NSDictionary *)gamelogDictionary;
- (id)initDeleteGameLog:(Sport *)sport Team:(Team *)team User:(User *)user;

- (BOOL)saveGamelog:(Sport *)sport Team:(Team *)team User:(User *)user;

@end
