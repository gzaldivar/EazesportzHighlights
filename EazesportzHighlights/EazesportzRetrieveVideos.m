//
//  EazesportzRetrieveVideos.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 3/1/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "EazesportzRetrieveVideos.h"
#import "eazesportzGetGame.h"

@implementation EazesportzRetrieveVideos {
    long responseStatusCode;
    NSMutableArray *serverData;
    NSMutableData *theData;
    
    NSURLRequest *originalRequest;
    Sport *thesport;
    Team *theteam;
    User *theuser;
}

@synthesize videos;

- (void)retrieveVideos:(Sport *)sport Team:(Team *)team Game:(GameSchedule *)game User:(User *)user {
    thesport = sport;
    theteam = team;
    theuser = user;
    
    NSString *stringurl = [NSString stringWithFormat:@"%@%@%@%@%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzUrl"],
                           @"/sports/", sport.id, @"/videoclips.json?auth_token=", user.authtoken];
    
    if (team) {
        stringurl = [stringurl stringByAppendingFormat:@"&team_id=%@", team.teamid];
    }
    
    if (game) {
        stringurl = [stringurl stringByAppendingFormat:@"&gameschedule_id=%@", game.id];
    }
    
    NSURL *url = [NSURL URLWithString:stringurl];
    originalRequest = [NSURLRequest requestWithURL:url];
    [[NSURLConnection alloc] initWithRequest:originalRequest delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    responseStatusCode = [httpResponse statusCode];
    theData = [[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [theData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Error"
                                     defaultButton:@"OK" alternateButton:nil
                                       otherButton:nil informativeTextWithFormat:@"Error connecting to server"];
    [alert setIcon:[thesport getImage:@"tiny"]];
    [alert runModal];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    serverData = [NSJSONSerialization JSONObjectWithData:theData options:0 error:nil];
    
    if (responseStatusCode == 200) {
        videos = [[NSMutableArray alloc] init];
        NSLog(@"%@", serverData);
        
        for (int i = 0; i < [serverData count]; i++ ) {
            [videos addObject:[[Video alloc] initWithDirectory:[serverData objectAtIndex:i]]];
            
            if ([[videos objectAtIndex:i] schedule].length > 0) {
                eazesportzGetGame *getGame = [[eazesportzGetGame alloc] init];
                Video *thevideo = [videos objectAtIndex:i];
                thevideo.game = [getGame getGameSynchronous:thesport Team:theteam Game:[[videos objectAtIndex:i] schedule] User:theuser];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoListChangedNotification" object:nil
                                                          userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Success", @"Result", nil]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoListChangedNotification" object:nil
                                                          userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Error", @"Result", nil]];
    }
}

@end
