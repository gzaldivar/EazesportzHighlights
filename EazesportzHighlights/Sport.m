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
        
        self.id = [sportDictionary objectForKey:@"id"];
        sitename = [sportDictionary objectForKey:@"sitename"];
        mascot = [sportDictionary objectForKey:@"mascot"];
        year = [sportDictionary objectForKey:@"year"];
        zip = [sportDictionary objectForKey:@"zip"];
        state = [sportDictionary objectForKey:@"state"];
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
        silverMedia = [[sportDictionary objectForKey:@"silverMedia"] integerValue];
        goldMedia = [[sportDictionary objectForKey:@"goldMedia"] integerValue];
        platinumMedia = [[sportDictionary objectForKey:@"platinumMedia"] integerValue];
        teamcount = [sportDictionary objectForKey:@"teamcount"];
        
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

@end
