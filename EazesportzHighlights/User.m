//
//  User.m
//  sportzSoftwareHome
//
//  Created by Gil on 2/6/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize username;
@synthesize authtoken;
@synthesize email;
@synthesize userid;
@synthesize admin;
@synthesize userUrl;
@synthesize tiny;
@synthesize userthumb;
@synthesize bio_alert;
@synthesize blog_alert;
@synthesize media_alert;
@synthesize stat_alert;
@synthesize score_alert;
@synthesize teammanagerid;
@synthesize isactive;
@synthesize avatarprocessing;
@synthesize tier;
@synthesize default_site;

@synthesize awskeyid;
@synthesize awssecretkey;

- (id)init {
    if ((self = [super init])) {
        self.email = @"";
        self.username = @"";
        self.authtoken = @"";
        self.userid = @"";
        self.admin = NO;
        self.userUrl = @"";
        self.tiny = @"";
        self.userthumb = @"";
        self.blog_alert = NO;
        self.bio_alert = NO;
        self.media_alert = NO;
        self.stat_alert = NO;
        self.score_alert = NO;
        self.teammanagerid = @"";
        self.isactive = NO;
        self.avatarprocessing = NO;
        self.tier = @"";
        self.default_site = @"";
        self.awskeyid = @"";
        self.awssecretkey = @"";
        return self;
    } else
        return nil;
}

- (BOOL)isBasic {
    if ([tier isEqualToString:@"Basic"])
        return YES;
    else
        return NO;
}

- (id)initWithDictionary:(NSDictionary *)userDictionary {
    if ((self = [super init]) && (userDictionary.count > 0)) {
        email = [userDictionary objectForKey:@"email"];
        userid = [userDictionary objectForKey:@"id"];
        username = [userDictionary objectForKey:@"name"];
        avatarprocessing = [[userDictionary objectForKey:@"avatarprocessing"] boolValue];
        
        if ((NSNull *)[userDictionary objectForKey:@"avatarthumburl"] != [NSNull null])
            userthumb = [userDictionary objectForKey:@"avatarthumburl"];
        else
            userthumb = @"";
        
        if ((NSNull *)[userDictionary objectForKey:@"avatartinyurl"] != [NSNull null])
            tiny = [userDictionary objectForKey:@"avatartinyurl"];
        else
            tiny = @"";
        
        isactive = [NSNumber numberWithInteger:[[userDictionary objectForKey:@"is_active"] integerValue]];
        bio_alert = [NSNumber numberWithInteger:[[userDictionary objectForKey:@"bio_alert"] integerValue]];
        blog_alert = [NSNumber numberWithInteger:[[userDictionary objectForKey:@"blog_alert"] integerValue]];
        media_alert = [NSNumber numberWithInteger:[[userDictionary objectForKey:@"media_alert"] integerValue]];
        stat_alert = [NSNumber numberWithInteger:[[userDictionary objectForKey:@"stat_alert"] integerValue]];
        score_alert = [NSNumber numberWithInteger:[[userDictionary objectForKey:@"score_alert"] integerValue]];
        admin = [NSNumber numberWithInteger:[[userDictionary objectForKey:@"admin"] integerValue]];
        awssecretkey = [userDictionary objectForKey:@"awskey"];
        awskeyid = [userDictionary objectForKey:@"awskeyid"];
        tier = [userDictionary objectForKey:@"tier"];
        authtoken = [userDictionary objectForKey:@"authentication_token"];
        
        if ((NSNull *)[userDictionary objectForKey:@"default_site"] != [NSNull null])
            default_site = [userDictionary objectForKey:@"default_site"];
        else
            default_site = @"";
        
        return self;
    } else {
        return nil;
    }
}

@end
