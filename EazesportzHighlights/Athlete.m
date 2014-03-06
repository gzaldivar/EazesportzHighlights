//
//  Athlete.m
//  smpwlions
//
//  Created by Gilbert Zaldivar on 3/26/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import "Athlete.h"
#import "EazesportzRetrievePlayers.h"

@implementation Athlete {
    NSString *imagesize;
    
    long responseStatusCode;
    NSMutableData *theData;
    BOOL deletePlayer;
    Sport *thesport;
    Team *theteam;
    User *theuser;
}

@synthesize number;
@synthesize lastname;
@synthesize firstname;
@synthesize middlename;
@synthesize name;
@synthesize full_name;
@synthesize logname;
@synthesize height;
@synthesize weight;
@synthesize position;
@synthesize year;
@synthesize season;
@synthesize bio;
@synthesize athleteid;
@synthesize tinypic;
@synthesize thumb;
@synthesize mediumpic;
@synthesize largepic;
@synthesize teamid;
@synthesize teamname;
@synthesize following;
@synthesize hasphotos;
@synthesize hasvideos;
@synthesize processing;

@synthesize football_passing_stats;
@synthesize football_rushing_stats;
@synthesize football_receiving_stats;
@synthesize football_defense_stats;
@synthesize football_kicker_stats;
@synthesize football_place_kicker_stats;
@synthesize football_punter_stats;
@synthesize football_returner_stats;

@synthesize basketball_stats;

@synthesize soccer_stats;

@synthesize thumbimage;
@synthesize tinyimage;
@synthesize mediumimage;

@synthesize httperror;

- (id)init {
    if (self = [super init]) {
        imagesize = @"";
        football_passing_stats = [[NSMutableArray alloc] init];
        football_rushing_stats = [[NSMutableArray alloc] init];
        football_receiving_stats = [[NSMutableArray alloc] init];
        football_defense_stats = [[NSMutableArray alloc] init];
        football_kicker_stats = [[NSMutableArray alloc] init];
        football_place_kicker_stats = [[NSMutableArray alloc] init];
        football_returner_stats = [[NSMutableArray alloc] init];
        football_punter_stats = [[NSMutableArray alloc] init];
        basketball_stats = [[NSMutableArray alloc] init];
        soccer_stats = [[NSMutableArray alloc] init];
        return self;
    } else
        return nil;
}

- (id)initWithDictionary:(NSDictionary *)athleteDictionary Sport:(Sport *)sport {
    if ((self == [super init]) && (athleteDictionary.count > 0)) {
        athleteid = [athleteDictionary objectForKey:@"id"];
        
        if ((NSNull *)[athleteDictionary objectForKey:@"number"] != [NSNull null])
            number = [athleteDictionary objectForKey:@"number"];
        else
            number = 0;
        
        bio = [athleteDictionary objectForKey:@"bio"];
        name = [athleteDictionary objectForKey:@"name"];
        full_name = [athleteDictionary objectForKey:@"full_name"];
        logname = [athleteDictionary objectForKey:@"logname"];
        firstname = [athleteDictionary objectForKey:@"firstname"];
        middlename = [athleteDictionary objectForKey:@"middlename"];
        lastname = [athleteDictionary objectForKey:@"lastname"];
        height = [athleteDictionary objectForKey:@"height"];
        
        if ((NSNull *)[athleteDictionary objectForKey:@"weight"] != [NSNull null])
            weight = [athleteDictionary objectForKey:@"weight"];
        else
            weight = 0;
        
        position = [athleteDictionary objectForKey:@"position"];
        year = [athleteDictionary objectForKey:@"year"];
        season = [athleteDictionary objectForKey:@"season"];
        teamid = [athleteDictionary objectForKey:@"team_id"];
        teamname = [athleteDictionary objectForKey:@"teamname"];
        tinypic = [athleteDictionary objectForKey:@"tiny"];
        thumb = [athleteDictionary objectForKey:@"thumb"];
        mediumpic = [athleteDictionary objectForKey:@"mediumpic"];
        largepic = [athleteDictionary objectForKey:@"largepic"];
        following = [NSNumber numberWithBool:[[athleteDictionary objectForKey:@"following"] boolValue]];
        hasvideos = [[athleteDictionary objectForKey:@"hasvideos"] boolValue];
        hasphotos = [[athleteDictionary objectForKey:@"hasphotos"] boolValue];
        
        [self getImage:@"tiny"];
        
        if ([sport.name isEqualToString:@"Football"]) {
            
            NSArray *passingstats = [athleteDictionary objectForKey:@"football_passings"];
            football_passing_stats = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < passingstats.count; i++) {
                [football_passing_stats addObject:[[FootballPassingStat alloc] initWithDictionary:
                                                   [[passingstats objectAtIndex:i] objectForKey:@"football_passing"]]];
            }
            
            NSArray *rushingstats = [athleteDictionary objectForKey:@"football_rushings"];
            football_rushing_stats = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < rushingstats.count; i++) {
                [football_rushing_stats addObject:[[FootballRushingStat alloc] initWithDictionary:
                                                   [[rushingstats objectAtIndex:i] objectForKey:@"football_rushing"]]];
            }
            
            NSArray *receivingstats = [athleteDictionary objectForKey:@"football_receivings"];
            football_receiving_stats = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < receivingstats.count; i++) {
                [football_receiving_stats addObject:[[FootballReceivingStat alloc] initWithDictionary:
                                                   [[receivingstats objectAtIndex:i] objectForKey:@"football_receiving"]]];
            }
            
            NSArray *defensestats = [athleteDictionary objectForKey:@"football_defenses"];
            football_defense_stats = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < defensestats.count; i++) {
                [football_defense_stats addObject:[[FootballDefenseStats alloc] initWithDictionary:
                                                     [[defensestats objectAtIndex:i] objectForKey:@"football_defense"]]];
            }
            
            NSArray *placekickerstats = [athleteDictionary objectForKey:@"football_place_kickers"];
            football_place_kicker_stats = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < placekickerstats.count; i++) {
                [football_place_kicker_stats addObject:[[FootballPlaceKickerStats alloc] initWithDictionary:
                                                   [[placekickerstats objectAtIndex:i] objectForKey:@"football_place_kicker"]]];
            }
            
            NSArray *kickerstats = [athleteDictionary objectForKey:@"football_kickers"];
            football_kicker_stats = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < kickerstats.count; i++) {
                [football_kicker_stats addObject:[[FootballKickerStats alloc] initWithDictionary:
                                                        [[kickerstats objectAtIndex:i] objectForKey:@"football_kicker"]]];
            }
            
            NSArray *punterstats = [athleteDictionary objectForKey:@"football_punters"];
            football_punter_stats = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < punterstats.count; i++) {
                [football_punter_stats addObject:[[FootballPunterStats alloc] initWithDictionary:
                                                        [[punterstats objectAtIndex:i] objectForKey:@"football_punter"]]];
            }
            
            NSArray *returnerstats = [athleteDictionary objectForKey:@"football_returners"];
            football_returner_stats = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < returnerstats.count; i++) {
                [football_returner_stats addObject:[[FootballReturnerStats alloc] initWithDictionary:
                                                        [[returnerstats objectAtIndex:i] objectForKey:@"football_returner"]]];
            }
                        
        } else if ([sport.name isEqualToString:@"Basketball"]) {
            NSArray *bballstats = [athleteDictionary objectForKey:@"basketball_stats"];
            basketball_stats = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < [bballstats count]; i++) {
                NSDictionary *entry = [bballstats objectAtIndex:i];
                [basketball_stats addObject:[[BasketballStats alloc] initWithDirectory:[entry objectForKey:@"basketball_stat"] AthleteId:athleteid]];
            }
        } else if ([sport.name isEqualToString:@"Soccer"]) {
            NSArray *soccerstats = [athleteDictionary objectForKey:@"soccers"];
            soccer_stats = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < soccerstats.count; i++) {
                [soccer_stats addObject:[[Soccer alloc] initWithDirectory:[[soccerstats objectAtIndex:i] objectForKey:@"soccer"] AthleteId:athleteid]];
            }
        }
        
        return self;
    } else {
        return nil;
    }
}

