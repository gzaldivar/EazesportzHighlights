//
//  FootballPlaceKickerStats.h
//  EazeSportz
//
//  Created by Gil on 11/20/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "User.h"

@interface FootballPlaceKickerStats : NSObject

@property(nonatomic, strong) NSNumber *fgattempts;
@property(nonatomic, strong) NSNumber *fgmade;
@property(nonatomic, strong) NSNumber *fgblocked;
@property(nonatomic, strong) NSNumber *fglong;
@property(nonatomic, strong) NSNumber *xpattempts;
@property(nonatomic, strong) NSNumber *xpmade;
@property(nonatomic, strong) NSNumber *xpmissed;
@property(nonatomic, strong) NSNumber *xpblocked;

@property(nonatomic, strong) NSString *football_place_kicker_id;
@property(nonatomic, strong) NSString *athlete_id;
@property(nonatomic, strong) NSString *gameschedule_id;

@property(nonatomic, strong) NSString *httperror;

- (id)initWithDictionary:(NSDictionary *)placekickerDictionary;
- (id)copyWithZone:(NSZone *)zone;

- (BOOL)saveStats:(Sport *)sport User:(User *)user;

@end
