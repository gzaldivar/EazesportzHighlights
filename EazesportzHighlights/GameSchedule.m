//
//  GameSchedule.m
//  smpwlions
//
//  Created by Gil on 3/15/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import "GameSchedule.h"
#import "Gamelogs.h"
#import "EazesportzRetrieveGames.h"
#import "Event.h"

@implementation GameSchedule {
    NSImage *opponentImage;
    
    long responseStatusCode;
    NSMutableData *theData;
    
    NSURLRequest *originalRequest;
    BOOL deletegame;
    Sport *thesport;
    User *theuser;
}

@synthesize id;
@synthesize team_id;
@synthesize startdate;
@synthesize starttime;
@synthesize location;
@synthesize homeaway;
@synthesize event;
@synthesize opponent;
@synthesize leaguegame;
@synthesize opponent_name;
@synthesize opponent_mascot;
@synthesize opponentpic;
@synthesize eazesportzOpponent;
@synthesize gameisfinal;
@synthesize lastplay;
@synthesize homescore;
@synthesize opponentscore;

@synthesize game_name;

@synthesize homeq1;
@synthesize homeq2;
@synthesize homeq3;
@synthesize homeq4;
@synthesize opponentq1;
@synthesize opponentq2;
@synthesize opponentq3;
@synthesize opponentq4;
@synthesize penalty;
@synthesize firstdowns;
@synthesize penaltyyards;
@synthesize possession;
@synthesize ballon;
@synthesize own;
@synthesize currentgametime;
@synthesize our;
@synthesize down;
@synthesize currentqtr;

@synthesize gamedatetime;

@synthesize togo;

@synthesize hometimeouts;
@synthesize opponenttimeouts;

@synthesize homefouls;
@synthesize visitorfouls;
@synthesize homebonus;
@synthesize visitorbonus;
@synthesize period;

@synthesize gamelogs;
@synthesize liveevent;

@synthesize socceroppck;
@synthesize socceroppsaves;
@synthesize socceroppsog;

@synthesize httperror;

- (id)init {
    if (self = [super init]) {
        team_id = @"";
        startdate = @"";
        starttime = @"";
        location = @"";
        homeaway = @"";
        event = @"";
        opponent = @"";
        leaguegame = YES;
        opponent_name = @"";
        opponent_mascot = @"";
        opponentImage = nil;
        eazesportzOpponent = NO;
        gameisfinal = NO;
        lastplay = @"";
        homescore = [NSNumber numberWithInt:0];
        opponentscore = [NSNumber numberWithInt:0];
        game_name = @"";
        homeq1 = [NSNumber numberWithInt:0];
        homeq2 = [NSNumber numberWithInt:0];
        homeq3 = [NSNumber numberWithInt:0];
        homeq4 = [NSNumber numberWithInt:0];
        opponentq1 = [NSNumber numberWithInt:0];
        opponentq2 = [NSNumber numberWithInt:0];
        opponentq3 = [NSNumber numberWithInt:0];
        opponentq4 = [NSNumber numberWithInt:0];
        penalty = [NSNumber numberWithInt:0];
        firstdowns = [NSNumber numberWithInt:0];
        penaltyyards = [NSNumber numberWithInt:0];
        possession = @"";
        ballon = [NSNumber numberWithInt:0];
        own = [NSNumber numberWithInt:0];
        currentgametime = @"00:00";
        our = @"";
        down = [NSNumber numberWithInt:0];
        currentqtr = @"";
        togo = [NSNumber numberWithInt:0];
        homefouls = [NSNumber numberWithInt:0];
        visitorfouls = [NSNumber numberWithInt:0];
        homebonus = NO;
        visitorbonus = NO;
        period = [NSNumber numberWithInt:1];
        socceroppck = [NSNumber numberWithInt:0];
        socceroppsaves = [NSNumber numberWithInt:0];
        socceroppsog = [NSNumber numberWithInt:0];

        return self;
    } else
        return nil;
}