- (void)saveAthlete:(Sport *)sport Team:(Team *)team User:(User *)user {
    thesport = sport;
    theuser = user;
    theteam = team;
    
    NSURL *aurl;
    
    if (self.athleteid != nil)
        aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@",
                                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzUrl"], @"/sports/",
                                    sport.id, @"/athletes/", athleteid, @".json?auth_token=", user.authtoken]];
    else
        aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@",
                                     [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzUrl"], @"/sports/",
                                     sport.id, @"/athletes.json?auth_token=", user.authtoken]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:180];
    NSError *jsonSerializationError = nil;

    NSMutableDictionary *athDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[number stringValue], @"number",
                                    lastname, @"lastname", middlename, @"middlename", firstname, @"firstname",
                                    height, @"height", [weight stringValue], @"weight", season, @"season", year, @"year",
                                    position, @"position", team.teamid, @"team_id",
                                    bio, @"bio", nil];
    
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:athDict, @"athlete", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonSerializationError];
    
    if (jsonSerializationError) {
        NSLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    
    if (self.athleteid != nil)
        [request setHTTPMethod:@"PUT"];
    else
        [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:jsonData];
    
    [[NSURLConnection alloc] initWithRequest:request  delegate:self];
}

- (void)deleteAthlete:(Sport *)sport User:(User *)user {
    thesport = sport;
    theuser = user;
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@",
                                       [mainBundle objectForInfoDictionaryKey:@"EazesportzUrl"],  @"/sports/", sport.id,
                                       @"/athletes/", athleteid, @".json?auth_token=", user.authtoken]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSError *error = nil;
    NSDictionary *jsonDict = [[NSDictionary alloc] init];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"DELETE"];
    [request setHTTPBody:jsonData];
    deletePlayer = YES;
    [[NSURLConnection alloc] initWithRequest:request  delegate:self];
    
}

