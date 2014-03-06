//
//  EazesportzRetrieveTeams.h
//  EazeSportz
//
//  Created by Gil on 1/10/14.
//  Copyright (c) 2014 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "User.h"

@interface EazesportzRetrieveTeams : NSObject

@property(nonatomic, strong) NSMutableArray *teams;

- (void)retrieveTeams:(Sport *)sport User:(User *)user;

@end