- (id)initWithDictionary:(NSDictionary *)gameScheduleDictionary Sport:(Sport *)sport {
    if ((self = [super init]) && (gameScheduleDictionary.count > 0)) {
        //    gamelogs = [[NSMutableArray alloc] init];
        self.id = [gameScheduleDictionary objectForKey:@"id"];
        team_id = [gameScheduleDictionary objectForKey:@"team_id"];
        opponent = [gameScheduleDictionary objectForKey:@"opponent"];
        leaguegame = [[gameScheduleDictionary objectForKey:@"league"] boolValue];
        opponent_name = [gameScheduleDictionary objectForKey:@"opponent_name"];
        opponent_mascot = [gameScheduleDictionary objectForKey:@"opponent_mascot"];
        opponentpic = [gameScheduleDictionary objectForKey:@"opponentpic"];
        eazesportzOpponent = [[gameScheduleDictionary objectForKey:@"eazesportzOpponent"] boolValue];
        location = [gameScheduleDictionary objectForKey:@"location"];
        starttime = [gameScheduleDictionary objectForKey:@"starttime"];
        startdate = [gameScheduleDictionary objectForKey:@"gamedate"];
        homeaway = [gameScheduleDictionary objectForKey:@"homeaway"];
        event = [gameScheduleDictionary objectForKey:@"event"];
        game_name = [gameScheduleDictionary objectForKey:@"game_name"];
        homeq1 = [gameScheduleDictionary objectForKey:@"homeq1"];
        homeq2 = [gameScheduleDictionary objectForKey:@"homeq2"];
        homeq3 = [gameScheduleDictionary objectForKey:@"homeq3"];
        homeq4 = [gameScheduleDictionary objectForKey:@"homeq4"];
        opponentq1 = [gameScheduleDictionary objectForKey:@"opponentq1"];
        opponentq2 = [gameScheduleDictionary objectForKey:@"opponentq2"];
        opponentq3 = [gameScheduleDictionary objectForKey:@"opponentq3"];
        opponentq4 = [gameScheduleDictionary objectForKey:@"opponentq4"];
        penaltyyards = [gameScheduleDictionary objectForKey:@"penaltyyards"];
        firstdowns = [gameScheduleDictionary objectForKey:@"firstdowns"];
        penalty = [gameScheduleDictionary objectForKey:@"penalty"];
        down = [gameScheduleDictionary objectForKey:@"down"];
        lastplay = [gameScheduleDictionary objectForKey:@"lastplay"];
        currentgametime = [gameScheduleDictionary objectForKey:@"current_game_time"];
        ballon = [gameScheduleDictionary objectForKey:@"ballon"];
        our = [gameScheduleDictionary objectForKey:@"our"];
        possession = [gameScheduleDictionary objectForKey:@"possession"];
        currentqtr = [gameScheduleDictionary objectForKey:@"currentqtr"];
        gameisfinal = [[gameScheduleDictionary objectForKey:@"final"] boolValue];
        togo = [gameScheduleDictionary objectForKey:@"togo"];
        homescore = [gameScheduleDictionary objectForKey:@"homescore"];
        opponentscore = [gameScheduleDictionary objectForKey:@"opponentscore"];
        hometimeouts = [gameScheduleDictionary objectForKey:@"hometimeouts"];
        opponenttimeouts = [gameScheduleDictionary objectForKey:@"opponenttimeouts"];
        homebonus = [[gameScheduleDictionary objectForKey:@"homebonus"] boolValue];
        homefouls = [gameScheduleDictionary objectForKey:@"homefouls"];
        visitorbonus = [[gameScheduleDictionary objectForKey:@"visitorbonus"] boolValue];
        visitorfouls = [gameScheduleDictionary objectForKey:@"opponentfouls"];
        period = [gameScheduleDictionary objectForKey:@"currentperiod"];
        liveevent = [[gameScheduleDictionary objectForKey:@"liveevent"] boolValue];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss+00:00"];
        gamedatetime = [dateFormatter dateFromString:[gameScheduleDictionary objectForKey:@"gamedatetime"]];
        
        socceroppsog = [gameScheduleDictionary objectForKey:@"socceroppsog"];
        socceroppsaves = [gameScheduleDictionary objectForKey:@"socceroppsaves"];
        socceroppck = [gameScheduleDictionary objectForKey:@"socceroppck"];
        
        if ([sport.name isEqualToString:@"Football"]) {
            NSMutableArray *logs = [gameScheduleDictionary objectForKey:@"gamelogs"];
            gamelogs = [[NSMutableArray alloc] init];
            
             for (int cnt = 0; cnt < logs.count; cnt++) {
                 [gamelogs addObject:[[Gamelogs alloc] initWithDictionary:[[logs objectAtIndex:cnt] objectForKey:@"gamelog"]]];
             }
            [self sortGamelog];
        }
        
        return self;
    } else {
        return nil;
    }
}