- (id)initDelete {
    self = nil;
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    responseStatusCode = [httpResponse statusCode];
    theData = [[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [theData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Error"
                                     defaultButton:@"OK" alternateButton:nil
                                       otherButton:nil informativeTextWithFormat:@"Error connecting to server"];
    [alert setIcon:[thesport getImage:@"tiny"]];
    [alert runModal];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSDictionary *serverData = [NSJSONSerialization JSONObjectWithData:theData options:0 error:nil];
    if (responseStatusCode == 200) {
        if (deletePlayer) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AthleteDeletedNotification" object:nil
                                                              userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Success", @"Result", nil]];
            [self initDelete];
        } else {
            NSDictionary *items = [serverData objectForKey:@"athlete"];
            self.athleteid = [items objectForKey:@"_id"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AthleteSavedNotification" object:nil
                                                              userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Success", @"Result", nil]];
        }
        
        [[[EazesportzRetrievePlayers alloc] init] retrievePlayers:thesport Team:theteam User:theuser];
    } else {
        if (deletePlayer)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AthleteDeletedNotification" object:nil
                                                          userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Error", @"Result", nil]];
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AthleteSavedNotification" object:nil
                                                              userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Error", @"Result", nil]];
        
        httperror = [serverData objectForKey:@"error"];
    }
}

- (NSString *)numberLogname {
    return [NSString stringWithFormat:@"%@%@%@", [number stringValue], @" - ", logname];
}

- (NSString *)getBasketballStatGameId:(NSString *)basketball_stat_id {
    NSString *gameid = nil;
    
    for (int cnt = 0; cnt < basketball_stats.count; cnt++) {
        if ([[[basketball_stats objectAtIndex:cnt] basketball_stat_id] isEqualToString:basketball_stat_id]) {
            gameid = [[basketball_stats objectAtIndex:cnt] gameschedule_id];
            break;
        }
    }
    return gameid;
}

- (BasketballStats *)findBasketballGameStatEntries:(NSString *)gameid {
    BasketballStats *entry = [[BasketballStats alloc] init];
    for (int i = 0; i < [basketball_stats count]; i++) {
        if ([[[basketball_stats objectAtIndex:i] gameschedule_id] isEqualToString:gameid]) {
            entry = [[basketball_stats objectAtIndex:i] copy];
        }
    }
    
    if (entry.athleteid.length == 0) {
        entry.athleteid = athleteid;
        entry.gameschedule_id = gameid;
    }

    return entry;
}

- (void)updateBasketballGameStats:(BasketballStats *)bballstats {
    int i;
    for (i = 0; i < [basketball_stats count]; i++) {
        if ([[[basketball_stats objectAtIndex:i] gameschedule_id] isEqualToString:bballstats.gameschedule_id]) {
            break;
        }
    }
    
    if (i < basketball_stats.count) {
        [basketball_stats removeObjectAtIndex:i];
    }
    [basketball_stats addObject:bballstats];
}

- (BOOL)saveBasketballGameStats:(Sport *)sport Team:(Team *)team Game:(GameSchedule *)game User:(User *)user {
    return [[self findBasketballGameStatEntries:game.id] saveStats:sport User:user];
    BasketballStats *astats = [self findBasketballGameStatEntries:game.id];
    
    if ([astats saveStats:sport User:user]) {
        [self updateBasketballGameStats:astats];
        return YES;
    } else
        return NO;
}

- (Soccer *)findSoccerStats:(NSString *)statid {
    Soccer *thestat = nil;
    
    for (int cnt = 0; cnt < soccer_stats.count; cnt++) {
        if ([[[soccer_stats objectAtIndex:cnt] soccerid] isEqualToString:statid]) {
            thestat = [soccer_stats objectAtIndex:cnt];
            break;
        }
    }
    return thestat;
}

- (Soccer *)findSoccerGameStats:(NSString *)gameid {
    Soccer *entry = [[Soccer alloc] init];
    for (int i = 0; i < [soccer_stats count]; i++) {
        if ([[[soccer_stats objectAtIndex:i] gameschedule_id] isEqualToString:gameid]) {
            entry = [[soccer_stats objectAtIndex:i] copy];
        }
    }
    
    if (entry.athleteid.length == 0) {
        entry.athleteid = athleteid;
        entry.gameschedule_id = gameid;
    }
    
    return entry;
}

- (void)updateSoccerGameStats:(Soccer *)soccerstat {
    int i;
    for (i = 0; i < [soccer_stats count]; i++) {
        if ([[[soccer_stats objectAtIndex:i] gameschedule_id] isEqualToString:soccerstat.gameschedule_id]) {
            break;
        }
    }
    
    if (i < soccer_stats.count) {
        [soccer_stats removeObjectAtIndex:i];
    }
    [soccer_stats addObject:soccerstat];
}

- (BOOL)saveSoccerGameStats:(Sport *)sport Team:(Team *)team Game:(GameSchedule *)game User:(User *)user {
    Soccer *astats = [self findSoccerGameStats:game.id];
    
    if ([astats saveStats:sport User:user]) {
        [self updateSoccerGameStats:astats];
        return YES;
    } else
        return NO;
}

- (BOOL)isSoccerGoalie {
    BOOL result = NO;
    
    for (int i = 0; i < soccer_stats.count; i++) {
        if ([[soccer_stats objectAtIndex:i] goalieStats]) {
            result = YES;
            break;
        }
    }
    
    if (!result) {
        NSArray *positions = [position componentsSeparatedByString:@"/"];
        for (int i = 0; i < positions.count; i++) {
            if ([[positions objectAtIndex:i] isEqualToString:@"GK"]) {
                result = YES;
                break;
            }
        }
    }
    
    return result;
}

- (Soccer *)soccerSeasonTotals {
    Soccer *thestats = [[Soccer alloc] init];
    int goals = 0, goalsagainst = 0, saves = 0, cornerkicks = 0, steals = 0, assists = 0, shots = 0, minutes = 0, shutouts = 0;
    
    for (int i = 0; i < soccer_stats.count; i++) {
        goals += [[[soccer_stats objectAtIndex:i] goals] intValue];
        goalsagainst += [[[soccer_stats objectAtIndex:i] goalsagainst] intValue];
        saves += [[[soccer_stats objectAtIndex:i] goalssaved] intValue];
        cornerkicks += [[[soccer_stats objectAtIndex:i] cornerkicks] intValue];
        assists += [[[soccer_stats objectAtIndex:i] assists] intValue];
        shots += [[[soccer_stats objectAtIndex:i] shotstaken] intValue];
        minutes += [[[soccer_stats objectAtIndex:i] minutesplayed] intValue];
        steals += [[[soccer_stats objectAtIndex:i] steals] intValue];
        
        if (goalsagainst == 0)
            shutouts += 1;
    }
    
    thestats.goals = [NSNumber numberWithInt:goals];
    thestats.goalsagainst = [NSNumber numberWithInt:goalsagainst];
    thestats.goalssaved = [NSNumber numberWithInt:saves];
    thestats.cornerkicks = [NSNumber numberWithInt:cornerkicks];
    thestats.assists = [NSNumber numberWithInt:assists];
    thestats.shotstaken = [NSNumber numberWithInt:shots];
    thestats.minutesplayed = [NSNumber numberWithInt:minutes];
    thestats.shutouts = [NSNumber numberWithInt:shutouts];
    
    return thestats;
}

- (BasketballStats *)basketballSeasonTotals {
    BasketballStats *thestats = [[BasketballStats alloc] init];
    int fgm = 0, fga = 0, threefgm = 0, threefga = 0, ftm = 0, fta = 0, blocks = 0, steals = 0, assists = 0, orb = 0, drb = 0, fouls = 0;
    
    for (int i = 0; i < basketball_stats.count; i++) {
        fgm += [[[basketball_stats objectAtIndex:i] twomade] intValue];
        fga += [[[basketball_stats objectAtIndex:i] twoattempt] intValue];
        threefgm += [[[basketball_stats objectAtIndex:i] threemade] intValue];
        threefga += [[[basketball_stats objectAtIndex:i] threeattempt] intValue];
        ftm += [[[basketball_stats objectAtIndex:i] ftmade] intValue];
        fta += [[[basketball_stats objectAtIndex:i] ftattempt] intValue];
        blocks += [[[basketball_stats objectAtIndex:i] blocks] intValue];
        steals += [[[basketball_stats objectAtIndex:i] steals] intValue];
        assists += [[[basketball_stats objectAtIndex:i] assists] intValue];
        orb += [[[basketball_stats objectAtIndex:i] offrebound] intValue];
        drb += [[[basketball_stats objectAtIndex:i] defrebound] intValue];
        fouls += [[[basketball_stats objectAtIndex:i] fouls] intValue];
    }
    
    thestats.twoattempt = [NSNumber numberWithInt:fga];
    thestats.twomade = [NSNumber numberWithInt:fgm];
    thestats.threeattempt = [NSNumber numberWithInt:threefga];
    thestats.threemade = [NSNumber numberWithInt:threefgm];
    thestats.ftattempt = [NSNumber numberWithInt:fta];
    thestats.ftmade = [NSNumber numberWithInt:ftm];
    thestats.blocks = [NSNumber numberWithInt:blocks];
    thestats.steals = [NSNumber numberWithInt:steals];
    thestats.assists = [NSNumber numberWithInt:assists];
    thestats.offrebound = [NSNumber numberWithInt:orb];
    thestats.defrebound = [NSNumber numberWithInt:drb];
    thestats.fouls = [NSNumber numberWithInt:fouls];
    
    return thestats;
}

- (NSImage *)getImage:(NSString *)size {
    NSImage *image;
    
    if ([size isEqualToString:@"tiny"] ) {
        
        if ([self.tinypic isEqualToString:@"/pics/tiny/missing.png"]) {
            image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:@"photo_not_available.png"]];
        } else if (self.processing) {
            image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:@"photo_processing.png"]];
        } else if ((tinyimage == nil) || (![imagesize isEqualToString:@"tiny"])) {
            NSURL * imageURL = [NSURL URLWithString:self.tinypic];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            image = [[NSImage alloc] initWithData:imageData];
            self.tinyimage = image;
            imagesize = size;
        } else
            image = self.tinyimage;
        
    } else if ([size isEqualToString:@"thumb"]) {
        
        if ([self.thumb isEqualToString:@"/pics/thumb/missing.png"]) {
            image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:@"photo_not_available.png"]];
        } else if (self.processing) {
            image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:@"photo_processing.png"]];
        } else if ((self.thumbimage) || (![imagesize isEqualToString:@"thumb"])) {
            NSURL * imageURL = [NSURL URLWithString:self.thumb];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            image = [[NSImage alloc] initWithData:imageData];
            self.thumbimage = image;
            imagesize = size;
        } else
            image = self.thumbimage;
        
    } else if ([size isEqualToString:@"medium"]) {
        
        if ([self.mediumpic isEqualToString:@"/pics/medium/missing.png"]) {
            image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:@"photo_not_available.png"]];
        } else if (self.processing) {
            image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:@"photo_processing.png"]];
        } else if ((self.mediumimage) || (![imagesize isEqualToString:@"medium"])) {
            NSURL * imageURL = [NSURL URLWithString:self.mediumpic];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            image = [[NSImage alloc] initWithData:imageData];
            self.mediumimage = image;
            imagesize = size;
        } else
            image = self.mediumimage;
        
    }
    
    return image;
}

