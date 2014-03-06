//
//  FootballPassingStat.h
//  EazeSportz
//
//  Created by Gil on 11/20/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "User.h"

@interface FootballPassingStat : NSObject

@property(nonatomic, strong) NSNumber *attempts;
@property(nonatomic, strong) NSNumber *completions;
@property(nonatomic, strong) NSNumber *comp_percentage;
@property(nonatomic, strong) NSNumber *interceptions;
@property(nonatomic, strong) NSNumber *sacks;
@property(nonatomic, strong) NSNumber *td;
@property(nonatomic, strong) NSNumber *yards;
@property(nonatomic, strong) NSNumber *yards_lost;
@property(nonatomic, strong) NSNumber *firstdowns;
@property(nonatomic, strong) NSNumber *twopointconv;

@property(nonatomic, strong) NSString *football_passing_id;
@property(nonatomic, strong) NSString *athlete_id;
@property(nonatomic, strong) NSString *gameschedule_id;

@property(nonatomic, strong) NSString *httperror;

- (id)initWithDictionary:(NSDictionary *)passingDictionary;
- (id)copyWithZone:(NSZone *)zone;

- (BOOL)saveStats:(Sport *)sport User:(User *)user;

@end
