//
//  Sport.m
//  sportzSoftwareHome
//
//  Created by Gil on 2/6/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import "Sport.h"

@implementation Sport {
    NSString *logosize;
}

@synthesize id;
@synthesize sitename;
@synthesize mascot;
@synthesize year;
@synthesize zip;
@synthesize state;
@synthesize country;
@synthesize city;
@synthesize banner;
@synthesize season;
@synthesize name;
@synthesize sport_logo_thumb;
@synthesize sport_logo_tiny;
@synthesize siteid;
@synthesize has_stats;
@synthesize alert_interval;
@synthesize gamelog_interval;
@synthesize newsfeed_interval;
@synthesize beta;
@synthesize approved;

@synthesize package;
@synthesize silverMedia;
@synthesize goldMedia;
@synthesize platinumMedia;

@synthesize streamingurl;
@synthesize streamingbucket;
@synthesize streamquality;
@synthesize allstreams;

@synthesize teamcount;

@synthesize playerPositions;

@synthesize footballDefensePositions;
@synthesize footballOffensePositions;
@synthesize footballSpecialTeamsPositions;

@synthesize sportimage;

- (id)init {
    if (self = [super init]) {
        playerPositions = [[NSMutableDictionary alloc] init];
        footballSpecialTeamsPositions = [[NSMutableDictionary alloc] init];
        footballOffensePositions = [[NSMutableDictionary alloc] init];
        footballDefensePositions = [[NSMutableDictionary alloc] init];
        logosize = @"";
        return self;
    } else
        return nil;
}

- (id)initWithDictionary:(NSDictionary *)sportDictionary {
    if ((self = [super init]) && (sportDictionary.count > 0)) {
        playerPositions = [[NSMutableDictionary alloc] init];
        
        if ([sportDictionary objectForKey:@"id"])
            self.id = [sportDictionary objectForKey:@"id"];
        else if ([sportDictionary objectForKey:@"_id"])
            self.id = [sportDictionary objectForKey:@"_id"];
        
        sitename = [sportDictionary objectForKey:@"sitename"];
        mascot = [sportDictionary objectForKey:@"mascot"];
        year = [sportDictionary objectForKey:@"year"];
        zip = [sportDictionary objectForKey:@"zip"];
        state = [sportDictionary objectForKey:@"state"];
        country = [sportDictionary objectForKey:@"country"];
        city = [sportDictionary objectForKey:@"city"];
        sport_logo_thumb = [sportDictionary objectForKey:@"sport_logo_thumb"];
        sport_logo_tiny = [sportDictionary objectForKey:@"sport_logo_tiny"];
        banner = [sportDictionary objectForKey:@"banner_url"];
        name = [sportDictionary objectForKey:@"name"];
        season = [sportDictionary objectForKey:@"season"];
        has_stats = [NSNumber numberWithBool:[[sportDictionary objectForKey:@"has_stats"] boolValue]];
        alert_interval = [sportDictionary objectForKey:@"alert_interval"];
        gamelog_interval = [sportDictionary objectForKey:@"gamelog_interval"];
        newsfeed_interval = [sportDictionary objectForKey:@"newsfeed_interval"];
        beta = [[sportDictionary objectForKey:@"beta"] boolValue];
        approved = [[sportDictionary objectForKey:@"approved"] boolValue];
        package = [sportDictionary objectForKey:@"package"];
        silverMedia = [[sportDictionary objectForKey:@"silverMedia"] intValue];
        goldMedia = [[sportDictionary objectForKey:@"goldMedia"] intValue];
        platinumMedia = [[sportDictionary objectForKey:@"platinumMedia"] intValue];
        teamcount = [sportDictionary objectForKey:@"teamcount"];
        streamingurl = [sportDictionary objectForKey:@"streamingurl"];
        streamingbucket = [sportDictionary objectForKey:@"streamingbucket"];
        streamquality = [sportDictionary objectForKey:@"streamquality"];
        allstreams = [[sportDictionary objectForKey:@"allstreams"] boolValue];
        
        if ([name isEqualToString:@"Soccer"]) {
            playerPositions = [self parsePositions:[sportDictionary objectForKey:@"soccer_positions"]];
        } else if ([name isEqualToString:@"Basketball"]) {
            playerPositions = [self parsePositions:[sportDictionary objectForKey:@"basketball_positions"]];
        } else if ([name isEqualToString:@"Football"]) {
            footballOffensePositions = [self parsePositions:[sportDictionary objectForKey:@"football_offense_position"]];
            footballDefensePositions = [self parsePositions:[sportDictionary objectForKey:@"football_defense_position"]];
            footballSpecialTeamsPositions = [self parsePositions:[sportDictionary objectForKey:@"football_specialteams_position"]];
        }
        
        return self;
    } else {
        return nil;
    }
}

