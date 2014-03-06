//
//  FootballReturnerStats.m
//  EazeSportz
//
//  Created by Gil on 11/20/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import "FootballReturnerStats.h"
#import "EazesportzAppDelegate.h"

@implementation FootballReturnerStats

@synthesize punt_return;
@synthesize punt_returnlong;
@synthesize punt_returntd;
@synthesize punt_returnyards;

@synthesize kolong;
@synthesize koreturn;
@synthesize kotd;
@synthesize koyards;

@synthesize football_returner_id;
@synthesize gameschedule_id;
@synthesize athlete_id;

@synthesize httperror;

- (id)init {
    if (self = [super init]) {
        punt_return = [NSNumber numberWithInt:0];
        punt_returnlong = [NSNumber numberWithInt:0];
        punt_returntd = [NSNumber numberWithInt:0];
        punt_returnyards = [NSNumber numberWithInt:0];
        
        kolong = [NSNumber numberWithInt:0];
        koreturn = [NSNumber numberWithInt:0];
        kotd = [NSNumber numberWithInt:0];
        koyards = [NSNumber numberWithInt:0];
        
        athlete_id = @"";
        gameschedule_id = @"";
        football_returner_id = @"";
        
        return self;
    } else
        return nil;
}

- (id)initWithDictionary:(NSDictionary *)returnerDictionary {
    if ((self = [super init]) && (returnerDictionary.count > 0)) {
        punt_return = [returnerDictionary objectForKey:@"punt_return"];
        punt_returnlong = [returnerDictionary objectForKey:@"punt_returnlong"];
        punt_returntd = [returnerDictionary objectForKey:@"punt_returntd"];
        punt_returnyards = [returnerDictionary objectForKey:@"punt_returnyards"];
        
        kolong = [returnerDictionary objectForKey:@"kolong"];
        koreturn = [returnerDictionary objectForKey:@"koreturn"];
        kotd = [returnerDictionary objectForKey:@"kotd"];
        koyards = [returnerDictionary objectForKey:@"koyards"];
        
        athlete_id = [returnerDictionary objectForKey:@"athlete_id"];
        gameschedule_id = [returnerDictionary objectForKey:@"gameschedule_id"];
        football_returner_id = [returnerDictionary objectForKey:@"football_returner_id"];
        
        return self;
    } else
        return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    FootballReturnerStats *copy;
    copy.athlete_id = athlete_id;
    copy.gameschedule_id = gameschedule_id;
    copy.football_returner_id = football_returner_id;
    
    copy.punt_return = punt_return;
    copy.punt_returnlong = punt_returnlong;
    copy.punt_returntd = punt_returntd;
    copy.punt_returnyards = punt_returnyards;
    
    copy.kolong = kolong;
    copy.koreturn = koreturn;
    copy.kotd = kotd;
    copy.koyards = koyards;
    
    return copy;
}

- (BOOL)saveStats:(Sport *)sport User:(User *)user {
    if (([punt_return intValue] > 0) || ([punt_returnlong intValue] > 0) || ([punt_returntd intValue] > 0) || ([punt_returnyards intValue] > 0) ||
        ([kolong intValue] > 0) || ([koreturn intValue] > 0) || ([kotd intValue] > 0) || ([koyards intValue] > 0)) {
        NSURL *aurl;
        NSBundle *mainBundle = [NSBundle mainBundle];
        
        if (football_returner_id.length > 0) {
            aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                         [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"], @"/sports/", sport.id,
                                         @"/athletes/", athlete_id,@"/football_returners/", football_returner_id,
                                         @".json?auth_token=", user.authtoken]];
            
        } else {
            aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                         [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"], @"/sports/", sport.id,
                                         @"/athletes/", athlete_id, @"/football_returners.json?gameschedule_id=",
                                         gameschedule_id, @"&auth_token=", user.authtoken]];
        }
        
        NSMutableDictionary *statDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: gameschedule_id, @"gameschedule_id",
                                         @"Totals", @"livestats", [punt_return stringValue], @"punt_return",
                                         [punt_returnlong stringValue], @"punt_returnlong", [punt_returntd stringValue],
                                         @"punt_returntd", [punt_returnyards stringValue], @"punt_returnyards",
                                         [kolong stringValue], @"kolong", [koreturn stringValue], @"koreturn",
                                         [kotd stringValue], @"kotd", [koyards stringValue], @"koyards", nil];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl];
        NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:statDict, @"football_returner", nil];
        
        NSError *jsonSerializationError = nil;
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        if (football_returner_id.length > 0) {
            if (([punt_return intValue] == 0) && ([punt_returnlong intValue] == 0) && ([punt_returntd intValue] == 0) &&
                ([punt_returnyards intValue] == 0) && ([kolong intValue] == 0) && ([koreturn intValue] == 0) && ([kotd intValue] == 0) &&
                ([koyards intValue] == 0))
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
        NSDictionary *items = [serverData objectForKey:@"returner"];
        
        if ([httpResponse statusCode] == 200) {
            
            if (football_returner_id.length == 0)
                football_returner_id = [items objectForKey:@"_id"];
            
            return YES;
        } else {
            httperror = [serverData objectForKey:@"error"];
            return NO;
        }
    } else
        return YES;
}

@end
