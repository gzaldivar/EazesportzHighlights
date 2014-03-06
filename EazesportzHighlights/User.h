//
//  User.h
//  sportzSoftwareHome
//
//  Created by Gil on 2/6/13.
//  Copyright (c) 2013 Gilbert Zaldivar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSString *authtoken;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *userid;
@property(nonatomic, strong) NSString *userUrl;
@property(nonatomic, strong) NSString *userthumb;
@property(nonatomic, strong) NSString *tiny;
@property(nonatomic, strong) NSNumber *bio_alert;
@property(nonatomic, strong) NSNumber *media_alert;
@property(nonatomic, strong) NSNumber *blog_alert;
@property(nonatomic, strong) NSNumber *stat_alert;
@property(nonatomic, strong) NSNumber *score_alert;
@property(nonatomic, assign) NSNumber *admin;
@property(nonatomic, strong) NSString *teammanagerid;
@property(nonatomic, strong) NSNumber *isactive;
@property(nonatomic, assign) BOOL avatarprocessing;
@property(nonatomic, strong) NSString *tier;
@property(nonatomic, strong) NSString *default_site;

@property(nonatomic, strong) NSString *awssecretkey;
@property(nonatomic, strong) NSString *awskeyid;

- (BOOL)isBasic;

- (id)initWithDictionary:(NSDictionary *)userDictionary;

@end
