//
//  FootballDefenseStats.m
//  EazeSportz
//
//  Created by Gil on 11/20/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import "FootballDefenseStats.h"
#import "EazesportzAppDelegate.h"

@implementation FootballDefenseStats

@synthesize tackles;
@synthesize fumbles_recovered;
@synthesize int_long;
@synthesize int_yards;
@synthesize interceptions;
@synthesize pass_defended;
@synthesize sacks;
@synthesize td;
@synthesize assists;
@synthesize safety;
@synthesize sackassist;

@synthesize football_defense_id;
@synthesize athlete_id;
@synthesize gameschedule_id;

@synthesize httperror;

- (id)init {
    if (self = [super init]) {
        tackles = [NSNumber numberWithInt:0];
        fumbles_recovered = [NSNumber numberWithInt:0];
        int_long = [NSNumber numberWithInt:0];
        int_yards = [NSNumber numberWithInt:0];
        interceptions = [NSNumber numberWithInt:0];
        pass_defended = [NSNumber numberWithInt:0];
        sacks = [NSNumber numberWithInt:0];
        td = [NSNumber numberWithInt:0];
        assists = [NSNumber numberWithInt:0];
        safety = [NSNumber numberWithInt:0];
        sackassist = [NSNumber numberWithInt:0];
        
        athlete_id = @"";
        gameschedule_id = @"";
        football_defense_id = @"";
        
        return self;
    } else
        return nil;
}

- (id)initWithDictionary:(NSDictionary *)defenseDirectory {
    if ((self = [super init]) && (defenseDirectory.count > 0)) {
        tackles = [defenseDirectory objectForKey:@"tackles"];
        assists = [defenseDirectory objectForKey:@"assists"];
        interceptions = [defenseDirectory objectForKey:@"interceptions"];
        int_long = [defenseDirectory objectForKey:@"int_long"];
        int_yards = [defenseDirectory objectForKey:@"int_yards"];
        pass_defended = [defenseDirectory objectForKey:@"pass_defended"];
        sacks = [defenseDirectory objectForKey:@"sacks"];
        td = [defenseDirectory objectForKey:@"int_td"];
        safety = [defenseDirectory objectForKey:@"safety"];
        fumbles_recovered = [defenseDirectory objectForKey:@"fumbles_recovered"];
        sackassist = [defenseDirectory objectForKey:@"sackassist"];
        
        athlete_id = [defenseDirectory objectForKey:@"athlete_id"];
        gameschedule_id = [defenseDirectory objectForKey:@"gameschedule_id"];
        football_defense_id = [defenseDirectory objectForKey:@"football_defense_id"];
        
        return self;
    } else
        return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    FootballDefenseStats *copy;
    copy.athlete_id = athlete_id;
    copy.gameschedule_id = gameschedule_id;
    copy.football_defense_id = football_defense_id;
    
    copy.tackles = tackles;
    copy.fumbles_recovered = fumbles_recovered;
    copy.int_long = int_long;
    copy.int_yards = int_yards;
    copy.interceptions = interceptions;
    copy.pass_defended = pass_defended;
    copy.sacks = sacks;
    copy.td = td;
    copy.assists = assists;
    copy.safety = safety;
    copy.sackassist = sackassist;
    
    return copy;
}

- (BOOL)saveStats:(Sport *)sport User:(User *)user {
    if (([tackles intValue] > 0) || ([fumbles_recovered intValue] > 0) || ([int_long intValue] > 0) || ([int_yards intValue] > 0) ||
        ([interceptions intValue] > 0) || ([pass_defended intValue] > 0) || ([sacks intValue] > 0) || ([td intValue] > 0) ||
        ([assists intValue] > 0) || ([safety intValue] > 0) || ([sackassist intValue] > 0)) {
        NSURL *aurl;
        NSBundle *mainBundle = [NSBundle mainBundle];
        
        if (football_defense_id.length > 0) {
            aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                         [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                         @"/sports/", sport.id, @"/athletes/", athlete_id, @"/football_defenses/",
                                         football_defense_id, @".json?auth_token=", user.authtoken]];
            
        } else {
            aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                         [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                         @"/sports/", sport.id, @"/athletes/", athlete_id,
                                         @"/football_defenses.json?gameschedule_id=",
                                         gameschedule_id, @"&auth_token=", user.authtoken]];
        }
        
        NSMutableDictionary *statDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: gameschedule_id, @"gameschedule_id",
                                         @"Totals", @"livestats", [tackles stringValue], @"tackles",
                                         [fumbles_recovered stringValue], @"fumbles_recovered", [int_long stringValue],
                                         @"int_long", [int_yards stringValue], @"int_yards", [interceptions stringValue],
                                         @"interceptions", [pass_defended stringValue], @"pass_defended", [sacks stringValue],
                                         @"sacks", [td stringValue], @"int_td", [assists stringValue], @"assists",
                                         [safety stringValue], @"safety", [sackassist stringValue], @"sackassist", nil];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl];
        NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:statDict, @"football_defense", nil];
        
        NSError *jsonSerializationError = nil;
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        if (football_defense_id.length > 0) {
            if (([tackles intValue] == 0) && ([fumbles_recovered intValue] == 0) && ([int_long intValue] == 0) && ([int_yards intValue] == 0) &&
                ([interceptions intValue] == 0) && ([pass_defended intValue] == 0) && ([sacks intValue] == 0) && ([td intValue] == 0) &&
                ([assists intValue] == 0) && ([safety intValue] == 0) && ([sackassist intValue] == 0))
                [request setHTTPMethod:@"DELETE"];
            else
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
        NSDictionary *items = [serverData objectForKey:@"defense"];
        
        if ([httpResponse statusCode] == 200) {
            
            if (football_defense_id.length == 0)
                football_defense_id = [items objectForKey:@"_id"];
            
            return YES;
        } else {
            httperror = [serverData objectForKey:@"error"];
            return NO;
        }
    } else
        return YES;
}

@end
