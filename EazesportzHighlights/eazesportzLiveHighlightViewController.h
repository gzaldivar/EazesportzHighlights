//
//  eazesportzLiveVideoViewController.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/18/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Sport.h"
#import "User.h"
#import "Team.h"
#import "Event.h"
#import "EazesportzRetrievePlayers.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface eazesportzLiveHighlightViewController : NSViewController

@property (nonatomic, strong) Sport *sport;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) EazesportzRetrievePlayers *getPlayers;

@property (nonatomic, assign) BOOL highdef;
- (IBAction)homeButtonClicked:(id)sender;

@property (nonatomic, strong) __block NSTask *buildTask;
@property (nonatomic, strong) __block NSTask *clipTask;

@property (nonatomic) BOOL isRunning;
@property (nonatomic, strong) NSPipe *outputPipe;
@property (nonatomic, strong) NSPipe *stderrorPipe;
@property (nonatomic, strong) NSPipe *createclipPipe;

@property (weak) IBOutlet AVPlayerView *playerView;
- (IBAction)clipButtonClicked:(id)sender;
@property (weak) IBOutlet NSButton *clipButton;
@property (weak) IBOutlet NSTextField *highlightsDir;
@property (weak) IBOutlet NSComboBox *uploadComboBox;

@end