- (FootballPassingStat *)findFootballPassingStat:(NSString *)gameid {
    FootballPassingStat *thestat = nil;
    
    for (int cnt = 0; cnt < football_passing_stats.count; cnt++) {
        if ([gameid isEqualToString:[[football_passing_stats objectAtIndex:cnt] gameschedule_id]]) {
            thestat = [football_passing_stats objectAtIndex:cnt];
            break;
        }
    }
    
    if (thestat == nil) {
        thestat = [[FootballPassingStat alloc] init];
        thestat.athlete_id = athleteid;
        thestat.gameschedule_id = gameid;
    }
    
    return  thestat;
}

- (FootballPassingStat *)getFBPassingStat:(NSString *)gameid {
    FootballPassingStat *thestat = nil;
    
    for (int cnt = 0; cnt < football_passing_stats.count; cnt++) {
        if ([gameid isEqualToString:[[football_passing_stats objectAtIndex:cnt] gameschedule_id]]) {
            thestat = [football_passing_stats objectAtIndex:cnt];
            break;
        }
    }
    
    return  thestat;
}

- (FootballPassingStat *)findFootballPassingStatById:(NSString *)stat_id {
    FootballPassingStat *thestat = nil;
    
    for (int cnt = 0; cnt < football_passing_stats.count; cnt++) {
        if ([stat_id isEqualToString:[[football_passing_stats objectAtIndex:cnt] football_passing_id]]) {
            thestat = [football_passing_stats objectAtIndex:cnt];
            break;
        }
    }
    return thestat;
}

- (void)updateFootballPassingGameStats:(FootballPassingStat *)passingstat {
    int i;
    for (i = 0; i < [football_passing_stats count]; i++) {
        if ([[[football_passing_stats objectAtIndex:i] gameschedule_id] isEqualToString:passingstat.gameschedule_id]) {
            break;
        }
    }
    
    if (i < football_passing_stats.count) {
        [football_passing_stats removeObjectAtIndex:i];
    }
    [football_passing_stats addObject:passingstat];
}

