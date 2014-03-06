//
//  eazesportzVideoFileWindowController.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 3/1/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Sport.h"
#import "Team.h"
#import "User.h"
#import "Video.h"
#import "Event.h"

@interface eazesportzVideoFileWindowController : NSWindowController

@property (nonatomic, strong) Sport *sport;
@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) GameSchedule *game;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Video *video;
@property (nonatomic, strong) Event *event;

@property (weak) IBOutlet NSTableView *videoTableView;
@property (weak) IBOutlet NSTextField *teamLabel;
@property (weak) IBOutlet NSTextField *downloadFileLabel;
@property (weak) IBOutlet NSProgressIndicator *activityIndicator;
@property (weak) IBOutlet NSTextField *gameLabel;

@end
