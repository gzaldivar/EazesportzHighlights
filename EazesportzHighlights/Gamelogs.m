//
//  Gamelogs.m
//  smpwlions
//
//  Created by Gilbert Zaldivar on 3/26/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import "Gamelogs.h"
#import "EazesportzRetrievePlayers.h"

@implementation Gamelogs

@synthesize gamelogid;
@synthesize logentry;
@synthesize logentrytext;
@synthesize period;
@synthesize score;
@synthesize time;
@synthesize hasphotos;
@synthesize hasvideos;
@synthesize player;
@synthesize assistplayer;
@synthesize yards;

@synthesize gameschedule_id;
@synthesize football_defense_id;
@synthesize football_passing_id;
@synthesize football_place_kicker_id;
@synthesize football_returner_id;
@synthesize football_rushing_id;

@synthesize httperror;

- (id)init {
    if (self = [super init]) {
        gamelogid = @"";
        gameschedule_id = @"";
        football_returner_id = @"";
        football_rushing_id = @"";
        football_place_kicker_id = @"";
        football_defense_id = @"";
        football_passing_id = @"";
        
        logentry = @"";
        logentrytext = @"";
        period = @"";
        score = @"";
        time = @"";
        hasphotos = NO;
        hasvideos = NO;
        player = @"";
        assistplayer = @"";
        yards = [NSNumber numberWithInt:0];
        
        return self;
    } else
        return nil;
}

- (id)initWithDictionary:(NSDictionary *)gamelogDictionary {
    if ((self = [super init]) && (gamelogDictionary.count > 0)) {
        gameschedule_id = [gamelogDictionary objectForKey: @"gameschedule_id"];
        gamelogid = [gamelogDictionary objectForKey:@"id"];
        
        football_passing_id = [gamelogDictionary objectForKey:@"football_passing_id"];
        football_defense_id = [gamelogDictionary objectForKey:@"football_defense_id"];
        football_place_kicker_id = [gamelogDictionary objectForKey:@"football_place_kicker_id"];
        football_returner_id = [gamelogDictionary objectForKey:@"football_returner_id"];
        football_rushing_id = [gamelogDictionary objectForKey:@"football_rushing_id"];
        
        logentry = [gamelogDictionary objectForKey:@"logentry"];
        logentrytext = [gamelogDictionary objectForKey:@"logentrytext"];
        period = [gamelogDictionary objectForKey:@"period"];
        time = [gamelogDictionary objectForKey:@"time"];
        score = [gamelogDictionary objectForKey:@"score"];
        hasvideos = [[gamelogDictionary objectForKey:@"hasvideos"] boolValue];
        hasphotos = [[gamelogDictionary objectForKey:@"hasphotos"] boolValue];
        player = [gamelogDictionary objectForKey:@"player"];
        assistplayer = [gamelogDictionary objectForKey:@"assist"];
        yards = [gamelogDictionary objectForKey:@"yards"];
        
        return  self;
    } else
        return nil;
}

- (id)initDeleteGameLog:(Sport *)sport Team:(Team *)team User:(User *)user {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@",
                                       [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                       @"/sports/", sport.id, @"/teams/", team.teamid, @"/gameschedules/",
                                       gameschedule_id, @"/gamelogs/", gamelogid, @".json?auth_token=", user.authtoken]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSURLResponse* response;
    NSError *error = nil;
    NSDictionary *jsonDict = [[NSDictionary alloc] init];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"DELETE"];
    [request setHTTPBody:jsonData];
    NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    int responseStatusCode = (int)[(NSHTTPURLResponse*)response statusCode];
    NSDictionary *gamelogdata = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
    
    if (responseStatusCode == 200) {
        [[[EazesportzRetrievePlayers alloc] init] retrievePlayers:sport Team:team User:user];
        return nil;
    } else {
        httperror = [gamelogdata objectForKey:@"error"];
        return self;
    }
}

- (BOOL)saveGamelog:(Sport *)sport Team:(Team *)team User:(User *)user {
    NSURL *aurl;
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    if (gamelogid.length == 0) {
        aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                     [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                     @"/sports/", sport.id, @"/teams/", team.teamid, @"/gameschedules/", gameschedule_id,
                                     @"/gamelogs.json?auth_token=", user.authtoken]];
        
        NSMutableDictionary *statDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: gameschedule_id,
                                         @"gameschedule_id", logentry, @"logentry",
                                         period, @"period", time, @"time", score, @"score", player, @"player",
                                         assistplayer, @"assist", [yards stringValue], @"yards", nil];
        
        if (football_rushing_id.length > 0) {
            [statDict setValue:football_rushing_id forKey:@"football_rushing_id"];
        }
        
        if (football_passing_id.length > 0) {
            [statDict setValue:football_passing_id forKey:@"football_passing_id"];
        }
        
        if (football_returner_id.length > 0) {
            [statDict setValue:football_returner_id forKey:@"football_returner_id"];
        }
        
        if (football_defense_id.length > 0) {
            [statDict setValue:football_defense_id forKey:@"football_defense_id"];
        }
        
        if (football_place_kicker_id.length > 0) {
            [statDict setValue:football_place_kicker_id forKey:@"football_place_kicker_id"];
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl];
        NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:statDict, @"gamelog", nil];
        
        NSError *jsonSerializationError = nil;
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        if (gamelogid.length > 0) {
            [request setHTTPMethod:@"PUT"];
        } else {
            [request setHTTPMethod:@"POST"];
        }
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonSerializationError];
        
        if (!jsonSerializationError) {
            NSString *serJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"Serialized JSON: %@", serJson);
        } else {
            NSLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
        }
        
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:jsonData];
        
        //Capturing server response
        NSURLResponse* response;
        NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&jsonSerializationError];
        NSMutableDictionary *serverData = [NSJSONSerialization JSONObjectWithData:result options:0 error:&jsonSerializationError];
        NSLog(@"%@", serverData);
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        
        if ([httpResponse statusCode] == 200) {
            logentrytext = [serverData objectForKey:@"logentrytext"];
            
            if (gamelogid.length == 0)
                gamelogid = [serverData objectForKey:@"id"];
            
            return YES;
        } else {
            httperror = [serverData objectForKey:@"error"];
            return NO;
        }
    } else {
        return YES;
    }
}

@end