- (FootballRushingStat *)findFootballRushingStat:(NSString *)gameid {
    FootballRushingStat *thestat = nil;
    
    for (int cnt = 0; cnt < football_rushing_stats.count; cnt++) {
        if ([gameid isEqualToString:[[football_rushing_stats objectAtIndex:cnt] gameschedule_id]])
            thestat = [football_rushing_stats objectAtIndex:cnt];
    }
    
    if (thestat == nil) {
        thestat = [[FootballRushingStat alloc] init];
        thestat.athlete_id = athleteid;
        thestat.gameschedule_id = gameid;
    }
    
    return  thestat;
}

- (FootballRushingStat *)getFBRushingStat:(NSString *)gameid {
    FootballRushingStat *thestat = nil;
    
    for (int cnt = 0; cnt < football_rushing_stats.count; cnt++) {
        if ([gameid isEqualToString:[[football_rushing_stats objectAtIndex:cnt] gameschedule_id]])
            thestat = [football_rushing_stats objectAtIndex:cnt];
    }
    
    return  thestat;
}

- (FootballRushingStat *)findFootballRushingStatById:(NSString *)stat_id {
    FootballRushingStat *thestat = nil;
    
    for (int cnt = 0; cnt < football_rushing_stats.count; cnt++) {
        if ([stat_id isEqualToString:[[football_rushing_stats objectAtIndex:cnt] football_rushing_id]]) {
            thestat = [football_rushing_stats objectAtIndex:cnt];
            break;
        }
    }
    return thestat;
}

- (void)updateFootballRushingGameStats:(FootballRushingStat *)rushingstat {
    int i;
    for (i = 0; i < [football_rushing_stats count]; i++) {
        if ([[[football_rushing_stats objectAtIndex:i] gameschedule_id] isEqualToString:rushingstat.gameschedule_id]) {
            break;
        }
    }
    
    if (i < football_rushing_stats.count) {
        [football_rushing_stats removeObjectAtIndex:i];
    }
    [football_rushing_stats addObject:rushingstat];
}

- (FootballReceivingStat *)findFootballReceivingStat:(NSString *)gameid {
    FootballReceivingStat *thestat = nil;
    
    for (int cnt = 0; cnt < football_receiving_stats.count; cnt++) {
        if ([gameid isEqualToString:[[football_receiving_stats objectAtIndex:cnt] gameschedule_id]])
            thestat = [football_receiving_stats objectAtIndex:cnt];
    }
    
    if (thestat == nil) {
        thestat = [[FootballReceivingStat alloc] init];
        thestat.athlete_id = athleteid;
        thestat.gameschedule_id = gameid;
    }
    
    return  thestat;
}

- (FootballReceivingStat *)getFBReceiverStat:(NSString *)gameid {
    FootballReceivingStat *thestat = nil;
    
    for (int cnt = 0; cnt < football_receiving_stats.count; cnt++) {
        if ([gameid isEqualToString:[[football_receiving_stats objectAtIndex:cnt] gameschedule_id]])
            thestat = [football_receiving_stats objectAtIndex:cnt];
    }
    return  thestat;
}

- (FootballReceivingStat *)findFootballReceivingStatById:(NSString *)stat_id {
    FootballReceivingStat *thestat = nil;
    
    for (int cnt = 0; cnt < football_receiving_stats.count; cnt++) {
        if ([stat_id isEqualToString:[[football_receiving_stats objectAtIndex:cnt] football_receiving_id]]) {
            thestat = [football_receiving_stats objectAtIndex:cnt];
            break;
        }
    }
    return thestat;
}

- (void)updateFootballReceivingGameStats:(FootballReceivingStat *)receivingstat {
    int i;
    for (i = 0; i < [football_receiving_stats count]; i++) {
        if ([[[football_receiving_stats objectAtIndex:i] gameschedule_id] isEqualToString:receivingstat.gameschedule_id]) {
            break;
        }
    }
    
    if (i < football_receiving_stats.count) {
        [football_receiving_stats removeObjectAtIndex:i];
    }
    [football_receiving_stats addObject:receivingstat];
}

- (FootballDefenseStats *)findFootballDefenseStat:(NSString *)gameid {
    FootballDefenseStats *thestat = nil;
    
    for (int cnt = 0; cnt < football_defense_stats.count; cnt++) {
        if ([gameid isEqualToString:[[football_defense_stats objectAtIndex:cnt] gameschedule_id]])
            thestat = [football_defense_stats objectAtIndex:cnt];
    }
    
    if (thestat == nil) {
        thestat = [[FootballDefenseStats alloc] init];
        thestat.athlete_id = athleteid;
        thestat.gameschedule_id = gameid;
    }
    
    return  thestat;
}

- (FootballDefenseStats *)getFBDefenseStat:(NSString *)gameid {
    FootballDefenseStats *thestat = nil;
    
    for (int cnt = 0; cnt < football_defense_stats.count; cnt++) {
        if ([gameid isEqualToString:[[football_defense_stats objectAtIndex:cnt] gameschedule_id]])
            thestat = [football_defense_stats objectAtIndex:cnt];
    }
    
    return  thestat;
}

- (FootballDefenseStats *)findFootballDefenseStatById:(NSString *)stat_id {
    FootballDefenseStats *thestat = nil;
    
    for (int cnt = 0; cnt < football_defense_stats.count; cnt++) {
        if ([stat_id isEqualToString:[[football_defense_stats objectAtIndex:cnt] football_defense_id]]) {
            thestat = [football_defense_stats objectAtIndex:cnt];
            break;
        }
    }
    return thestat;
}

