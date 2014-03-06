//
//  FootballKickerStats.m
//  EazeSportz
//
//  Created by Gil on 11/20/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import "FootballKickerStats.h"
#import "EazesportzAppDelegate.h"

@implementation FootballKickerStats

@synthesize koattempts;
@synthesize koreturned;
@synthesize kotouchbacks;

@synthesize football_kicker_id;
@synthesize gameschedule_id;
@synthesize athlete_id;

@synthesize httperror;

- (id)init {
    if (self = [super init]) {
        koattempts = [NSNumber numberWithInt:0];
        koreturned = [NSNumber numberWithInt:0];
        kotouchbacks = [NSNumber numberWithInt:0];
        
        athlete_id = @"";
        gameschedule_id = @"";
        football_kicker_id = @"";
        
        return self;
    } else
        return nil;
}

- (id)initWithDictionary:(NSDictionary *)kickerDictionary {
    if ((self = [super init]) && (kickerDictionary.count > 0)) {
        koattempts = [kickerDictionary objectForKey:@"koattempts"];
        koreturned = [kickerDictionary objectForKey:@"koreturned"];
        kotouchbacks = [kickerDictionary objectForKey:@"kotouchbacks"];
        
        athlete_id = [kickerDictionary objectForKey:@"athlete_id"];
        gameschedule_id = [kickerDictionary objectForKey:@"gameschedule_id"];
        football_kicker_id = [kickerDictionary objectForKey:@"football_kicker_id"];
        
        return self;
    } else
        return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    FootballKickerStats *copy;
    copy.athlete_id = athlete_id;
    copy.gameschedule_id = gameschedule_id;
    copy.football_kicker_id = football_kicker_id;
    
    copy.koattempts = koattempts;
    copy.koreturned = koreturned;
    copy.kotouchbacks = kotouchbacks;
    
    return  copy;
}

- (BOOL)saveStats:(Sport *)sport User:(User *)user {
    if (([koattempts intValue] > 0) || ([koreturned intValue] > 0) || ([kotouchbacks intValue] > 0)) {
        NSURL *aurl;
        NSBundle *mainBundle = [NSBundle mainBundle];
        
        if (football_kicker_id.length > 0) {
            aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                         [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                         @"/sports/", sport.id, @"/athletes/", athlete_id, @"/football_kickers/",
                                         football_kicker_id, @".json?auth_token=", user.authtoken]];
            
        } else {
            aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                         [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                         @"/sports/", sport.id, @"/athletes/", athlete_id,
                                         @"/football_kickers.json?gameschedule_id=",
                                         gameschedule_id, @"&auth_token=", user.authtoken]];
        }
        
        NSMutableDictionary *statDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: gameschedule_id, @"gameschedule_id",
                                         @"Totals", @"livestats", [koattempts stringValue], @"koattempts",
                                         [koreturned stringValue], @"koreturned", [kotouchbacks stringValue], @"kotouchbacks",
                                         nil];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl];
        NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:statDict, @"football_kicker", nil];
        
        NSError *jsonSerializationError = nil;
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        if (football_kicker_id.length > 0) {
            if (([koattempts intValue] == 0) && ([koreturned intValue] == 0) && ([kotouchbacks intValue] == 0))
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
        NSDictionary *items = [serverData objectForKey:@"kicker"];
        
        if ([httpResponse statusCode] == 200) {
            
            if (football_kicker_id.length == 0)
                football_kicker_id = [items objectForKey:@"_id"];
            
            return YES;
        } else {
            httperror = [serverData objectForKey:@"error"];
            return NO;
        }
    } else
        return YES;
}

@end
