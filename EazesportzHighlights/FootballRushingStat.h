//
//  FootballRushingStat.h
//  EazeSportz
//
//  Created by Gil on 11/20/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "User.h"

@interface FootballRushingStat : NSObject

@property(nonatomic, strong) NSNumber *attempts;
@property(nonatomic, strong) NSNumber *yards;
@property(nonatomic, strong) NSNumber *average;
@property(nonatomic, strong) NSNumber *td;
@property(nonatomic, strong) NSNumber *longest;
@property(nonatomic, strong) NSNumber *fumbles;
@property(nonatomic, strong) NSNumber *fumbles_lost;
@property(nonatomic, strong) NSNumber *firstdowns;
@property(nonatomic, strong) NSNumber *twopointconv;

@property(nonatomic, strong) NSString *football_rushing_id;
@property(nonatomic, strong) NSString *athlete_id;
@property(nonatomic, strong) NSString *gameschedule_id;

@property(nonatomic, strong) NSString *httperror;

- (id)initWithDictionary:(NSDictionary *)rushingDictionary;
- (id)copyWithZone:(NSZone *)zone;

- (BOOL)saveStats:(Sport *)sport User:(User *)user;

@end
