//
//  Event.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/26/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "Team.h"
#import "User.h"
#import "GameSchedule.h"

@interface Event : NSObject

@property (nonatomic, strong) NSString *event_id;
@property (nonatomic, strong) NSDate *startdate;
@property (nonatomic, strong) NSDate *enddate;
@property (nonatomic, strong) NSNumber *videoevent;                  // 0 = no video, 1 = Live, 2 = Local file, 3 = Downloaded File
@property (nonatomic, strong) NSString *eventname;
@property (nonatomic, strong) NSString *eventdesc;
@property (nonatomic, strong) NSString *eventurl;
@property (nonatomic, strong) NSString *team_id;
@property (nonatomic, strong) NSString *gameschedule_id;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *sport_id;

@property (nonatomic, strong) NSString *httperror;

- (id)initWithDictionary:(NSDictionary *)eventDictionary Sport:(Sport *)sport;

- (BOOL)saveEvent:(Sport *)sport Team:(Team *)team Game:(GameSchedule *)game User:(User *)user;

- (BOOL)deleteEvent:(User *)user;

- (GameSchedule *)getGame:(Sport *)sport Team:(Team *)team User:(User *)user;

@end
