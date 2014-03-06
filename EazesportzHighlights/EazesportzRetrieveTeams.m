//
//  EazesportzRetrieveTeams.m
//  EazeSportz
//
//  Created by Gil on 1/10/14.
//  Copyright (c) 2014 Gil. All rights reserved.
//

#import "EazesportzRetrieveTeams.h"
#import "Team.h"

@implementation EazesportzRetrieveTeams {
    long responseStatusCode;
    NSMutableArray *serverData;
    NSMutableData *theData;
    
    NSURLRequest *originalRequest;
    Sport *thesport;
}

@synthesize teams;

- (void)retrieveTeams:(Sport *)sport User:(User *)user {
    thesport = sport;
    NSURL *url;
    
    if (user)
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@",
                                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzUrl"],
                                    @"/sports/", sport.id, @"/teams.json?auth_token=", user.authtoken]];
    else
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@",
                                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzUrl"],
                                    @"/sports/", sport.id, @"/teams.json"]];
    
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
        teams =[[NSMutableArray alloc] init];
        for (int i = 0; i < [serverData count]; i++) {
            [teams addObject:[[Team alloc] initWithDictionary:[serverData objectAtIndex:i] Sport:thesport]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TeamListChangedNotification" object:nil
                                              userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Success", @"Result", nil]];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TeamListChangedNotification" object:nil
                    userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Error Retreving Teams", @"Result", nil]];
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
