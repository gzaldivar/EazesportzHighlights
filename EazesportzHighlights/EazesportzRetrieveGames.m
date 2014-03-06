//
//  EazesportzRetrieveGames.m
//  EazeSportz
//
//  Created by Gil on 1/9/14.
//  Copyright (c) 2014 Gil. All rights reserved.
//

#import "EazesportzRetrieveGames.h"
#import "GameSchedule.h"

@implementation EazesportzRetrieveGames {
    long responseStatusCode;
    NSMutableArray *serverData;
    NSMutableData *theData;
    
    NSURLRequest *originalRequest;
    Sport *thesport;
}

@synthesize gameList;

- (void)retrieveGames:(Sport *)sport Team:(NSString *)teamid Token:(NSString *)authtoken {
    thesport = sport;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",
                                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzUrl"],
                                    @"/sports/", sport.id, @"/teams/", teamid, @"/gameschedules.json",
                                    @"?auth_token=", authtoken]];
    
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
        gameList = [[NSMutableArray alloc] init];
        NSLog(@"%@", serverData);
        
        for (int i = 0; i < [serverData count]; i++ ) {
            [gameList addObject:[[GameSchedule alloc] initWithDictionary:[serverData objectAtIndex:i] Sport:thesport]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GameListChangedNotification" object:nil];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error"
                                         defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Error connecting to server"];
        [alert runModal];
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
