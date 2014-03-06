//
//  FootballReturnerStats.h
//  EazeSportz
//
//  Created by Gil on 11/20/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "User.h"

@interface FootballReturnerStats : NSObject

@property(nonatomic, strong) NSNumber *punt_return;
@property(nonatomic, strong) NSNumber *punt_returnyards;
@property(nonatomic, strong) NSNumber *punt_returntd;
@property(nonatomic, strong) NSNumber *punt_returnlong;

@property(nonatomic, strong) NSNumber *koreturn;
@property(nonatomic, strong) NSNumber *kotd;
@property(nonatomic, strong) NSNumber *koyards;
@property(nonatomic, strong) NSNumber *kolong;

@property(nonatomic, strong) NSString *football_returner_id;
@property(nonatomic, strong) NSString *athlete_id;
@property(nonatomic, strong) NSString *gameschedule_id;

@property(nonatomic,strong) NSString *httperror;

- (id)initWithDictionary:(NSDictionary *)returnerDictionary;
- (id)copyWithZone:(NSZone *)zone;

- (BOOL)saveStats:(Sport *)sport User:(User *)user;

@end