- (void)sortGamelog {
    NSString *quarter = @"period";
    NSString *timeentry = @"time";
    
    NSSortDescriptor *lastDescriptor = [[NSSortDescriptor alloc] initWithKey:quarter ascending:YES
                                        selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:timeentry ascending:YES
                                        selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSArray *descriptors = [NSArray arrayWithObjects:lastDescriptor, firstDescriptor, nil];
    [gamelogs sortUsingDescriptors:descriptors];
}

- (Gamelogs *)findGamelog:(NSString *)gamelogid {
    Gamelogs *gamelog = nil;
    
    for (int i = 0; i < gamelogs.count; i++) {
        if ([[[gamelogs objectAtIndex:i] gamelogid] isEqualToString:gamelogid]) {
            gamelog = [gamelogs objectAtIndex:i];
            break;
        }
        
    }
    
    return gamelog;
}

- (void)updateGamelog:(Gamelogs *)gamelog {
    int i;
    for (i = 0; i < [gamelogs count]; i++) {
        if ([[[gamelogs objectAtIndex:i] gamelogid] isEqualToString:gamelog.gamelogid]) {
            break;
        }
    }
    
    if (i < gamelogs.count) {
        [gamelogs removeObjectAtIndex:i];
    }
    [gamelogs addObject:gamelog];
}

- (void)saveGameschedule:(Sport *)sport User:(User *)user {
    thesport = sport;
    theuser = user;
    
    httperror = @"";
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *serverUrlString = [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"];
    NSURL *url;
    
    if (self.id) {
        url = [NSURL URLWithString:[serverUrlString stringByAppendingFormat:@"%@%@%@%@%@%@%@%@", @"/sports/",
                                    sport.id, @"/teams/", team_id, @"/gameschedules/", self.id, @".json?auth_token=",
                                    user.authtoken]];
    } else {
        url = [NSURL URLWithString:[serverUrlString stringByAppendingFormat:@"%@%@%@%@%@%@", @"/sports/", sport.id,
                                    @"/teams/", team_id, @"/gameschedules.json?auth_token=", user.authtoken]];
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSArray *time = [starttime componentsSeparatedByString:@":"];
    
    NSMutableDictionary *gamedict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:opponent, @"opponent",
                                     opponent_mascot, @"opponent_mascot", location, @"location",
                                     event, @"event", startdate, @"gamedate",
                                     [time objectAtIndex:0], @"starttime(4i)", [time objectAtIndex:1], @"starttime(5i)",
                                     homeaway, @"homeaway", [homescore stringValue], @"homescore",
                                     [opponentscore stringValue], @"opponentscore", [[NSNumber numberWithBool:leaguegame] stringValue], @"league",
                                     [[NSNumber numberWithBool:gameisfinal] stringValue], @"final", nil];
    
    NSArray *timearray = [currentgametime componentsSeparatedByString:@":"];
    
    [gamedict setValue:timearray[0] forKey:@"livegametime(4i)"];
    [gamedict setValue:timearray[0] forKey:@"gameminutes"];
    [gamedict setValue:timearray[1] forKey:@"livegametime(5i)"];
    [gamedict setValue:timearray[1] forKey:@"gameseconds"];
    
    [gamedict setValue:[period stringValue] forKey:@"currentperiod"];
    [gamedict setValue:currentgametime forKey:@"current_game_time"];

    if ([sport.name isEqualToString:@"Soccer"]) {
        [gamedict setValue:[socceroppsog stringValue] forKey:@"socceroppsog"];
        [gamedict setValue:[socceroppsaves stringValue] forKey:@"socceroppsaves"];
        [gamedict setValue:[socceroppck stringValue] forKey:@"socceroppck"];
    } else if ([sport.name isEqualToString:@"Basketball"]) {
        [gamedict setValue:[visitorfouls stringValue] forKey:@"opponentfouls"];
        [gamedict setValue:[opponentscore stringValue] forKey:@"opponentscore"];
        [gamedict setValue:[[NSNumber numberWithBool:visitorbonus] stringValue] forKey:@"visitorbonus"];
        [gamedict setValue:[[NSNumber numberWithBool:homebonus] stringValue] forKey:@"homebonus"];
        [gamedict setValue:possession forKey:@"bballpossessionarrow"];
        [gamedict setValue:[[NSNumber numberWithBool:homebonus] stringValue] forKey:@"homebonus"];
        [gamedict setValue:[[NSNumber numberWithBool:visitorbonus] stringValue] forKey:@"visitorbonus"];
    } else if ([sport.name isEqualToString:@"Football"]) {
        [gamedict setValue:[ballon stringValue] forKey:@"ballon"];
        [gamedict setValue:[togo stringValue] forKey:@"togo"];
        [gamedict setValue:[down stringValue] forKey:@"down"];
        [gamedict setValue:[opponentscore stringValue] forKey:@"opponentscore"];
        [gamedict setValue:[opponentq1 stringValue] forKey:@"opponentq1"];
        [gamedict setValue:[opponentq2 stringValue] forKey:@"opponentq2"];
        [gamedict setValue:[opponentq3 stringValue] forKey:@"opponentq3"];
        [gamedict setValue:[opponentq4 stringValue] forKey:@"opponentq4"];
        [gamedict setValue:[homeq1 stringValue] forKey:@"homeq1"];
        [gamedict setValue:[homeq2 stringValue] forKey:@"homeq2"];
        [gamedict setValue:[homeq3 stringValue] forKey:@"homeq3"];
        [gamedict setValue:[homeq4 stringValue] forKey:@"homeq4"];
        [gamedict setValue:[opponenttimeouts stringValue] forKey:@"opponenttimeouts"];
        [gamedict setValue:[hometimeouts stringValue] forKey:@"hometimeouts"];
        [gamedict setValue:[penaltyyards stringValue] forKey:@"penaltyyards"];
        [gamedict setValue:[penalty stringValue] forKey:@"penalty"];
        
        Team *team = [[Team alloc] init];
        team.teamid = team_id;
        
        for (int i = 0; i < gamelogs.count; i++)
            [[gamelogs objectAtIndex:i] saveGamelog:sport Team:team User:user];
        
        [self sortGamelog];
    }
    
    NSMutableDictionary *jsonDict =  [[NSMutableDictionary alloc] init];
    [jsonDict setValue:gamedict forKey:@"gameschedule"];
    NSError *jsonSerializationError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonSerializationError];
    
    if (!jsonSerializationError) {
        NSString *serJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Serialized JSON: %@", serJson);
    } else {
        NSLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    
    if (!self.id) {
        [request setHTTPMethod:@"POST"];
    } else {
        [request setHTTPMethod:@"PUT"];
    }
    
    [request setHTTPBody:jsonData];
    
    originalRequest = request;
    [[NSURLConnection alloc] initWithRequest:request  delegate:self];
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
    [alert runModal];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *jsonSerializationError = nil;
    NSMutableDictionary *serverData = [NSJSONSerialization JSONObjectWithData:theData options:0 error:&jsonSerializationError];
    
    if (responseStatusCode == 200) {
                
        [[[EazesportzRetrieveGames alloc] init] retrieveGames:thesport Team:team_id Token:theuser.authtoken];
        
        if (deletegame) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GameDeletedNotification" object:nil
                                                              userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Success", @"Result", nil]];
            [self initDelete];
        } else {
        
            if (self.id.length == 0)
                self.id = [[serverData objectForKey:@"schedule"] objectForKey:@"_id"];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"GameSavedNotification" object:nil];
        }
    } else {
        httperror = [serverData objectForKey:@"error"];
    }
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    if (redirectResponse) {
        NSMutableURLRequest *newrequest = [originalRequest mutableCopy];
        [newrequest setURL:[request URL]];
        return  newrequest;
    } else {
        NSMutableURLRequest *newRequest = [originalRequest mutableCopy];
        
//        [newRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", @"http://powerful-everglades-2345.herokuapp.com",
//                                                 @"/sports/", currentSettings.sport.id, @"/teams/",
//                                                 currentSettings.team.teamid, @"/gameschedules/", self.id, @".json?auth_token=", currentSettings.user.authtoken]]];
        return request;
    }
    
}

