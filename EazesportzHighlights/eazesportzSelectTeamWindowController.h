//
//  eazesportzSelectTeamWindowController.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/21/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Sport.h"
#import "Team.h"
#import "User.h"

@interface eazesportzSelectTeamWindowController : NSWindowController

@property (weak) IBOutlet NSTableView *teamTableView;

@property (nonatomic, strong) NSWindow *teamSelectWindow;
@property (nonatomic, strong) Sport *sport;
@property (nonatomic, strong) User *user;

@property (nonatomic, strong) Team *team;

@end
