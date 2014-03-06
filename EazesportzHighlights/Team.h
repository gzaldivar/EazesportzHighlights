//
//  Team.h
//  smpwlions
//
//  Created by Gil on 3/9/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "User.h"

@interface Team : NSObject

@property(nonatomic, strong)NSString* teamid;
@property(nonatomic, strong)NSString* mascot;
@property(nonatomic, strong)NSString* title;
@property(nonatomic, strong)NSString* team_name;
@property(nonatomic, strong) NSString *team_logo;
@property(nonatomic, strong) NSString *tiny_logo;

@property(nonatomic, strong) NSMutableArray *fb_pass_players;
@property(nonatomic, strong) NSMutableArray *fb_rush_players;
@property(nonatomic, strong) NSMutableArray *fb_rec_players;
@property(nonatomic, strong) NSMutableArray *fb_def_players;
@property(nonatomic, strong) NSMutableArray *fb_placekickers;
@property(nonatomic, strong) NSMutableArray *fb_punters;
@property(nonatomic, strong) NSMutableArray *fb_kickers;
@property(nonatomic, strong) NSMutableArray *fb_returners;

@property(nonatomic, strong) NSString *httpError;

@property(nonatomic, strong)NSImage *teamimage;

- (id)initWithDictionary:(NSDictionary *)teamDictionary Sport:(Sport *)sport;

- (NSImage *)getImage:(NSString *)size Sport:(Sport *)sport;
- (BOOL)hasImage;

- (BOOL)saveTeam:(Sport *)sport User:(User *)user;

@end
