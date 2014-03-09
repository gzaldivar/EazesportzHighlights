//
//  EazesportzRetrievePlayers.h
//  EazeSportz
//
//  Created by Gil on 1/9/14.
//  Copyright (c) 2014 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "Team.h"
#import "User.h"
#import "Athlete.h"

@interface EazesportzRetrievePlayers : NSObject

- (void)retrievePlayers:(Sport *)sport Team:(Team *)team User:(User *)user;

@property (nonatomic, strong, readonly) NSMutableArray *roster;

- (Athlete *)findAthleteById:(NSString *)athleteid;

@end
