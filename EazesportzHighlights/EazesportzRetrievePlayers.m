//
//  EazesportzRetrievePlayers.m
//  EazeSportz
//
//  Created by Gil on 1/9/14.
//  Copyright (c) 2014 Gil. All rights reserved.
//

#import "EazesportzRetrievePlayers.h"
#import "Athlete.h"

@implementation EazesportzRetrievePlayers {
    long responseStatusCode;
    NSMutableArray *serverData;
    NSMutableData *theData;
    
    NSURLRequest *originalRequest;
    Sport *thesport;
}

@synthesize roster;

- (void)retrievePlayers:(Sport *)sport Team:(Team *)team User:(User *)user {
    thesport = sport;
    NSURL *url;
    
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@",
                                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzUrl"],
                                @"/sports/", sport.id, @"/athletes.json?team_id=", team.teamid,
                                @"&auth_token=", user.authtoken]];
    
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
    NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                       otherButton:nil informativeTextWithFormat:@"Error connecting to server"];
    [alert setIcon:[thesport getImage:@"tiny"]];
    [alert runModal];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    serverData = [NSJSONSerialization JSONObjectWithData:theData options:0 error:nil];
    if (responseStatusCode == 200) {
        roster = [[NSMutableArray alloc] init];
        for (int i = 0; i < [serverData count]; i++ ) {
            [roster addObject:[[Athlete alloc] initWithDictionary:[serverData objectAtIndex:i] Sport:thesport]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RosterChangedNotification" object:nil
                        userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Success", @"Result", nil]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RosterChangedNotification" object:nil
                                                          userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Error retrieving roster", @"Result", nil]];
    }
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    if (redirectResponse) {
        NSMutableURLRequest *newrequest = [originalRequest mutableCopy];
        [newrequest setURL:[request URL]];
        return  newrequest;
    } else {
        return request;
    }
}

@end
