//
//  FootballPunterStats.m
//  EazeSportz
//
//  Created by Gil on 11/20/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import "FootballPunterStats.h"
#import "EazesportzAppDelegate.h"

@implementation FootballPunterStats

@synthesize punts;
@synthesize punts_blocked;
@synthesize punts_long;
@synthesize punts_yards;

@synthesize football_punter_id;
@synthesize gameschedule_id;
@synthesize athlete_id;

@synthesize httperror;

- (id)init {
    if (self = [super init]) {
        punts = [NSNumber numberWithInt:0];
        punts_blocked = [NSNumber numberWithInt:0];
        punts_long = [NSNumber numberWithInt:0];
        punts_yards = [NSNumber numberWithInt:0];
        
        athlete_id = @"";
        gameschedule_id = @"";
        football_punter_id = @"";
        
        return self;
    } else
        return nil;
}

- (id)initWithDictionary:(NSDictionary *)punterDictionary {
    if ((self = [super init]) && (punterDictionary.count > 0)) {
        punts = [punterDictionary objectForKey:@"punts"];
        punts_blocked = [punterDictionary objectForKey:@"punts_blocked"];
        punts_long = [punterDictionary objectForKey:@"punts_long"];
        punts_yards = [punterDictionary objectForKey:@"punts_yards"];
        
        athlete_id = [punterDictionary objectForKey:@"athlete_id"];
        gameschedule_id = [punterDictionary objectForKey:@"gameschedule_id"];
        football_punter_id = [punterDictionary objectForKey:@"football_punter_id"];
        
        return self;
    } else
        return  nil;
}

- (id)copyWithZone:(NSZone *)zone {
    FootballPunterStats *copy;
    copy.athlete_id = athlete_id;
    copy.gameschedule_id = gameschedule_id;
    copy.football_punter_id = football_punter_id;
    
    copy.punts = punts;
    copy.punts_blocked = punts_blocked;
    copy.punts_long = punts_long;
    copy.punts_yards = punts_yards;
    
    return copy;
}

- (BOOL)saveStats:(Sport *)sport User:(User *)user {
    if (([punts_yards intValue] > 0) || ([punts intValue] > 0) || ([punts_long intValue] > 0) || ([punts_blocked intValue] > 0)) {
        NSURL *aurl;
        NSBundle *mainBundle = [NSBundle mainBundle];
        
        if (football_punter_id.length > 0) {
            aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                         [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                         @"/sports/", sport.id, @"/athletes/", athlete_id,
                                         @"/football_punters/", football_punter_id,
                                         @".json?auth_token=", user.authtoken]];
            
        } else {
            aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                         [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                         @"/sports/", sport.id, @"/athletes/", athlete_id,
                                         @"/football_punters.json?gameschedule_id=",
                                         gameschedule_id, @"&auth_token=", user.authtoken]];
        }
        
        NSMutableDictionary *statDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: gameschedule_id, @"gameschedule_id", @"Totals", @"livestats",
                                         [punts_yards stringValue], @"punts_yards", [punts_blocked stringValue], @"punts_blocked",
                                         [punts_long stringValue], @"punts_long", [punts_yards stringValue], @"punts_yards", nil];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl];
        NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:statDict, @"football_punter", nil];
        
        NSError *jsonSerializationError = nil;
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        if (football_punter_id.length > 0) {
            if (([punts intValue] == 0) && ([punts_blocked intValue] == 0) && ([punts_long intValue] == 0) && ([punts_yards intValue] == 0))
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
        NSDictionary *items = [serverData objectForKey:@"punter"];
        
        if ([httpResponse statusCode] == 200) {
            
            if (football_punter_id.length == 0)
                football_punter_id = [items objectForKey:@"_id"];
            
            return YES;
        } else {
            httperror = [serverData objectForKey:@"error"];
            return NO;
        }
    } else
        return YES;
}

@end
