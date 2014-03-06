//
//  eazesportzMasterViewController.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 1/31/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Sport.h"
#import "Team.h"
#import "User.h"
#import "GameSchedule.h"

@interface eazesportzMasterViewController : NSViewController

@property (weak) IBOutlet NSTextField *sportNameLabel;
@property (weak) IBOutlet NSImageView *homeTeamImage;
@property (weak) IBOutlet NSSegmentedControl *videoTypeSegmentedControl;
- (IBAction)videoSegmentControlClicked:(id)sender;

@property (weak) IBOutlet NSTableView *gamesTableView;

@property (nonatomic, strong) Sport *sport;
@property (nonatomic, strong) User *user;
- (IBAction)teamButtonClicked:(id)sender;
@property (weak) IBOutlet NSButton *teamButton;

@property (nonatomic, strong) NSWindow *masterWindow;
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong, readonly) GameSchedule *game;
@property (nonatomic, strong) Team *team;
- (IBAction)homeButtonClicked:(id)sender;
- (IBAction)processVideoButtonClicked:(id)sender;
- (IBAction)gameButtonClicked:(id)sender;
@property (weak) IBOutlet NSTextField *teamLabel;
@property (weak) IBOutlet NSTextField *gameLabel;
@property (weak) IBOutlet NSDatePicker *highlightDate;
- (IBAction)downloadFileButtonClicked:(id)sender;

@end
