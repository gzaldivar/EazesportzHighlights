//
//  Soccer.m
//  EazeSportz
//
//  Created by Gil on 11/4/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import "Soccer.h"
#import "EazesportzAppDelegate.h"

@implementation Soccer

@synthesize soccerid;
@synthesize gameschedule_id;
@synthesize goals;
@synthesize shotstaken;
@synthesize assists;
@synthesize steals;
@synthesize goalsagainst;
@synthesize goalssaved;
@synthesize shutouts;
@synthesize minutesplayed;
@synthesize cornerkicks;

@synthesize athleteid;

@synthesize httperror;

- (id)init {
    if (self = [super init]) {
        soccerid = @"";
        gameschedule_id = @"";
        athleteid = @"";
        goals = [NSNumber numberWithInt:0];
        shotstaken = [NSNumber numberWithInt:0];
        assists = [NSNumber numberWithInt:0];
        steals = [NSNumber numberWithInt:0];
        goalsagainst = [NSNumber numberWithInt:0];
        goalssaved = [NSNumber numberWithInt:0];
        shutouts = [NSNumber numberWithInt:0];
        minutesplayed = [NSNumber numberWithInt:0];
        cornerkicks = [NSNumber numberWithInt:0];
        return self;
    } else
        return nil;
}

- (id)initWithDirectory:(NSDictionary *)soccerDirectory AthleteId:(NSString *)playerid {
    if ((self = [super init]) && (soccerDirectory.count > 0)) {
        soccerid = [soccerDirectory objectForKey:@"soccerid"];
        gameschedule_id = [soccerDirectory objectForKey:@"gameschedule_id"];
        goals = [soccerDirectory objectForKey:@"goals"];
        shotstaken = [soccerDirectory objectForKey:@"shotstaken"];
        assists = [soccerDirectory objectForKey:@"assists"];
        steals = [soccerDirectory objectForKey:@"steals"];
        goalsagainst = [soccerDirectory objectForKey:@"goalsagainst"];
        goalssaved = [soccerDirectory objectForKey:@"goalssaved"];
        shutouts = [soccerDirectory objectForKey:@"shutouts"];
        minutesplayed = [soccerDirectory objectForKey:@"minutesplayed"];
        cornerkicks = [soccerDirectory objectForKey:@"cornerkick"];
        
        athleteid = playerid;
        
        return self;
    } else {
        return nil;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    Soccer *copy = [[Soccer allocWithZone: zone] init];
    copy.assists = assists;
    copy.steals = steals;
    copy.goalssaved = goalssaved;
    copy.goalsagainst = goalsagainst;
    copy.goals = goals;
    copy.shotstaken = shotstaken;
    copy.soccerid = soccerid;
    copy.gameschedule_id = gameschedule_id;
    copy.minutesplayed = minutesplayed;
    copy.shutouts = shutouts;
    copy.athleteid = athleteid;
    copy.cornerkicks = cornerkicks;
    return copy;
}

- (BOOL)goalieStats {
    if (([goalssaved intValue] > 0) || ([goalsagainst intValue] > 0) || ([shutouts intValue] > 0))
        return YES;
    else
        return NO;
}

- (BOOL)saveStats:(Sport *)sport User:(User *)user {
    NSURL *aurl;
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    if (soccerid.length > 0) {
        aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                     [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"], @"/sports/", sport.id,
                                     @"/athletes/", athleteid, @"/soccers/", soccerid, @".json?auth_token=",  user.authtoken]];

    } else {
        aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                     [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"], @"/sports/", sport.id,
                                     @"/athletes/", athleteid, @"/soccers.json?gameschedule_id=",
                                     gameschedule_id, @"&auth_token=", user.authtoken]];
    }
    
    NSMutableDictionary *statDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: gameschedule_id, @"gameschedule_id", @"Totals", @"livestats",
                                     [goals stringValue], @"goals", [shotstaken stringValue], @"shotstaken", [assists stringValue], @"assists",
                                     [steals stringValue], @"steals", [goalsagainst stringValue], @"goalsagainst", [goalssaved stringValue], @"goalssaved",
                                     [minutesplayed stringValue], @"minutesplayed", [shutouts stringValue], @"shutouts",
                                     [cornerkicks stringValue], @"cornerkick", nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl];
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:statDict, @"soccer", nil];
    
    NSError *jsonSerializationError = nil;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if (soccerid.length > 0) {
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
    NSDictionary *items = [serverData objectForKey:@"soccerstats"];
    
    if ([httpResponse statusCode] == 200) {
        
        if (soccerid.length == 0)
            soccerid = [items objectForKey:@"_id"];
        
        return YES;
    } else {
        httperror = [serverData objectForKey:@"error"];
        return NO;
    }

}

@end