- (void)deleteGame:(Sport *)sport Team:(Team *)team User:(User *)user {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                       [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                       @"/sports/", sport.id, @"/teams/", team.teamid, @"/gameschedules/", self.id,
                                        @".json?auth_token=", user.authtoken]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSMutableDictionary *jsonDict =  [[NSMutableDictionary alloc] init];
    NSError *jsonSerializationError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonSerializationError];
    
    if (!jsonSerializationError) {
        NSString *serJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Serialized JSON: %@", serJson);
    } else {
        NSLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"DELETE"];
    [request setHTTPBody:jsonData];

    deletegame = YES;
    originalRequest = request;
    [[NSURLConnection alloc] initWithRequest:request  delegate:self];
}

- (id)initDelete {
    self = nil;
    return self;
}

- (NSImage *)opponentImage {
    NSImage *image;
    
    if (opponentImage) {
        return opponentImage;
    } else {
        if (([opponentpic isEqualToString:@"/opponentpics/original/missing.png"]) || ([opponentpic isEqualToString:@"/opponentpics/tiny/missing.png"])) {
            image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:@"photo_not_available.png"]];
        } else {
            NSURL * imageURL = [NSURL URLWithString:opponentpic];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            image = [[NSImage alloc] initWithData:imageData];
        }
        
        opponentImage = image;
        return image;
    }
}
/*
- (int)soccerHomeCK {
    int cornerKicks = 0;
    
    for (int i = 0; i < currentSettings.roster.count; i++) {
        cornerKicks += [[[[currentSettings.roster objectAtIndex:i] findSoccerGameStats:self.id] cornerkicks] intValue];
    }
    
    return  cornerKicks;
}

- (int)soccerHomeShots {
    int shots = 0;
    
    for (int i = 0; i < currentSettings.roster.count; i++) {
        shots += [[[[currentSettings.roster objectAtIndex:i] findSoccerGameStats:self.id] shotstaken] intValue];
    }
    
    return  shots;
}

- (int)soccerHomeSaves {
    int saves = 0;
    
    for (int i = 0; i < currentSettings.roster.count; i++) {
        saves += [[[[currentSettings.roster objectAtIndex:i] findSoccerGameStats:self.id] goalssaved] intValue];
    }
    
    return  saves;
}

- (int)homeBasketballFouls {
    int fouls = 0;
    
    for (int i = 0; i < currentSettings.roster.count; i++) {
        fouls += [[[[currentSettings.roster objectAtIndex:i] findBasketballGameStatEntries:self.id] fouls] intValue];
    }
    
    return fouls;
}
*/
- (NSString *)vsOpponent {
    return [NSString stringWithFormat:@"%@%@", @"vs. ", opponent_mascot];
}

@end