- (NSMutableDictionary *)parsePositions:(NSArray *)positions {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < positions.count; i++) {
        NSArray *pospair = [positions objectAtIndex:i];
        for (int cnt = 0; cnt < pospair.count; cnt = cnt + 2) {
            [result setObject:[pospair objectAtIndex:cnt + 1] forKey:[pospair objectAtIndex:cnt]];
        }
    }
    
    return result;
}

- (NSImage *)getImage:(NSString *)size {
    NSImage *image;
    
    if ([size isEqualToString:@"tiny"] ) {
        if ([sport_logo_tiny isEqualToString:@"/sport_logos/tiny/missing.png"]) {
            image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:@"photo_not_available.png"]];
        } else if ((sportimage == nil) || (![logosize isEqualToString:@"tiny"])) {
            NSURL * imageURL = [NSURL URLWithString:sport_logo_tiny];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            image = [[NSImage alloc] initWithData:imageData];
            sportimage = image;
            logosize = size;
        } else
            image = sportimage;
    } else if ([size isEqualToString:@"thumb"]) {        
        if (([sport_logo_thumb isEqualToString:@"/sport_logos/thumb/missing.png"]) || (sport_logo_thumb.length == 0)) {
            image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:@"photo_not_available.png"]];
        } else if ((sportimage == nil) || (![logosize isEqualToString:@"thumb"])) {
            NSURL * imageURL = [NSURL URLWithString:sport_logo_thumb];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            image = [[NSImage alloc] initWithData:imageData];
            sportimage = image;
            logosize = size;
        } else
            image = sportimage;
    }
    
    return image;
}

- (BOOL)isPackageEnabled {
    if (([self.package isEqualToString:@"Silver"]) || ([self.package isEqualToString:@"Gold"]) || ([self.package isEqualToString:@"Platinum"])) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isGoldPackage {
    if ([package isEqualToString:@"Gold"])
        return YES;
    else
        return NO;
}

- (BOOL)saveSport:(User *)user {
    NSString *stringurl;
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    if (self.id.length > 0) {
        stringurl = [NSString stringWithFormat:@"%@%@%@%@%@", [mainBundle objectForInfoDictionaryKey:@"EazesportzUrl"], @"/sports/",
                     self.id, @".json?auth_token=",  user.authtoken];
        
    } else {
        stringurl = [NSString stringWithFormat:@"%@%@%@", [mainBundle objectForInfoDictionaryKey:@"EazesportzUrl"],
                     @"/sports.json?auth_token=", user.authtoken];
    }
    
    NSURL *url = [NSURL URLWithString:stringurl];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss+00:00"];
    
    NSMutableDictionary *sportDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:sitename, @"sitename",
                                      mascot, @"mascot", year, @"year", zip, @"zip", country, @"country", city, @"city",
                                     user.email, @"contactemail", season, @"season", streamquality,
                                      @"streamquality", [NSString stringWithFormat:@"%d", allstreams], @"allstreams", nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:sportDict, @"sport", nil];
    
    NSError *jsonSerializationError = nil;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if (self.id.length > 0) {
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
        NSDictionary *items = [serverData objectForKey:@"sport"];
        [self initWithDictionary:items];
        
        return YES;
    } else {
        return NO;
    }
}

@end
