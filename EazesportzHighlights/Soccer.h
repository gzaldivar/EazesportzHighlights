//
//  Soccer.h
//  EazeSportz
//
//  Created by Gil on 11/4/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "User.h"

@interface Soccer : NSObject

@property(nonatomic, strong) NSString *soccerid;
@property(nonatomic, strong) NSString *gameschedule_id;
@property(nonatomic, strong) NSNumber *goals;
@property(nonatomic, strong) NSNumber *shotstaken;
@property(nonatomic, strong) NSNumber *assists;
@property(nonatomic, strong) NSNumber *steals;
@property(nonatomic, strong) NSNumber *goalsagainst;
@property(nonatomic, strong) NSNumber *goalssaved;
@property(nonatomic, strong) NSNumber *shutouts;
@property(nonatomic, strong) NSNumber *minutesplayed;
@property(nonatomic, strong) NSNumber *cornerkicks;

@property(nonatomic, strong) NSString *athleteid;

@property(nonatomic,strong) NSString *httperror;

- (id)initWithDirectory:(NSDictionary *)soccerDirectory AthleteId:(NSString *)playerid;
- (id)copyWithZone:(NSZone *)zone;

- (BOOL)goalieStats;

- (BOOL)saveStats:(Sport *)sport User:(User *)user;

@end