- (void)updateFootballDefenseGameStats:(FootballDefenseStats *)defensestat {
    int i;
    for (i = 0; i < [football_defense_stats count]; i++) {
        if ([[[football_defense_stats objectAtIndex:i] gameschedule_id] isEqualToString:defensestat.gameschedule_id]) {
            break;
        }
    }
    
    if (i < football_defense_stats.count) {
        [football_defense_stats removeObjectAtIndex:i];
    }
    [football_defense_stats addObject:defensestat];
}

- (FootballKickerStats *)findFootballKickerStat:(NSString *)gameid {
    FootballKickerStats *thestat = nil;
    
    for (int cnt = 0; cnt < football_kicker_stats.count; cnt++) {
        if ([gameid isEqualToString:[[football_kicker_stats objectAtIndex:cnt] gameschedule_id]])
            thestat = [football_kicker_stats objectAtIndex:cnt];
    }
    
    if (thestat == nil) {
        thestat = [[FootballKickerStats alloc] init];
        thestat.athlete_id = athleteid;
        thestat.gameschedule_id = gameid;
    }
    
    return  thestat;
}

- (FootballKickerStats *)getFBKickerStat:(NSString *)gameid {
    FootballKickerStats *thestat = nil;
    
    for (int cnt = 0; cnt < football_kicker_stats.count; cnt++) {
        if ([gameid isEqualToString:[[football_kicker_stats objectAtIndex:cnt] gameschedule_id]])
            thestat = [football_kicker_stats objectAtIndex:cnt];
    }
    
    return  thestat;
}

- (FootballKickerStats *)findFootballKickerStatById:(NSString *)stat_id {
    FootballKickerStats *thestat = nil;
    
    for (int cnt = 0; cnt < football_kicker_stats.count; cnt++) {
        if ([stat_id isEqualToString:[[football_kicker_stats objectAtIndex:cnt] football_kicker_id]]) {
            thestat = [football_kicker_stats objectAtIndex:cnt];
            break;
        }
    }
    return thestat;
}

- (void)updateFootballKickerGameStats:(FootballKickerStats *)kickerstat {
    int i;
    
    for (i = 0; i < [football_kicker_stats count]; i++) {
        if ([[[football_kicker_stats objectAtIndex:i] gameschedule_id] isEqualToString:kickerstat.gameschedule_id]) {
            break;
        }
    }
    
    if (i < football_kicker_stats.count) {
        [football_kicker_stats removeObjectAtIndex:i];
    }
    
    [football_kicker_stats addObject:kickerstat];
}

- (FootballPlaceKickerStats *)findFootballPlaceKickerStat:(NSString *)gameid {
    FootballPlaceKickerStats *thestat = nil;
    
    for (int cnt = 0; cnt < football_place_kicker_stats.count; cnt++) {
        if ([gameid isEqualToString:[[football_place_kicker_stats objectAtIndex:cnt] gameschedule_id]])
            thestat = [football_place_kicker_stats objectAtIndex:cnt];
    }
    
    if (thestat == nil) {
        thestat = [[FootballPlaceKickerStats alloc] init];
        thestat.athlete_id = athleteid;
        thestat.gameschedule_id = gameid;
    }
    
    return  thestat;
}

- (FootballPlaceKickerStats *)getFBPlaceKickerStat:(NSString *)gameid {
    FootballPlaceKickerStats *thestat = nil;
    
    for (int cnt = 0; cnt < football_place_kicker_stats.count; cnt++) {
        if ([gameid isEqualToString:[[football_place_kicker_stats objectAtIndex:cnt] gameschedule_id]])
            thestat = [football_place_kicker_stats objectAtIndex:cnt];
    }
    
    return  thestat;
}

- (FootballPlaceKickerStats *)findFootballPlaceKickerStatById:(NSString *)stat_id {
    FootballPlaceKickerStats *thestat = nil;
    
    for (int cnt = 0; cnt < football_place_kicker_stats.count; cnt++) {
        if ([stat_id isEqualToString:[[football_place_kicker_stats objectAtIndex:cnt] football_place_kicker_id]]) {
            thestat = [football_place_kicker_stats objectAtIndex:cnt];
            break;
        }
    }
    return thestat;
}

- (void)updateFootballPlaceKickerGameStats:(FootballPlaceKickerStats *)placekickerstat {
    int i;
    for (i = 0; i < [football_place_kicker_stats count]; i++) {
        if ([[[football_place_kicker_stats objectAtIndex:i] gameschedule_id] isEqualToString:placekickerstat.gameschedule_id]) {
            break;
        }
    }
    
    if (i < football_place_kicker_stats.count) {
        [football_place_kicker_stats removeObjectAtIndex:i];
    }
    [football_place_kicker_stats addObject:placekickerstat];
}

- (FootballPunterStats *)findFootballPunterStat:(NSString *)gameid {
    FootballPunterStats *thestat = nil;
    
    for (int cnt = 0; cnt < football_punter_stats.count; cnt++) {
        if ([gameid isEqualToString:[[football_punter_stats objectAtIndex:cnt] gameschedule_id]])
            thestat = [football_punter_stats objectAtIndex:cnt];
    }
    
    if (thestat == nil) {
        thestat = [[FootballPunterStats alloc] init];
        thestat.athlete_id = athleteid;
        thestat.gameschedule_id = gameid;
    }
    
    return  thestat;
}

- (FootballPunterStats *)getFBPunterStat:(NSString *)gameid {
    FootballPunterStats *thestat = nil;
    
    for (int cnt = 0; cnt < football_punter_stats.count; cnt++) {
        if ([gameid isEqualToString:[[football_punter_stats objectAtIndex:cnt] gameschedule_id]])
            thestat = [football_punter_stats objectAtIndex:cnt];
    }
    
    return  thestat;
}

