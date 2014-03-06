//
//  FootballPassingStat.m
//  EazeSportz
//
//  Created by Gil on 11/20/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import "FootballPassingStat.h"
#import "EazesportzAppDelegate.h"

@implementation FootballPassingStat

@synthesize attempts;
@synthesize completions;
@synthesize comp_percentage;
@synthesize interceptions;
@synthesize sacks;
@synthesize td;
@synthesize yards;
@synthesize yards_lost;
@synthesize firstdowns;
@synthesize twopointconv;

@synthesize football_passing_id;
@synthesize athlete_id;
@synthesize gameschedule_id;

@synthesize httperror;

- (id)init {
    if (self = [super init]) {
        attempts = [NSNumber numberWithInt:0];
        completions = [NSNumber numberWithInt:0];
        comp_percentage = [NSNumber numberWithInt:0];
        interceptions = [NSNumber numberWithInt:0];
        sacks = [NSNumber numberWithInt:0];
        td = [NSNumber numberWithInt:0];
        yards = [NSNumber numberWithInt:0];
        yards_lost = [NSNumber numberWithInt:0];
        firstdowns = [NSNumber numberWithInt:0];
        twopointconv = [NSNumber numberWithInt:0];
        
        football_passing_id = @"";
        athlete_id = @"";
        gameschedule_id = @"";
        return self;
    } else
        return nil;
}

- (id)initWithDictionary:(NSDictionary *)passingDictionary {
    if ((self = [super init]) && (passingDictionary.count > 0)) {
        attempts = [passingDictionary objectForKey:@"attempts"];
        completions = [passingDictionary objectForKey:@"completions"];
        comp_percentage = [passingDictionary objectForKey:@"comp_percentage"];
        interceptions = [passingDictionary objectForKey:@"interceptions"];
        sacks = [passingDictionary objectForKey:@"sacks"];
        td = [passingDictionary objectForKey:@"td"];
        yards = [passingDictionary objectForKey:@"yards"];
        yards_lost = [passingDictionary objectForKey:@"yards_lost"];
        firstdowns = [passingDictionary objectForKey:@"firstdowns"];
        twopointconv = [passingDictionary objectForKey:@"twopointconv"];
        
        athlete_id = [passingDictionary objectForKey:@"athlete_id"];
        gameschedule_id = [passingDictionary objectForKey:@"gameschedule_id"];
        football_passing_id = [passingDictionary objectForKey:@"football_passing_id"];
        
        return self;
    } else
        return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    FootballPassingStat *copy;
    copy.athlete_id = athlete_id;
    copy.gameschedule_id = gameschedule_id;
    copy.football_passing_id = football_passing_id;
    
    copy.attempts = attempts;
    copy.completions = completions;
    copy.comp_percentage = comp_percentage;
    copy.interceptions = interceptions;
    copy.sacks = sacks;
    copy.yards_lost = yards_lost;
    copy.yards = yards;
    copy.firstdowns = firstdowns;
    copy.twopointconv = twopointconv;
    copy.td = td;
    
    return copy;
}

- (BOOL)saveStats:(Sport *)sport User:(User *)user {
    if (([attempts intValue] > 0) || ([completions intValue] > 0) || ([interceptions intValue] > 0) || ([sacks intValue] > 0) ||
        ([yards_lost intValue] > 0) || ([yards intValue] > 0) || ([firstdowns intValue] > 0) || ([twopointconv intValue] > 0) || ([td intValue] > 0)) {
        NSURL *aurl;
        NSBundle *mainBundle = [NSBundle mainBundle];
        
        if (football_passing_id.length > 0) {
            aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                         [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                         @"/sports/", sport.id, @"/athletes/", athlete_id, @"/football_passings/",
                                         football_passing_id, @".json?auth_token=", user.authtoken]];
            
        } else {
            aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                         [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"], @"/sports/",
                                         sport.id, @"/athletes/", athlete_id, @"/football_passings.json?gameschedule_id=",
                                         gameschedule_id, @"&auth_token=", user.authtoken]];
        }
        
        if ([yards intValue] > 0)
            comp_percentage = [NSNumber numberWithFloat:[yards floatValue]/[completions floatValue]];
        else
            comp_percentage = [NSNumber numberWithFloat:0.0];
        
        NSMutableDictionary *statDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: gameschedule_id, @"gameschedule_id", @"Totals", @"livestats",
                                         [attempts stringValue], @"attempts", [completions stringValue], @"completions",
                                         [comp_percentage stringValue], @"comp_percentage", [interceptions stringValue], @"interceptions",
                                         [sacks stringValue], @"sacks", [td stringValue], @"td", [yards stringValue], @"yards",
                                         [yards_lost stringValue], @"yards_lost", [firstdowns stringValue], @"firstdowns",
                                         [twopointconv stringValue], @"twopointconv", nil];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl];
        NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:statDict, @"football_passing", nil];
        
        NSError *jsonSerializationError = nil;
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        if (football_passing_id.length > 0) {
            if (([attempts intValue] == 0) && ([completions intValue] == 0) && ([comp_percentage floatValue] == 0.0) && ([interceptions intValue] == 0) &&
                ([sacks intValue] == 0) && ([td intValue] == 0) && ([yards intValue] == 0) && ([yards_lost intValue] == 0) &&
                ([firstdowns intValue] == 0) && ([twopointconv intValue] == 0))
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
        
        [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:jsonData];
        
        //Capturing server response
        NSURLResponse* response;
        NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&jsonSerializationError];
        NSMutableDictionary *serverData = [NSJSONSerialization JSONObjectWithData:result options:0 error:&jsonSerializationError];
        NSLog(@"%@", serverData);
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSDictionary *items = [serverData objectForKey:@"passing"];
        
        if ([httpResponse statusCode] == 200) {
            
            if (football_passing_id.length == 0)
                football_passing_id = [items objectForKey:@"_id"];
            
            return YES;
        } else {
            httperror = [serverData objectForKey:@"error"];
            return NO;
        }
    } else
        return YES;
}

@end
