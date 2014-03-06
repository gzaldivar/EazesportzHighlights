//
//  FootballReceivingStat.m
//  EazeSportz
//
//  Created by Gil on 11/20/13.
//  Copyright (c) 2013 Gil. All rights reserved.
//

#import "FootballReceivingStat.h"
#import "EazesportzAppDelegate.h"

@implementation FootballReceivingStat

@synthesize average;
@synthesize fumbles;
@synthesize fumbles_lost;
@synthesize longest;
@synthesize receptions;
@synthesize td;
@synthesize yards;
@synthesize twopointconv;
@synthesize firstdowns;

@synthesize football_receiving_id;
@synthesize athlete_id;
@synthesize gameschedule_id;

@synthesize httperror;

- (id)init {
    if (self = [super init]) {
        average = [NSNumber numberWithInt:0];
        fumbles = [NSNumber numberWithInt:0];
        fumbles_lost = [NSNumber numberWithInt:0];
        longest = [NSNumber numberWithInt:0];
        receptions = [NSNumber numberWithInt:0];
        td = [NSNumber numberWithInt:0];
        yards = [NSNumber numberWithInt:0];
        twopointconv = [NSNumber numberWithInt:0];
        firstdowns = [NSNumber numberWithInt:0];
        
        athlete_id = @"";
        gameschedule_id = @"";
        football_receiving_id = @"";
        
        return self;
    } else
        return nil;
}

- (id)initWithDictionary:(NSDictionary *)receivingDictionary {
    if ((self = [super init]) && (receivingDictionary.count > 0)) {
        average = [receivingDictionary objectForKey:@"average"];
        fumbles_lost = [receivingDictionary objectForKey:@"fumbles_lost"];
        fumbles = [receivingDictionary objectForKey:@"fumbles"];
        longest = [receivingDictionary objectForKey:@"longest"];
        receptions = [receivingDictionary objectForKey:@"receptions"];
        td = [receivingDictionary objectForKey:@"td"];
        yards = [receivingDictionary objectForKey:@"yards"];
        twopointconv = [receivingDictionary objectForKey:@"twopointconv"];
        firstdowns = [receivingDictionary objectForKey:@"firstdowns"];
        
        athlete_id = [receivingDictionary objectForKey:@"athlete_id"];
        gameschedule_id = [receivingDictionary objectForKey:@"gameschedule_id"];
        football_receiving_id = [receivingDictionary objectForKey:@"football_receiving_id"];
        
        return self;
    } else
        return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    FootballReceivingStat *copy;
    copy.athlete_id = athlete_id;
    copy.gameschedule_id = gameschedule_id;
    copy.football_receiving_id = football_receiving_id;
    
    copy.average = average;
    copy.fumbles = fumbles;
    copy.fumbles_lost = fumbles_lost;
    copy.longest = longest;
    copy.receptions = receptions;
    copy.td = td;
    copy.yards = yards;
    copy.twopointconv = twopointconv;
    copy.firstdowns = firstdowns;
    
    return copy;
}

- (BOOL)saveStats:(Sport *)sport User:(User *)user {
    NSURL *aurl;
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    if (football_receiving_id.length > 0) {
        aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                     [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                     @"/sports/", sport.id, @"/athletes/", athlete_id, @"/football_receivings/",
                                     football_receiving_id,  @".json?auth_token=", user.authtoken]];
        
    } else {
        aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                     [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                     @"/sports/", sport.id, @"/athletes/", athlete_id,
                                     @"/football_receivings.json?gameschedule_id=",
                                     gameschedule_id, @"&auth_token=", user.authtoken]];
    }
    
    if ([yards intValue] > 0)
        average = [NSNumber numberWithFloat:[yards floatValue]/[receptions floatValue]];
    else
        average = [NSNumber numberWithFloat:0.0];
    
    NSMutableDictionary *statDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: gameschedule_id, @"gameschedule_id", @"Totals", @"livestats",
                                     [average stringValue], @"average", [receptions stringValue], @"receptions",
                                     [fumbles stringValue], @"fumbles", [fumbles_lost stringValue], @"fumbles_lost",
                                     [longest stringValue], @"longest", [td stringValue], @"td", [yards stringValue], @"yards",
                                     [firstdowns stringValue], @"firstdowns", [twopointconv stringValue], @"twopointconv", nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl];
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:statDict, @"football_receiving", nil];
    
    NSError *jsonSerializationError = nil;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if (football_receiving_id.length > 0) {
        if (([receptions intValue] == 0) && ([yards intValue] == 0) && ([average floatValue] == 0.0) && ([longest intValue] == 0) &&
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
    NSDictionary *items = [serverData objectForKey:@"receiving"];
    
    if ([httpResponse statusCode] == 200) {
        
        if (football_receiving_id.length == 0)
            football_receiving_id = [items objectForKey:@"_id"];
        
        return YES;
    } else {
        httperror = [serverData objectForKey:@"error"];
        return NO;
    }
 }

@end
