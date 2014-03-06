//
//  BasketballStats.h
//  Basketball Console
//
//  Created by Gilbert Zaldivar on 9/19/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "User.h"

@interface BasketballStats : NSObject

@property(nonatomic, strong) NSNumber *twoattempt;
@property(nonatomic, strong) NSNumber *twomade;
@property(nonatomic, strong) NSNumber *threeattempt;
@property(nonatomic, strong) NSNumber *threemade;
@property(nonatomic, strong) NSNumber *ftmade;
@property(nonatomic, strong) NSNumber *ftattempt;
@property(nonatomic, strong) NSNumber *fouls;
@property(nonatomic, strong) NSNumber *assists;
@property(nonatomic, strong) NSNumber *steals;
@property(nonatomic, strong) NSNumber *blocks;
@property(nonatomic, strong) NSNumber *offrebound;
@property(nonatomic, strong) NSNumber *defrebound;
@property(nonatomic, strong) NSNumber *turnovers;

@property(nonatomic, strong) NSString *gameschedule_id;
@property(nonatomic, strong) NSString *basketball_stat_id;
@property(nonatomic, strong) NSString *athleteid;

@property(nonatomic, strong) NSString *httperror;

- (id)initWithDirectory:(NSDictionary *)basketballStatDirectory AthleteId:(NSString *)playerid;
- (id)copyWithZone:(NSZone *)zone;

- (BOOL)saveStats:(Sport *)sport User:(User *)user;

@end
