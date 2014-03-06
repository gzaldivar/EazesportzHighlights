//
//  Athlete.h
//  smpwlions
//
//  Created by Gilbert Zaldivar on 3/26/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "User.h"
#import "Team.h"
#import "GameSchedule.h"

#import "BasketballStats.h"

#import "FootballPassingStat.h"
#import "FootballDefenseStats.h"
#import "FootballKickerStats.h"
#import "FootballPlaceKickerStats.h"
#import "FootballPunterStats.h"
#import "FootballReceivingStat.h"
#import "FootballRushingStat.h"
#import "FootballReturnerStats.h"

#import "Soccer.h"

@interface Athlete : NSObject

@property(nonatomic, strong) NSNumber *number;
@property(nonatomic, strong) NSString *lastname;
@property(nonatomic, strong) NSString *middlename;
@property(nonatomic, strong) NSString *firstname;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *full_name;
@property(nonatomic, strong) NSString *logname;
@property(nonatomic, strong) NSString *height;
@property(nonatomic, strong) NSNumber *weight;
@property(nonatomic, strong) NSString *position;
@property(nonatomic, strong) NSString *year;
@property(nonatomic, strong) NSString *season;
@property(nonatomic, strong) NSString *bio;
@property(nonatomic, strong) NSString *athleteid;
@property(nonatomic, strong) NSString *teamid;
@property(nonatomic, strong) NSString *tinypic;
@property(nonatomic, strong) NSString *thumb;
@property(nonatomic, strong) NSString *mediumpic;
@property(nonatomic, strong) NSString *largepic;
@property(nonatomic, strong) NSString *teamname;
@property(nonatomic, strong) NSNumber *following;
@property(nonatomic, assign) BOOL hasphotos;
@property(nonatomic, assign) BOOL hasvideos;
@property(nonatomic, assign) BOOL processing;

@property(nonatomic, strong) NSMutableArray *football_passing_stats;
@property(nonatomic, strong) NSMutableArray *football_rushing_stats;
@property(nonatomic, strong) NSMutableArray *football_receiving_stats;
@property(nonatomic, strong) NSMutableArray *football_defense_stats;
@property(nonatomic, strong) NSMutableArray *football_place_kicker_stats;
@property(nonatomic, strong) NSMutableArray *football_returner_stats;
@property(nonatomic, strong) NSMutableArray *football_kicker_stats;
@property(nonatomic, strong) NSMutableArray *football_punter_stats;

@property(nonatomic, strong) NSMutableArray *basketball_stats;

@property(nonatomic, strong) NSMutableArray *soccer_stats;

@property(nonatomic, strong) NSImage *thumbimage;
@property(nonatomic, strong) NSImage *tinyimage;
@property(nonatomic, strong) NSImage *mediumimage;

@property(nonatomic, strong) NSString *httperror;

- (NSString *)numberLogname;

- (id)initWithDictionary:(NSDictionary *)athleteDictionary Sport:(Sport *)sport;

- (void)saveAthlete:(Sport *)sport Team:(Team *)team User:(User *)user;

- (void)deleteAthlete:(Sport *)sport User:(User *)user;

- (FootballPassingStat *)findFootballPassingStat:(NSString *)gameid;
- (FootballPassingStat *)findFootballPassingStatById:(NSString *)stat_id;
- (void)updateFootballPassingGameStats:(FootballPassingStat *)passingstat;
- (FootballRushingStat *)findFootballRushingStat:(NSString *)gameid;
- (FootballRushingStat *)findFootballRushingStatById:(NSString *)stat_id;
- (void)updateFootballRushingGameStats:(FootballRushingStat *)rushingstat;
- (FootballReceivingStat *)findFootballReceivingStat:(NSString *)gameid;
- (FootballReceivingStat *)findFootballReceivingStatById:(NSString *)stat_id;
- (void)updateFootballReceivingGameStats:(FootballReceivingStat *)receivingstat;
- (FootballDefenseStats *)findFootballDefenseStat:(NSString *)gameid;
- (FootballDefenseStats *)findFootballDefenseStatById:(NSString *)stat_id;
- (void)updateFootballDefenseGameStats:(FootballDefenseStats *)defensestat;
- (FootballKickerStats *)findFootballKickerStat:(NSString *)gameid;
- (FootballKickerStats *)findFootballKickerStatById:(NSString *)stat_id;
- (void)updateFootballKickerGameStats:(FootballKickerStats *)kickerstat;
- (FootballPlaceKickerStats *)findFootballPlaceKickerStat:(NSString *)gameid;
- (FootballPlaceKickerStats *)findFootballPlaceKickerStatById:(NSString *)stat_id;
- (void)updateFootballPlaceKickerGameStats:(FootballPlaceKickerStats *)placekickerstat;
- (FootballPunterStats *)findFootballPunterStat:(NSString *)gameid;
- (FootballPunterStats *)findFootballPunterStatById:(NSString *)stat_id;
- (void)updateFootballPunterGameStats:(FootballPunterStats *)punterstat;
- (FootballReturnerStats *)findFootballReturnerStat:(NSString *)gameid;
- (FootballReturnerStats *)findFootballReturnerStatById:(NSString *)stat_id;
- (void)updateFootballReturnerGameStats:(FootballReturnerStats *)returnerstat;

- (FootballPassingStat *)getFBPassingStat:(NSString *)gameid;
- (FootballRushingStat *)getFBRushingStat:(NSString *)gameid;
- (FootballReceivingStat *)getFBReceiverStat:(NSString *)gameid;
- (FootballDefenseStats *)getFBDefenseStat:(NSString *)gameid;
- (FootballPlaceKickerStats *)getFBPlaceKickerStat:(NSString *)gameid;
- (FootballKickerStats *)getFBKickerStat:(NSString *)gameid;
- (FootballPunterStats *)getFBPunterStat:(NSString *)gameid;
- (FootballReturnerStats *)getFBReturnerStat:(NSString *)gameid;

- (BOOL)saveFootballGameStats:(Sport *)sport Team:(Team *)team Game:(GameSchedule *)game User:(User *)user;

- (BOOL)isQB:(NSString *)gameid;
- (BOOL)isRB:(NSString *)gameid;
- (BOOL)isWR:(NSString *)gameid;
- (BOOL)isOL:(NSString *)gameid;
- (BOOL)isDEF:(NSString *)gameid;
- (BOOL)isPK:(NSString *)gameid;
- (BOOL)isKicker:(NSString *)gameid;
- (BOOL)isPunter:(NSString *)gameid;
- (BOOL)isReturner:(NSString *)gameid;

- (NSString *)getBasketballStatGameId:(NSString *)basketball_stat_id;
- (BasketballStats *)findBasketballGameStatEntries:(NSString *)gameid;
- (void)updateBasketballGameStats:(BasketballStats *)bballstats;

- (BOOL)saveBasketballGameStats:(Sport *)sport Team:(Team *)team Game:(GameSchedule *)game User:(User *)user;

- (BasketballStats *)basketballSeasonTotals;

- (Soccer *)findSoccerStats:(NSString *)statid;
- (Soccer *)findSoccerGameStats:(NSString *)gameid;
- (void)updateSoccerGameStats:(Soccer *)soccerstat;

- (BOOL)saveSoccerGameStats:(Sport *)sport Team:(Team *)team Game:(GameSchedule *)game User:(User *)user;

- (BOOL)isSoccerGoalie;

- (Soccer *)soccerSeasonTotals;

- (NSImage *)getImage:(NSString *)size;

@end
