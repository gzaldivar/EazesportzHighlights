//
//  eazesportzGetGame.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/27/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzGetGame.h"

@implementation eazesportzGetGame {
    long responseStatusCode;
    NSDictionary *serverData;
    NSMutableData *theData;
    
    NSURLRequest *originalRequest;
    Sport *thesport;
}

@synthesize game;

- (void)retrieveGame:(Sport *)sport Team:(Team *)team Game:(NSString *)gameid User:(User *)user {
    thesport = sport;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzUrl"],
                                       @"/sports/", sport.id, @"/teams/", team.teamid, @"/gameschedules/", gameid, @".json?auth_token=", user.authtoken]];
    
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
        game = [[GameSchedule alloc] initWithDictionary:serverData Sport:thesport];
        NSLog(@"%@", serverData);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GameRetrievedNotification" object:nil
                                                          userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Result", @"Success", nil]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GameRetrievedNotification" object:nil
                                                          userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Result", @"Error", nil]];
    }
}

- (GameSchedule *)getGameSynchronous:(Sport *)sport Team:(Team *)team Game:(NSString *)gameid User:(User *)user {
    GameSchedule *thegame = nil;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzUrl"],
                                       @"/sports/", sport.id, @"/teams/", team.teamid, @"/gameschedules/", gameid, @".json?auth_token=", user.authtoken]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse* response;
    NSError *error = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSDictionary *thedata = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
    
    if ([httpResponse statusCode] == 200) {
        thegame = [[GameSchedule alloc] initWithDictionary:thedata Sport:sport];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil
                             informativeTextWithFormat:@"Error retrieving game"];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
    
    return thegame;
}

@end
