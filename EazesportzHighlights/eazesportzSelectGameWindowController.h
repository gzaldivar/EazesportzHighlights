//
//  eazesportzSelectGameWindowController.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/21/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Sport.h"
#import "Team.h"
#import "User.h"
#import "GameSchedule.h"

@interface eazesportzSelectGameWindowController : NSWindowController

@property (weak) IBOutlet NSTableView *gamesTableView;

@property (nonatomic, strong) Sport *sport;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Team *team;
@property (nonatomic, strong, readonly) GameSchedule *game;
@property (weak) IBOutlet NSProgressIndicator *activityIndicator;

@end
