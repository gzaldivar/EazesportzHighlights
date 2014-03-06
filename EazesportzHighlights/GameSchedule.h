//
//  GameSchedule.h
//  smpwlions
//
//  Created by Gil on 3/15/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Gamelogs.h"
#import "Sport.h"
#import "User.h"

@interface GameSchedule : NSObject

@property(nonatomic, strong) NSString *team_id;
@property(nonatomic, strong) NSString *opponent;
@property(nonatomic, strong) NSString *opponentpic;
@property(nonatomic, assign) BOOL eazesportzOpponent;
@property(nonatomic, strong) NSString *opponent_mascot;
@property(nonatomic, strong) NSString *opponent_name;
@property(nonatomic, strong) NSString *startdate;
@property(nonatomic, strong) NSString *starttime;
@property(nonatomic, strong) NSString *location;
@property(nonatomic, assign) BOOL leaguegame;
@property(nonatomic, strong) NSString *event;
@property(nonatomic, strong) NSString *homeaway;
@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSString *game_name;
@property(nonatomic, strong) NSNumber *homeq1;
@property(nonatomic, strong) NSNumber *homeq2;
@property(nonatomic, strong) NSNumber *homeq3;
@property(nonatomic, strong) NSNumber *homeq4;
@property(nonatomic, strong) NSNumber *opponentq1;
@property(nonatomic, strong) NSNumber *opponentq2;
@property(nonatomic, strong) NSNumber *opponentq3;
@property(nonatomic, strong) NSNumber *opponentq4;
@property(nonatomic, strong) NSNumber *firstdowns;
@property(nonatomic, strong) NSNumber *penalty;
@property(nonatomic, strong) NSNumber *penaltyyards;
@property(nonatomic, strong) NSString *currentgametime;
@property(nonatomic, strong) NSNumber *ballon;
@property(nonatomic, strong) NSString *possession;
@property(nonatomic, strong) NSString *lastplay;
@property(nonatomic, strong) NSNumber *own;
@property(nonatomic, strong) NSString *our;
@property(nonatomic, strong) NSNumber *down;
@property(nonatomic, strong) NSString *currentqtr;
@property(nonatomic, assign) BOOL gameisfinal;
@property(nonatomic, strong) NSNumber *togo;

@property(nonatomic, strong) NSDate *gamedatetime;

@property(nonatomic, strong) NSNumber *homescore;
@property(nonatomic, strong) NSNumber *opponentscore;
@property(nonatomic, strong) NSNumber *hometimeouts;
@property(nonatomic, strong) NSNumber *opponenttimeouts;
@property(nonatomic, strong) NSNumber *homefouls;
@property(nonatomic, strong) NSNumber *visitorfouls;
@property(nonatomic, assign) BOOL homebonus;
@property(nonatomic, assign) BOOL visitorbonus;
@property(nonatomic, strong) NSNumber *period;

@property(nonatomic, strong) NSNumber *socceroppck;
@property(nonatomic, strong) NSNumber *socceroppsog;
@property(nonatomic, strong) NSNumber *socceroppsaves;

@property(nonatomic, strong) NSMutableArray *gamelogs;
@property(nonatomic, strong) NSMutableArray *liveevents;

@property(nonatomic, strong) NSString *httperror;

- (id)initWithDictionary:(NSDictionary *)gameScheduleDictionary Sport:(Sport *)sport;

- (void)saveGameschedule:(Sport *)sport User:(User *)user;

- (void)deleteGame:(Sport *)sport Team:(Team *)team User:(User *)user;

- (BOOL)isaLiveGame;
- (NSImage *)opponentImage;

- (Gamelogs *)findGamelog:(NSString *)gamelogid;
- (void)updateGamelog:(Gamelogs *)gamelog;

- (int)soccerHomeCK;
- (int)soccerHomeSaves;
- (int)soccerHomeShots;

- (int)homeBasketballFouls;

- (NSString *)vsOpponent;

@end
