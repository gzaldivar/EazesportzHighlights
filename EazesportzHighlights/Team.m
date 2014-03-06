//
//  Team.m
//  smpwlions
//
//  Created by Gil on 3/9/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import "Team.h"
#import "EazesportzRetrieveTeams.h"

@implementation Team {
    NSString *logosize;
}

@synthesize teamid;
@synthesize mascot;
@synthesize title;
@synthesize team_name;
@synthesize team_logo;
@synthesize tiny_logo;

@synthesize fb_def_players;
@synthesize fb_kickers;
@synthesize fb_pass_players;
@synthesize fb_placekickers;
@synthesize fb_punters;
@synthesize fb_rec_players;
@synthesize fb_returners;
@synthesize fb_rush_players;

@synthesize httpError;

@synthesize teamimage;

- (id)init {
    if (self = [super init]) {
        logosize = @"";
        teamimage = nil;
        
        fb_pass_players = [[NSMutableArray alloc] init];
        fb_rec_players = [[NSMutableArray alloc] init];
        fb_rush_players = [[NSMutableArray alloc] init];
        fb_def_players = [[NSMutableArray alloc] init];
        fb_kickers = [[NSMutableArray alloc] init];
        fb_placekickers = [[NSMutableArray alloc] init];
        fb_returners = [[NSMutableArray alloc] init];
        fb_punters = [[NSMutableArray alloc] init];
        return self;
    } else
        return nil;
}

- (id)initWithDictionary:(NSDictionary *)teamDictionary Sport:(Sport *)sport {
    if ((self = [super init]) && (teamDictionary.count > 0)) {
        team_name = [teamDictionary objectForKey:@"team_name"];
        mascot = [teamDictionary objectForKey:@"mascot"];
        teamid = [teamDictionary objectForKey:@"id"];
        title = [teamDictionary objectForKey:@"title"];
        
        if ((NSNull *)[teamDictionary objectForKey:@"team_logo"] != [NSNull null])
            team_logo = [teamDictionary objectForKey:@"team_logo"];
        else
            team_logo = @"";
        
        if ((NSNull *)[teamDictionary objectForKey:@"tiny_logo"] != [NSNull null])
            tiny_logo = [teamDictionary objectForKey:@"tiny_logo"];
        else
            tiny_logo = @"";
        
        if ([sport.name isEqualToString:@"Football"]) {
            fb_pass_players = [teamDictionary objectForKey:@"fb_pass_players"];
            fb_rush_players = [teamDictionary objectForKey:@"fb_rush_players"];
            fb_rec_players = [teamDictionary objectForKey:@"fb_rec_players"];
            fb_def_players = [teamDictionary objectForKey:@"fb_def_players"];
            fb_punters = [teamDictionary objectForKey:@"fb_punters"];
            fb_placekickers = [teamDictionary objectForKey:@"fb_place_kickers"];
            fb_kickers = [teamDictionary objectForKey:@"fb_kickers"];
            fb_returners = [teamDictionary objectForKey:@"fb_returners"];
        }
        
        return self;
    } else {
        return nil;
    }
}

- (NSImage *)getImage:(NSString *)size Sport:(Sport *)sport {
    NSImage *image;
    
    if ([size isEqualToString:@"tiny"]) {
        
        if (([self.tiny_logo isEqualToString:@"/team_logos/tiny/missing.png"]) || (self.team_logo.length == 0)) {
            image = [sport getImage:@"tiny"];
        } else if ((self.teamimage == nil) || (![logosize isEqualToString:@"tiny"])) {
            NSURL * imageURL = [NSURL URLWithString:self.tiny_logo];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            image = [[NSImage alloc] initWithData:imageData];
            self.teamimage = image;
            logosize = size;
        } else
            image = self.teamimage;
        
    } else if ([size isEqualToString:@"thumb"]) {
        
        if (([self.team_logo isEqualToString:@"/team_logos/thumb/missing.png"]) || (self.team_logo.length == 0)) {
            image = [sport getImage:@"thumb"];
        } else if ((self.teamimage == nil) || (![logosize isEqualToString:@"thumb"])) {
            NSURL * imageURL = [NSURL URLWithString:self.team_logo];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            image = [[NSImage alloc] initWithData:imageData];
            self.teamimage = image;
            logosize = size;
        } else
            image = self.teamimage;
        
    }
    
    return image;
}

- (BOOL)hasImage {
    if (([self.team_logo isEqualToString:@"/team_logos/thumb/missing.png"]) || (self.team_logo.length == 0)) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)saveTeam:(Sport *)sport User:(User *)user {
    NSURL *aurl;
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    if (self.teamid.length > 0)
        aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@",
                                     [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                     @"/sports/", sport.id, @"/teams/", teamid, @".json?auth_token=", user.authtoken]];
    else
        aurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@",
                                     [mainBundle objectForInfoDictionaryKey:@"SportzServerUrl"],
                                     @"/sports/", sport.id, @"/teams.json?auth_token=", user.authtoken]];
    
    NSMutableDictionary *teamDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:team_name, @"title",
                                     mascot, @"mascot", nil];
    
    if ([sport.name isEqualToString:@"Football"]) {
        [teamDict setValue:fb_pass_players forKey:@"fb_pass_players"];
        [teamDict setValue:fb_rush_players forKey:@"fb_rush_players"];
        [teamDict setValue:fb_rec_players forKey:@"fb_rec_players"];
        [teamDict setValue:fb_def_players forKey:@"fb_def_players"];
        [teamDict setValue:fb_kickers forKey:@"fb_kickers"];
        [teamDict setValue:fb_placekickers forKey:@"fb_placekickers"];
        [teamDict setValue:fb_returners forKey:@"fb_returners"];
        [teamDict setValue:fb_punters forKey:@"fb_punters"];
    }
    
    /*    if (imageselected) {
     UIImage *photoImage = _teamImage.image;
     NSData *imageData = UIImageJPEGRepresentation(photoImage, 1.0);
     NSString *imageDataEncodedString = [imageData base64EncodedString];
     [teamDict setObject:imageDataEncodedString forKey:@"image_data"];
     [teamDict setObject:@"image/jpg" forKey:@"content_type"];
     NSString *name = [_teamnameTextField.text stringByAppendingFormat:@"%@%@%@", @"_", _mascotTextField.text, @".jpg"];
     [teamDict setObject:name forKey:@"original_filename"];
     imageselected = NO;
     }
     */
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl];
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:teamDict, @"team", nil];
    
    NSError *jsonSerializationError = nil;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if (teamid.length > 0) {
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
    NSDictionary *items = [serverData objectForKey:@"team"];
    
    if ([httpResponse statusCode] == 200) {
        if (teamid.length == 0) {
            teamid = [items objectForKey:@"_id"];
        }
        [[[EazesportzRetrieveTeams alloc] init] retrieveTeams:sport User:user];
        return YES;
    } else {
        httpError = [serverData objectForKey:@"error"];
        return NO;
    }
}

@end
