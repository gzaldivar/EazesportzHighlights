//
//  eazesportzUploadHighlightWindowController.h
//  EazesportzHighlights
//
//  Created by Gil on 3/8/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Sport.h"
#import "Team.h"
#import "GameSchedule.h"
#import "Gamelogs.h"
#import "User.h"
#import "EazesportzRetrievePlayers.h"

@interface eazesportzEditHighlightWindowController : NSWindowController

@property (nonatomic, strong) Sport *sport;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) GameSchedule *game;
@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) EazesportzRetrievePlayers *getPlayers;

@property (nonatomic, strong) NSString *clipname;

@property (nonatomic, strong, readonly) NSMutableArray *players;
@property (nonatomic, strong, readonly) Gamelogs *gamelog;

@property (weak) IBOutlet NSTextField *highlightNameTextField;
@property (weak) IBOutlet NSTextField *teamLabel;
@property (weak) IBOutlet NSTextField *gameTextField;
@property (weak) IBOutlet NSComboBox *gamelogComboBox;
- (IBAction)saveButtonClicked:(id)sender;
@property (weak) IBOutlet NSTextField *playtagLabel;
@property (weak) IBOutlet NSButton *gameButton;
- (IBAction)gameButtonClicked:(id)sender;
- (IBAction)playerButtonClicked:(id)sender;
@property (unsafe_unretained) IBOutlet NSTextView *highlightsDescription;
@property (weak) IBOutlet NSComboBox *playerTagsComboBox;

@end
