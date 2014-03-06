//
//  BasketballStats.m
//  Basketball Console
//
//  Created by Gilbert Zaldivar on 9/19/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import "BasketballStats.h"
#import "EazesportzAppDelegate.h"

@implementation BasketballStats

@synthesize twoattempt;
@synthesize twomade;
@synthesize threeattempt;
@synthesize threemade;
@synthesize ftmade;
@synthesize ftattempt;
@synthesize fouls;
@synthesize assists;
@synthesize steals;
@synthesize blocks;
@synthesize offrebound;
@synthesize defrebound;
@synthesize turnovers;

@synthesize gameschedule_id;
@synthesize basketball_stat_id;
@synthesize athleteid;

@synthesize httperror;

- (id)init {
    if (self = [super init]) {
        self.twoattempt = [NSNumber numberWithInt:0];
        self.twomade = [NSNumber numberWithInt:0];
        self.threeattempt = [NSNumber numberWithInt:0];
        self.threemade = [NSNumber numberWithInt:0];
        self.ftattempt = [NSNumber numberWithInt:0];
        self.ftmade = [NSNumber numberWithInt:0];
        self.fouls = [NSNumber numberWithInt:0];
        self.blocks = [NSNumber numberWithInt:0];
        self.steals = [NSNumber numberWithInt:0];
        self.assists = [NSNumber numberWithInt:0];
        self.defrebound = [NSNumber numberWithInt:0];
        self.offrebound = [NSNumber numberWithInt:0];
        self.turnovers = [NSNumber numberWithInt:0];
        self.gameschedule_id = @"";
        self.basketball_stat_id = @"";
        return self;
    } else
        return nil;
}

- (id)initWithDirectory:(NSDictionary *)basketballStatDirectory AthleteId:(NSString *)playerid {
    if ((self = [super init]) && (basketballStatDirectory.count > 0)) {
        twoattempt = [basketballStatDirectory objectForKey:@"twoattempt"];
        twomade = [basketballStatDirectory objectForKey:@"twomade"];
        threeattempt = [basketballStatDirectory objectForKey:@"threeattempt"];
        threemade = [basketballStatDirectory objectForKey:@"threemade"];
        ftattempt = [basketballStatDirectory objectForKey:@"ftattempt"];
        ftmade = [basketballStatDirectory objectForKey:@"ftmade"];
        fouls = [basketballStatDirectory objectForKey:@"fouls"];
        assists = [basketballStatDirectory objectForKey:@"assists"];
        steals = [basketballStatDirectory objectForKey:@"steals"];
        blocks = [basketballStatDirectory objectForKey:@"blocks"];
        offrebound = [basketballStatDirectory objectForKey:@"offrebound"];
        defrebound = [basketballStatDirectory objectForKey:@"defrebound"];
        turnovers = [basketballStatDirectory objectForKey:@"turnovers"];
        
        basketball_stat_id = [basketballStatDirectory objectForKey:@"basketball_stat_id"];
        gameschedule_id = [basketballStatDirectory objectForKey:@"gameschedule_id"];
        athleteid = playerid;
        return self;
    } else {
        return nil;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    BasketballStats *copy = [[BasketballStats alloc] init];
    copy.twoattempt = twoattempt;
    copy.twomade = twomade;
    copy.threeattempt = threeattempt;
    copy.threemade = threemade;
    copy.ftattempt = ftattempt;
    copy.ftmade = ftmade;
    copy.fouls = fouls;
    copy.blocks = blocks;
    copy.steals = steals;
    copy.assists = assists;
    copy.defrebound = defrebound;
    copy.offrebound = offrebound;
    copy.turnovers = turnovers;
    
    copy.gameschedule_id = gameschedule_id;
    copy.basketball_stat_id = basketball_stat_id;
    copy.athleteid = athleteid;
    return copy;
}

- (BOOL)saveStats:(Sport *)sport User:(User *)user {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *aurl;
    
    if (basketball_stat_id.length == 0)
        aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                     [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                     @"/sports/", sport.id, @"/athletes/", athleteid,
                                     @"/basketball_stats.json?gameschedule_id=",
                                     gameschedule_id, @"&auth_token=", user.authtoken]];
    else {
        aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                                     [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                     @"/sports/", sport.id, @"/athletes/", athleteid, @"/basketball_stats/",
                                     basketball_stat_id, @".json?auth_token=", user.authtoken]];
                
    }
    
    NSMutableDictionary *statDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: gameschedule_id, @"gameschedule_id",
                                     [twoattempt stringValue] , @"twoattempt", [twomade stringValue], @"twomade",
                                     [threeattempt stringValue], @"threeattempt", [threemade stringValue], @"threemade",
                                     [ftattempt stringValue], @"ftattempt", [ftmade stringValue], @"ftmade",
                                     [fouls stringValue], @"fouls", [assists stringValue], @"assists", [steals stringValue],
                                     @"steals", [blocks stringValue], @"blocks", [offrebound stringValue], @"offrebound",
                                     [defrebound stringValue], @"defrebound", [turnovers stringValue], @"turnovers",
                                     @"Totals", @"livestats", nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl];
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:statDict, @"basketball_stat", nil];
    
    NSError *jsonSerializationError = nil;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if (basketball_stat_id.length > 0) {
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
    NSDictionary *items = [serverData objectForKey:@"bbstats"];
    
    if ([httpResponse statusCode] == 200) {
        
        if (basketball_stat_id.length == 0) {
            basketball_stat_id = [items objectForKey:@"_id"];
        }
        return YES;
    } else {
        httperror = [items objectForKey:@"error"];
        return NO;
    }
}

@end
