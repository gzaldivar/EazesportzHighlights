//
//  eazesportzScheduleBroadcastViewController.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/21/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Sport.h"
#import "User.h"
#import "Team.h"
#import "Event.h"

@interface eazesportzScheduleBroadcastViewController : NSViewController

@property (weak) IBOutlet NSTextField *teamLabel;
- (IBAction)broadcastScheduleButtonClicked:(id)sender;
@property (weak) IBOutlet NSButton *broadcastScheduleButton;
@property (weak) IBOutlet NSTableView *scheduleTableView;

@property (nonatomic, strong) Sport *sport;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong, readonly) Team *team;

@property (nonatomic, strong, readonly) Event *event;

- (IBAction)homeButtonClicked:(id)sender;
- (IBAction)selectTeamButtonClicked:(id)sender;
- (IBAction)newScheduleButtonClicked:(id)sender;
@property (weak) IBOutlet NSDatePicker *startDatePicker;
@property (weak) IBOutlet NSDatePicker *endDatePicker;
- (IBAction)searchEventsButtonClicked:(id)sender;

@end
