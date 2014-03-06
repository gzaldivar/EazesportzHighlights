//
//  Sport.h
//  sportzSoftwareHome
//
//  Created by Gil on 2/6/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sport : NSObject

@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSString *sitename;
@property(nonatomic, strong) NSString *mascot;
@property(nonatomic, strong) NSString *banner;
@property(nonatomic, strong) NSString *siteid;
@property(nonatomic, strong) NSString *season;
@property(nonatomic, strong) NSString *year;
@property(nonatomic, strong) NSString *zip;
@property(nonatomic, strong) NSString *state;
@property(nonatomic, strong) NSString *city;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *sport_logo_thumb;
@property(nonatomic, strong) NSString *sport_logo_tiny;
@property(nonatomic, strong) NSNumber *has_stats;
@property(nonatomic, strong) NSNumber *alert_interval;
@property(nonatomic, strong) NSNumber *gamelog_interval;
@property(nonatomic, strong) NSNumber *newsfeed_interval;
@property(nonatomic, assign) BOOL beta;
@property(nonatomic, assign) BOOL approved;

@property(nonatomic, strong) NSString *package;
@property(nonatomic, assign) int silverMedia;
@property(nonatomic, assign) int goldMedia;
@property(nonatomic, assign) int platinumMedia;

@property(nonatomic, strong) NSNumber *teamcount;

@property(nonatomic, strong) NSMutableDictionary *playerPositions;

@property(nonatomic, strong) NSMutableDictionary *footballOffensePositions;
@property(nonatomic, strong) NSMutableDictionary *footballDefensePositions;
@property(nonatomic, strong) NSMutableDictionary *footballSpecialTeamsPositions;

@property(nonatomic, strong) NSImage *sportimage;

- (NSImage *)getImage:(NSString *)size;

- (id)initWithDictionary:(NSDictionary *)sportDictionary;

- (BOOL)isPackageEnabled;
- (BOOL)isGoldPackage;

@end
