//
//  EazesportzRetrieveEvents.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/26/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"
#import "Team.h"
#import "User.h"

@interface EazesportzRetrieveEvents : NSObject

- (void)retrieveEvents:(Sport *)sport Team:(Team *)team Token:(User *)user;

@property (nonatomic, strong) NSDate *startdate;
@property (nonatomic, strong) NSDate *enddate;
@property(nonatomic, strong, readonly) NSMutableArray *eventlist;
@property (nonatomic, strong, readonly) NSMutableArray *videoEventList;

@end
