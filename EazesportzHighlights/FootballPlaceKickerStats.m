//
//  FootballPlaceKickerStats.m
//  EazeSportz
//
//  Created by Gil on 11/20/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import "FootballPlaceKickerStats.h"
#import "EazesportzAppDelegate.h"

@implementation FootballPlaceKickerStats

@synthesize fgattempts;
@synthesize fgblocked;
@synthesize fglong;
@synthesize fgmade;
@synthesize xpattempts;
@synthesize xpblocked;
@synthesize xpmade;
@synthesize xpmissed;

@synthesize football_place_kicker_id;
@synthesize athlete_id;
@synthesize gameschedule_id;

@synthesize httperror;

- (id)init {
    if (self = [super init]) {
        fgattempts = [NSNumber numberWithInt:0];
        fgblocked = [NSNumber numberWithInt:0];
        fglong = [NSNumber numberWithInt:0];
        fgmade = [NSNumber numberWithInt:0];

        xpattempts = [NSNumber numberWithInt:0];
        xpblocked = [NSNumber numberWithInt:0];
        xpmade = [NSNumber numberWithInt:0];
        xpmissed = [NSNumber numberWithInt:0];
        
        athlete_id = @"";
        gameschedule_id = @"";
        football_place_kicker_id = @"";

        return self;
    } else
        return nil;
}

- (id)initWithDictionary:(NSDictionary *)placekickerDictionary {
    if ((self = [super init]) && (placekickerDictionary.count > 0)) {
        fgattempts = [placekickerDictionary objectForKey:@"fgattempts"];
        fgblocked = [placekickerDictionary objectForKey:@"fgblocked"];
        fglong = [placekickerDictionary objectForKey:@"fglong"];
        fgmade = [placekickerDictionary objectForKey:@"fgmade"];
        
        xpmissed = [placekickerDictionary objectForKey:@"xpmissed"];
        xpmade = [placekickerDictionary objectForKey:@"xpmade"];
        xpattempts = [placekickerDictionary objectForKey:@"xpattempts"];
        xpblocked = [placekickerDictionary objectForKey:@"xpblocked"];
        
        athlete_id = [placekickerDictionary objectForKey:@"athlete_id"];
        gameschedule_id = [placekickerDictionary objectForKey:@"gameschedule_id"];
        football_place_kicker_id = [placekickerDictionary objectForKey:@"football_place_kicker_id"];
        
        return self;
    } else
        return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    FootballPlaceKickerStats *copy;
    copy.athlete_id = athlete_id;
    copy.gameschedule_id = gameschedule_id;
    copy.football_place_kicker_id = football_place_kicker_id;
    
    copy.fgattempts = fgattempts;
    copy.fgblocked = fgblocked;
    copy.fglong = fglong;
    copy.fgmade = fgmade;
    
    copy.xpmade = xpmade;
    copy.xpmissed = xpmissed;
    copy.xpattempts = xpattempts;
    copy.xpblocked = xpblocked;
    return copy;
}

- (BOOL)saveStats:(Sport *)sport User:(User *)user {
    if (([fgattempts intValue] > 0) || ([fgblocked intValue] > 0) || ([fglong intValue] > 0) || ([fgmade intValue] > 0) ||
        ([xpmade intValue] > 0) || ([xpmissed intValue] > 0) || ([xpattempts intValue] > 0) || ([xpblocked intValue] > 0)) {
        NSURL *aurl;
        NSBundle *mainBundle = [NSBundle mainBundle];
        
        if (football_place_kicker_id.length > 0) {
            aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                         [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                         @"/sports/", sport.id, @"/athletes/", athlete_id, @"/football_place_kickers/",
                                         football_place_kicker_id, @".json?auth_token=", user.authtoken]];
            
        } else {
            aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                         [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                         @"/sports/", sport.id, @"/athletes/", athlete_id,
                                         @"/football_place_kickers.json?gameschedule_id=",
                                         gameschedule_id, @"&auth_token=", user.authtoken]];
        }
        
        NSMutableDictionary *statDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: gameschedule_id, @"gameschedule_id",
                                         @"Totals", @"livestats", [fgattempts stringValue], @"fgattempts",
                                         [fgblocked stringValue], @"fgblocked", [fglong stringValue], @"fglong",
                                         [fgmade stringValue], @"fgmade", [xpmissed stringValue], @"xpmissed",
                                         [xpmade stringValue], @"xpmade", [xpattempts stringValue], @"xpattempts",
                                         [xpblocked stringValue], @"xpblocked", nil];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl];
        NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:statDict, @"football_place_kicker", nil];
        
        NSError *jsonSerializationError = nil;
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        if (football_place_kicker_id.length > 0) {
            if (([fgattempts intValue] == 0) && ([fgblocked intValue] == 0) && ([fglong intValue] == 0) && ([fgmade intValue] == 0) &&
                ([xpmissed intValue] == 0) && ([xpmade intValue] == 0) && ([xpattempts intValue] == 0) && ([xpblocked intValue] == 0))
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
        NSDictionary *items = [serverData objectForKey:@"placekicker"];
        
        if ([httpResponse statusCode] == 200) {
            
            if (football_place_kicker_id.length == 0)
                football_place_kicker_id = [items objectForKey:@"_id"];
            
            return YES;
        } else {
            httperror = [serverData objectForKey:@"error"];
            return NO;
        }
    } else
        return YES;
}

@end