- (FootballPunterStats *)findFootballPunterStatById:(NSString *)stat_id {
    FootballPunterStats *thestat = nil;
    
    for (int cnt = 0; cnt < football_punter_stats.count; cnt++) {
        if ([stat_id isEqualToString:[[football_punter_stats objectAtIndex:cnt] football_punter_id]]) {
            thestat = [football_punter_stats objectAtIndex:cnt];
            break;
        }
    }
    return thestat;
}

- (void)updateFootballPunterGameStats:(FootballPunterStats *)punterstat {
    int i;
    for (i = 0; i < [football_punter_stats count]; i++) {
        if ([[[football_punter_stats objectAtIndex:i] gameschedule_id] isEqualToString:punterstat.gameschedule_id]) {
            break;
        }
    }
    
    if (i < football_punter_stats.count) {
        [football_punter_stats removeObjectAtIndex:i];
    }
    [football_punter_stats addObject:punterstat];
}

- (FootballReturnerStats *)findFootballReturnerStat:(NSString *)gameid {
    FootballReturnerStats *thestat = nil;
    
    for (int cnt = 0; cnt < football_returner_stats.count; cnt++) {
        if ([gameid isEqualToString:[[football_returner_stats objectAtIndex:cnt] gameschedule_id]])
            thestat = [football_returner_stats objectAtIndex:cnt];
    }
    
    if (thestat == nil) {
        thestat = [[FootballReturnerStats alloc] init];
        thestat.athlete_id = athleteid;
        thestat.gameschedule_id = gameid;
    }
    
    return  thestat;
}

- (FootballReturnerStats *)getFBReturnerStat:(NSString *)gameid {
    FootballReturnerStats *thestat = nil;
    
    for (int cnt = 0; cnt < football_returner_stats.count; cnt++) {
        if ([gameid isEqualToString:[[football_returner_stats objectAtIndex:cnt] gameschedule_id]])
            thestat = [football_returner_stats objectAtIndex:cnt];
    }
    
    return  thestat;
}

- (FootballReturnerStats *)findFootballReturnerStatById:(NSString *)stat_id {
    FootballReturnerStats *thestat = nil;
    
    for (int cnt = 0; cnt < football_returner_stats.count; cnt++) {
        if ([stat_id isEqualToString:[[football_returner_stats objectAtIndex:cnt] football_returner_id]]) {
            thestat = [football_returner_stats objectAtIndex:cnt];
            break;
        }
    }
    return thestat;
}

- (void)updateFootballReturnerGameStats:(FootballReturnerStats *)returnerstat {
    int i;
    for (i = 0; i < [football_returner_stats count]; i++) {
        if ([[[football_returner_stats objectAtIndex:i] gameschedule_id] isEqualToString:returnerstat.gameschedule_id]) {
            break;
        }
    }
    
    if (i < football_returner_stats.count) {
        [football_returner_stats removeObjectAtIndex:i];
    }
    [football_returner_stats addObject:returnerstat];
}

- (BOOL)isQB:(NSString *)gameid {
    BOOL isaQB = NO;
    
    for (int i = 0; i < football_passing_stats.count; i++) {
        if (([[[football_passing_stats objectAtIndex:i] attempts] intValue] > 0) &&
            ([[[football_passing_stats objectAtIndex:i] gameschedule_id] isEqualToString:gameid])) {
            isaQB = YES;
            break;
        }
    }
    if (!isaQB) {
        NSArray *positions = [position componentsSeparatedByString:@"/"];
        
        for (int i = 0; i < positions.count; i++) {
            if ([[positions objectAtIndex:i] isEqualToString:@"QB"]) {
                isaQB = YES;
                break;
            }
        }
    }
    return isaQB;
}

- (BOOL)isRB:(NSString *)gameid {
    BOOL isaRB = NO;
    
    if (gameid) {
        for (int i = 0; i < football_rushing_stats.count; i++) {
            if (([[[football_rushing_stats objectAtIndex:i] attempts] intValue] > 0) &&
                ([[[football_rushing_stats objectAtIndex:i] gameschedule_id] isEqualToString:gameid])) {
                isaRB = YES;
                break;
            }
        }
    } else {
        NSArray *positions = [position componentsSeparatedByString:@"/"];
        
        for (int i = 0; i < positions.count; i++) {
            if (([[positions objectAtIndex:i] isEqualToString:@"RB"]) || ([[positions objectAtIndex:i] isEqualToString:@"FB"]) ||
                ([[positions objectAtIndex:i] isEqualToString:@"TB"])) {
                isaRB = YES;
                break;
            }
        }
    }
    return isaRB;
}

- (BOOL)isWR:(NSString *)gameid {
    BOOL isaWR = NO;
    
    if (gameid) {
        for (int i = 0; i < football_receiving_stats.count; i++) {
            if (([[[football_receiving_stats objectAtIndex:i] receptions] intValue] > 0) &&
                ([[[football_receiving_stats objectAtIndex:i] gameschedule_id] isEqualToString:gameid])) {
                isaWR = YES;
                break;
            }
        }
    } else {
        NSArray *positions = [position componentsSeparatedByString:@"/"];
        
        for (int i = 0; i < positions.count; i++) {
            if (([[positions objectAtIndex:i] isEqualToString:@"WR"]) || ([[positions objectAtIndex:i] isEqualToString:@"TE"])) {
                isaWR = YES;
                break;
            }
        }
    }
    return isaWR;
}

- (BOOL)isOL:(NSString *)gameid {
    BOOL isaOL = NO;
    
    NSArray *positions = [position componentsSeparatedByString:@"/"];
    
    for (int i = 0; i < positions.count; i++) {
        if (([[positions objectAtIndex:i] isEqualToString:@"OL"]) || ([[positions objectAtIndex:i] isEqualToString:@"C"]) ||
            ([[positions objectAtIndex:i] isEqualToString:@"G"]) || ([[positions objectAtIndex:i] isEqualToString:@"T"])) {
            isaOL = YES;
            break;
        }
    }
    return isaOL;
}

