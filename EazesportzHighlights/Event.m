//
//  Event.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/26/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "Event.h"
#import "eazesportzGetGame.h"

@implementation Event {
    GameSchedule *eventgame;
}

@synthesize event_id;
@synthesize startdate;
@synthesize enddate;
@synthesize videoevent;
@synthesize eventdesc;
@synthesize eventname;
@synthesize eventurl;
@synthesize user_id;
@synthesize gameschedule_id;
@synthesize sport_id;
@synthesize team_id;

@synthesize httperror;

- (id)init {
    if (self = [super init]) {
        event_id = @"";
        startdate = nil;
        enddate = nil;
        videoevent = [NSNumber numberWithInt:0];
        eventdesc = @"";
        eventname = @"";
        eventurl = @"";
        user_id = @"";
        gameschedule_id = @"";
        sport_id = @"";
        team_id = @"";
        
        return self;
    } else
        return nil;
}

- (id)initWithDictionary:(NSDictionary *)eventDictionary Sport:(Sport *)sport {
    if ([eventDictionary objectForKey:@"id"])
        event_id = [eventDictionary objectForKey:@"id"];
    else
        event_id = [eventDictionary objectForKey:@"_id"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss+00:00"];
    startdate = [dateFormatter dateFromString:[eventDictionary objectForKey:@"start_time"]];
    enddate = [dateFormatter dateFromString:[eventDictionary objectForKey:@"end_time"]];
    
    videoevent = [eventDictionary objectForKey:@"videoevent"];
    eventdesc = [eventDictionary objectForKey:@"desc"];
    eventname = [eventDictionary objectForKey:@"name"];
    eventurl = [eventDictionary objectForKey:@"eventurl"];
    user_id = [eventDictionary objectForKey:@"user_id"];
    sport_id = [eventDictionary objectForKey:@"sport_id"];
    team_id = [eventDictionary objectForKey:@"team_id"];
    gameschedule_id = [eventDictionary objectForKey:@"gameschedule_id"];
    
    if (self = [super init]) {
        return self;
    } else
        return  nil;
}

- (BOOL)saveEvent:(Sport *)sport Team:(Team *)team Game:(GameSchedule *)game User:(User *)user {
    NSString *stringurl;
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    if (event_id.length > 0) {
        stringurl = [NSString stringWithFormat:@"%@%@%@%@%@%@%@", [mainBundle objectForInfoDictionaryKey:@"EazesportzUrl"], @"/sports/", sport.id,
                                     @"/events/", event_id, @".json?auth_token=",  user.authtoken];
        
    } else {
        stringurl = [NSString stringWithFormat:@"%@%@%@%@%@", [mainBundle objectForInfoDictionaryKey:@"EazesportzUrl"], @"/sports/", sport.id,
                                     @"/events.json?auth_token=", user.authtoken];
    }
    
    NSURL *url = [NSURL URLWithString:stringurl];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss+00:00"];

    NSMutableDictionary *statDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: eventname, @"name", eventdesc, @"desc",
                                     [dateFormatter stringFromDate:startdate], @"start_time", [dateFormatter stringFromDate:enddate], @"end_time",
                                     [videoevent stringValue], @"videoevent", eventurl, @"eventurl", user.userid, @"user_id", nil];
    
    if (team) {
        [statDict setValue:team.teamid forKey:@"team_id"];
    }
    
    if (game) {
        [statDict setValue:game.id forKey:@"gameschedule_id"];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:statDict, @"event", nil];
    
    NSError *jsonSerializationError = nil;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if (event_id.length > 0) {
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
        NSDictionary *items = [serverData objectForKey:@"event"];
        [self initWithDictionary:items Sport:sport];
        
        return YES;
    } else {
        httperror = [serverData objectForKey:@"error"];
        return NO;
    }
}

- (BOOL)deleteEvent:(User *)user {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@",
                                       [mainBundle objectForInfoDictionaryKey:@"EazesportzUrl"],  @"/sports/", sport_id,
                                       @"/events/", event_id, @".json?auth_token=", user.authtoken]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSError *error = nil;
    NSDictionary *jsonDict = [[NSDictionary alloc] init];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"DELETE"];
    [request setHTTPBody:jsonData];
    //Capturing server response
    NSURLResponse* response;
    NSError *jsonSerializationError = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&jsonSerializationError];
    NSMutableDictionary *serverData = [NSJSONSerialization JSONObjectWithData:result options:0 error:&jsonSerializationError];
    NSLog(@"%@", serverData);
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSDictionary *items = [serverData objectForKey:@"event"];
    
    if ([httpResponse statusCode] == 200) {
        return YES;
    } else {
        httperror = [serverData objectForKey:@"error"];
        return NO;
    }
}

- (GameSchedule *)getGame:(Sport *)sport Team:(Team *)team User:(User *)user {
    if (!eventgame)
        eventgame = [[[eazesportzGetGame alloc] init] getGameSynchronous:sport Team:team Game:self.gameschedule_id User:user];
    
    return eventgame;
}

@end
