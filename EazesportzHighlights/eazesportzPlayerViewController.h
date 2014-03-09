//
//  eazesportzPlayerViewController.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/4/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#import "GameSchedule.h"
#import "User.h"
#import "Team.h"
#import "Sport.h"
#import "EazesportzRetrievePlayers.h"

@interface eazesportzPlayerViewController : NSViewController

@property (weak) IBOutlet AVPlayerView *playerView;

@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) GameSchedule *game;
@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) Sport *sport;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) EazesportzRetrievePlayers *getPlayers;

@property (nonatomic, assign) BOOL highdef;
@property (nonatomic, strong) NSDate *highlightDate;

- (IBAction)trimButtonClicked:(id)sender;
- (IBAction)reloadvideoButtonClicked:(id)sender;
- (IBAction)saveButtonClicked:(id)sender;
@property (weak) IBOutlet NSTableView *clipTableView;
@property (weak) IBOutlet NSTextField *clipsLabel;
@property (weak) IBOutlet NSTextField *gameLabel;
@property (weak) IBOutlet NSButton *saveButton;
@property (weak) IBOutlet NSProgressIndicator *activityIndicator;
@property (weak) IBOutlet NSButton *deleteButton;
- (IBAction)deleteButtonClicked:(id)sender;
@property (weak) IBOutlet NSButton *trimButton;
@property (weak) IBOutlet NSButton *reloadButton;
- (IBAction)homeButtonClicked:(id)sender;
@property (weak) IBOutlet NSButton *hideClipsButton;
@property (weak) IBOutlet NSTextField *nogameLabel;

/**
 * NSTask
 */
@property (nonatomic, strong) __block NSTask *buildTask;
@property (nonatomic) BOOL isRunning;
@property (nonatomic, strong) NSPipe *outputPipe;
@property (nonatomic, strong) NSPipe *stderrorPipe;

@end
