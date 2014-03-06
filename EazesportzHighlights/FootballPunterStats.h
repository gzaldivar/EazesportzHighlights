//
//  FootballPunterStats.h
//  EazeSportz
//
//  Created by Gil on 11/20/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "User.h"

@interface FootballPunterStats : NSObject

@property(nonatomic, strong) NSNumber *punts;
@property(nonatomic, strong) NSNumber *punts_blocked;
@property(nonatomic, strong) NSNumber *punts_long;
@property(nonatomic, strong) NSNumber *punts_yards;

@property(nonatomic, strong) NSString *football_punter_id;
@property(nonatomic, strong) NSString *athlete_id;
@property(nonatomic, strong) NSString *gameschedule_id;

@property(nonatomic, strong) NSString *httperror;

- (id)initWithDictionary:(NSDictionary *)punterDictionary;
- (id)copyWithZone:(NSZone *)zone;

- (BOOL)saveStats:(Sport *)sport User:(User *)user;

@end
