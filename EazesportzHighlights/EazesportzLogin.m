//
//  EazesportzLogin.m
//  EazeSportz
//
//  Created by Gil on 1/10/14.
//  Copyright (c) 2014 Gil. All rights reserved.
//

#import "EazesportzLogin.h"
#import "EazesportzAppDelegate.h"
#import "sportzConstants.h"

@implementation EazesportzLogin {
    int responseStatusCode;
    NSMutableArray *serverData;
    NSMutableData *theData;
    
    NSURLRequest *originalRequest;
    
    NSString *email, *password;
    BOOL userinfo;
}

@synthesize user;

- (void)Login:(NSString *)loginemail Password:(NSString *)loginpassword {
    
    password = loginpassword;
    email = loginemail;
    userinfo = NO;
    
    NSString *sport = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"sportzteams"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzSSLUrl"], @"/users/sign_in.json"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSDictionary *userDict = [[NSDictionary alloc] initWithObjectsAndKeys:email, @"email",password, @"password", sport, @"sport", nil];
    
    NSError *jsonSerializationError = nil;
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:userDict, @"user", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonSerializationError];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    originalRequest = request;
    [[NSURLConnection alloc] initWithRequest:request  delegate:self];
}

- (void)Login:(NSString *)loginemail Password:(NSString *)loginpassword Site:(NSString *)site {
    password = loginpassword;
    email = loginemail;
    userinfo = NO;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",
                                       [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzSSLUrl"],
                                       @"/users/sign_in.json"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSDictionary *userDict = [[NSDictionary alloc] initWithObjectsAndKeys:email, @"email",
                              password, @"password", site, @"site", nil];
    
    NSError *jsonSerializationError = nil;
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:userDict, @"user", nil];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonSerializationError];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    originalRequest = request;
    [[NSURLConnection alloc] initWithRequest:request  delegate:self];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    responseStatusCode = (int)[httpResponse statusCode];
    theData = [[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [theData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Error"
                                     defaultButton:@"OK" alternateButton:nil
                                       otherButton:nil informativeTextWithFormat:@"Error connecting to server"];
    [alert runModal];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSDictionary *token = [NSJSONSerialization JSONObjectWithData:theData options:0 error:nil];

    if ((responseStatusCode == 200) && (!userinfo)) {
        NSUInteger passHash = [password hash];
        
        NSDictionary *userdata = [token objectForKey:@"user"];
        NSLog(@"%@", userdata);
        
        user = [[User alloc] init];
        
        if([userdata count] > 0) {
            user.userid = [userdata objectForKey:@"_id"];
            user.email = [userdata objectForKey:@"email"];
            user.authtoken = [token objectForKey:@"authentication_token"];
            user.username = [userdata objectForKey:@"username"];
            
            userinfo = YES;
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzSSLUrl"],
                                @"/users/", user.userid, @".json?auth_token=",  user.authtoken]];
            originalRequest = [NSMutableURLRequest requestWithURL:url];
            [[NSURLConnection alloc] initWithRequest:originalRequest delegate:self];
        } else {
            user.email = @"";
            user.authtoken = @"";
            user.username = @"";
            user.userid = @"";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginNotification" object:nil
                        userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:
                        @"Please activate your account using the email sent when you registered", @"Result",nil]];
        }
    } else if ((responseStatusCode == 200) && (userinfo)) {
        NSDictionary *userdata = [NSJSONSerialization JSONObjectWithData:theData options:0 error:nil];
        user = [[User alloc] initWithDictionary:userdata];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginNotification" object:nil
                            userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Success", @"Result", nil]];
    } else {
        if (!userinfo) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginNotification" object:nil
                                                userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Invalid Login", @"Result", nil]];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginNotification" object:nil
                                                userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Error Retrieving User", @"Result" , nil]];
        }
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