- (BOOL)isDEF:(NSString *)gameid {
    BOOL isaDEF = NO;
    
    if (gameid) {
        for (int i = 0; i < football_defense_stats.count; i++) {
            FootballDefenseStats *stats = [football_defense_stats objectAtIndex:i];
            if ((([[stats tackles] intValue] > 0) || ([stats.assists intValue] > 0) || ([stats.pass_defended intValue] > 0) ||
                 ([stats.interceptions intValue] > 0) || ([stats.sacks intValue] > 0) || ([stats.td intValue] > 0)) &&
                ([[[football_defense_stats objectAtIndex:i] gameschedule_id] isEqualToString:gameid])) {
                isaDEF = YES;
                break;
            }
        }
    } else {
        NSArray *positions = [position componentsSeparatedByString:@"/"];
        
        for (int i = 0; i < positions.count; i++) {
            if (([[positions objectAtIndex:i] isEqualToString:@"DL"]) || ([[positions objectAtIndex:i] isEqualToString:@"NG"]) ||
                ([[positions objectAtIndex:i] isEqualToString:@"DT"]) || ([[positions objectAtIndex:i] isEqualToString:@"DE"]) ||
                ([[positions objectAtIndex:i] isEqualToString:@"LB"]) || ([[positions objectAtIndex:i] isEqualToString:@"DB"]) ||
                ([[positions objectAtIndex:i] isEqualToString:@"CB"]) || ([[positions objectAtIndex:i] isEqualToString:@"S"]) ||
                ([[positions objectAtIndex:i] isEqualToString:@"SS"])) {
                isaDEF = YES;
                break;
            }
        }
    }
    return isaDEF;
}

- (BOOL)isPK:(NSString *)gameid {
    BOOL isaPK = NO;
    
    if (gameid) {
        for (int i = 0; i < football_place_kicker_stats.count; i++) {
            if ((([[[football_place_kicker_stats objectAtIndex:i] xpattempts] intValue] > 0) ||
                 ([[[football_place_kicker_stats objectAtIndex:i] fgattempts] intValue ] > 0)) &&
                ([[[football_place_kicker_stats objectAtIndex:i] gameschedule_id] isEqualToString:gameid])) {
                isaPK = YES;
                break;
            }
        }
    } else {
        NSArray *positions = [position componentsSeparatedByString:@"/"];
        
        for (int i = 0; i < positions.count; i++) {
            if (([[positions objectAtIndex:i] isEqualToString:@"PK"]) || ([[positions objectAtIndex:i] isEqualToString:@"PKP"])) {
                isaPK = YES;
                break;
            }
        }
    }
    return isaPK;
}

- (BOOL)isKicker:(NSString *)gameid {
    BOOL isaKicker = NO;
    
    if (gameid) {
        for (int i = 0; i < football_kicker_stats.count; i++) {
            if (([[[football_kicker_stats objectAtIndex:i] koattempts] intValue] > 0) &&
                ([[[football_kicker_stats objectAtIndex:i] gameschedule_id] isEqualToString:gameid])) {
                isaKicker = YES;
                break;
            }
        }
    } else {
        NSArray *positions = [position componentsSeparatedByString:@"/"];
        
        for (int i = 0; i < positions.count; i++) {
            if (([[positions objectAtIndex:i] isEqualToString:@"K"]) || ([[positions objectAtIndex:i] isEqualToString:@"PKP"])) {
                isaKicker = YES;
                break;
            }
        }
    }
    return isaKicker;
}

- (BOOL)isPunter:(NSString *)gameid {
    BOOL isaPunter = NO;
    
    if (gameid) {
        for (int i = 0; i < football_punter_stats.count; i++) {
            if (([[[football_punter_stats objectAtIndex:i] punts] intValue] > 0) &&
                ([[[football_punter_stats objectAtIndex:i] gameschedule_id] isEqualToString:gameid])) {
                isaPunter = YES;
                break;
            }
        }
    } else {
        NSArray *positions = [position componentsSeparatedByString:@"/"];
        
        for (int i = 0; i < positions.count; i++) {
            if ([[positions objectAtIndex:i] isEqualToString:@"P"]) {
                isaPunter = YES;
                break;
            }
        }
    }
    return isaPunter;
}

- (BOOL)isReturner:(NSString *)gameid {
    BOOL isaReturner = NO;
    
    if (gameid) {
        for (int i = 0; i < football_returner_stats.count; i++) {
            if ((([[[football_returner_stats objectAtIndex:i] koreturn] intValue] > 0) ||
                 ([[[football_returner_stats objectAtIndex:i] punt_return] intValue] > 0)) &&
                ([[[football_returner_stats objectAtIndex:i] gameschedule_id] isEqualToString:gameid])) {
                isaReturner = YES;
                break;
            }
        }
    } else {
        NSArray *positions = [position componentsSeparatedByString:@"/"];
        
        for (int i = 0; i < positions.count; i++) {
            if ([[positions objectAtIndex:i] isEqualToString:@"RET"]) {
                isaReturner = YES;
                break;
            }
        }
    }
    return isaReturner;
}

- (BOOL)saveFootballGameStats:(Sport *)sport Team:(Team *)team Game:(GameSchedule *)game User:(User *)user {
    FootballPassingStat *astats = [self findFootballPassingStat:game.id];
    
    if (astats.football_passing_id.length > 0) {
        if (![astats saveStats:sport User:user]) {
            return NO;
        }
    }
    
    FootballReceivingStat *recstats = [self findFootballReceivingStat:game.id];
    
    if (recstats.football_receiving_id.length > 0) {
        if (![recstats saveStats:sport User:user]) {
            return NO;
        }
    }
    
    FootballRushingStat *rushstats = [self findFootballRushingStat:game.id];
    
    if (rushstats.football_rushing_id.length > 0) {
        if (![rushstats saveStats:sport User:user]) {
            return NO;
        }
    }
        
    return YES;
}

@end
