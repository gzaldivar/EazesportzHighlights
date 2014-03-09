//
//  eazesportzSelectPlayerWindowController.h
//  EazesportzHighlights
//
//  Created by Gil on 3/8/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Sport.h"
#import "Team.h"
#import "User.h"
#import "Athlete.h"
#import "EazesportzRetrievePlayers.h"

@interface eazesportzSelectPlayerWindowController : NSWindowController

@property (nonatomic, strong) Sport *sport;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) EazesportzRetrievePlayers *getPlayers;
@property (nonatomic, strong, readonly) Athlete *player;

- (IBAction)searchButtonClicked:(id)sender;
@property (weak) IBOutlet NSTextField *positionTextField;
@property (weak) IBOutlet NSTextField *numberTextField;
@property (weak) IBOutlet NSTableView *playerTableView;
- (IBAction)reloadButtonClicked:(id)sender;

@end
