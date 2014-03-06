//
//  FootballRushingStat.m
//  EazeSportz
//
//  Created by Gil on 11/20/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import "FootballRushingStat.h"
#import "EazesportzAppDelegate.h"

@implementation FootballRushingStat

@synthesize attempts;
@synthesize average;
@synthesize fumbles;
@synthesize fumbles_lost;
@synthesize longest;
@synthesize td;
@synthesize yards;
@synthesize firstdowns;
@synthesize twopointconv;

@synthesize football_rushing_id;
@synthesize athlete_id;
@synthesize gameschedule_id;

@synthesize httperror;

- (id)init {
    if (self = [super init]) {
        attempts = [NSNumber numberWithInt:0];
        average = [NSNumber numberWithInt:0];
        fumbles = [NSNumber numberWithInt:0];
        fumbles_lost = [NSNumber numberWithInt:0];
        longest = [NSNumber numberWithInt:0];
        td = [NSNumber numberWithInt:0];
        yards = [NSNumber numberWithInt:0];
        firstdowns = [NSNumber numberWithInt:0];
        twopointconv = [NSNumber numberWithInt:0];
        
        athlete_id = @"";
        gameschedule_id = @"";
        football_rushing_id = @"";
        
        return self;
    } else
        return nil;
}

- (id)initWithDictionary:(NSDictionary *)rushingDictionary {
    if ((self = [super init]) && (rushingDictionary.count > 0)) {
        attempts = [rushingDictionary objectForKey:@"attempts"];
        average = [rushingDictionary objectForKey:@"average"];
        fumbles_lost = [rushingDictionary objectForKey:@"fumbles_lost"];
        fumbles = [rushingDictionary objectForKey:@"fumbles"];
        longest = [rushingDictionary objectForKey:@"longest"];
        td = [rushingDictionary objectForKey:@"td"];
        yards = [rushingDictionary objectForKey:@"yards"];
        firstdowns = [rushingDictionary objectForKey:@"firstdowns"];
        twopointconv = [rushingDictionary objectForKey:@"twopointconv"];
        
        athlete_id = [rushingDictionary objectForKey:@"athlete_id"];
        gameschedule_id = [rushingDictionary objectForKey:@"gameschedule_id"];
        football_rushing_id = [rushingDictionary objectForKey:@"football_rushing_id" ];

        return self;
    } else
        return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    FootballRushingStat *copy;
    copy.athlete_id = athlete_id;
    copy.gameschedule_id = gameschedule_id;
    copy.football_rushing_id = football_rushing_id;
    
    copy.attempts = attempts;
    copy.average = average;
    copy.fumbles_lost = fumbles_lost;
    copy.fumbles = fumbles;
    copy.longest = longest;
    copy.td = td;
    copy.yards = yards;
    copy.firstdowns = firstdowns;
    copy.twopointconv = twopointconv;
    
    return copy;
}

- (BOOL)saveStats:(Sport *)sport User:(User *)user {
    if (([attempts intValue] > 0) || ([fumbles intValue] > 0) || ([fumbles_lost intValue] > 0) || ([longest intValue] > 0) ||
        ([td intValue] > 0) || ([yards intValue] > 0) || ([firstdowns intValue] > 0) || ([twopointconv intValue] > 0)) {
        NSURL *aurl;
        NSBundle *mainBundle = [NSBundle mainBundle];
        
        if (football_rushing_id.length > 0) {
            aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                         [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"], @"/sports/",
                                         sport.id, @"/athletes/", athlete_id, @"/football_rushings/",
                                         football_rushing_id, @".json?auth_token=", user.authtoken]];
            
        } else {
            aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                         [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"], @"/sports/",
                                         sport.id, @"/athletes/", athlete_id, @"/football_rushings.json?gameschedule_id=",
                                         gameschedule_id, @"&auth_token=", user.authtoken]];
        }
        
        if ([yards intValue] > 0)
            average = [NSNumber numberWithFloat:[yards floatValue]/[attempts floatValue]];
        else
            average = [NSNumber numberWithFloat:0.0];
        
        NSMutableDictionary *statDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: gameschedule_id, @"gameschedule_id",
                                         @"Totals", @"livestats", [attempts stringValue], @"attempts", [average stringValue],
                                         @"average", [fumbles stringValue], @"fumbles", [fumbles_lost stringValue],
                                         @"fumbles_lost", [longest stringValue], @"longest", [td stringValue], @"td",
                                         [yards stringValue], @"yards", [firstdowns stringValue], @"firstdowns",
                                         [twopointconv stringValue], @"twopointconv", nil];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl];
        NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:statDict, @"football_rushing", nil];
        
        NSError *jsonSerializationError = nil;
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        if (football_rushing_id.length > 0) {
            if (([attempts intValue] == 0) && ([yards intValue] == 0) && ([average floatValue] == 0.0) && ([longest intValue] == 0) &&
                ([fumbles intValue] == 0) && ([fumbles_lost intValue] == 0) && ([firstdowns intValue] == 0) && ([twopointconv intValue] == 0) &&
                ([td intValue] == 0))
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
        NSDictionary *items = [serverData objectForKey:@"rushing"];
        
        if ([httpResponse statusCode] == 200) {
            
            if (football_rushing_id.length == 0)
                football_rushing_id = [items objectForKey:@"_id"];
            
            return YES;
        } else {
            httperror = [serverData objectForKey:@"error"];
            return NO;
        }
    } else
        return YES;
}

@end
