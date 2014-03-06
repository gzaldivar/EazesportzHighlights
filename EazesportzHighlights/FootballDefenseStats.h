//
//  FootballDefenseStats.h
//  EazeSportz
//
//  Created by Gil on 11/20/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "User.h"

@interface FootballDefenseStats : NSObject

@property(nonatomic, strong) NSNumber *tackles;
@property(nonatomic, strong) NSNumber *assists;
@property(nonatomic, strong) NSNumber *sacks;
@property(nonatomic, strong) NSNumber *pass_defended;
@property(nonatomic, strong) NSNumber *interceptions;
@property(nonatomic, strong) NSNumber *int_yards;
@property(nonatomic, strong) NSNumber *int_long;
@property(nonatomic, strong) NSNumber *td;
@property(nonatomic, strong) NSNumber *fumbles_recovered;
@property(nonatomic, strong) NSNumber *safety;
@property(nonatomic, strong) NSNumber *sackassist;

@property(nonatomic, strong) NSString *football_defense_id;
@property(nonatomic, strong) NSString *athlete_id;
@property(nonatomic, strong) NSString *gameschedule_id;

@property(nonatomic, strong) NSString *httperror;

- (id)initWithDictionary:(NSDictionary *)defenseDirectory;
- (id)copyWithZone:(NSZone *)zone;

- (BOOL)saveStats:(Sport *)sport User:(User *)user;

@end
