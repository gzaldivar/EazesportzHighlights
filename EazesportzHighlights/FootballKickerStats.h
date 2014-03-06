//
//  FootballKickerStats.h
//  EazeSportz
//
//  Created by Gil on 11/20/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "User.h"

@interface FootballKickerStats : NSObject

@property(nonatomic, strong) NSNumber *koattempts;
@property(nonatomic, strong) NSNumber *kotouchbacks;
@property(nonatomic, strong) NSNumber *koreturned;

@property(nonatomic, strong) NSString *football_kicker_id;
@property(nonatomic, strong) NSString *athlete_id;
@property(nonatomic, strong) NSString *gameschedule_id;

@property(nonatomic, strong) NSString *httperror;

- (id)initWithDictionary:(NSDictionary *)kickerDictionary;
- (id)copyWithZone:(NSZone *)zone;

- (BOOL)saveStats:(Sport *)sport User:(User *)user;

@end
