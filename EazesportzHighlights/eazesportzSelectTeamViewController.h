//
//  eazesportzSelectTeamViewController.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 1/31/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Sport.h"
#import "Team.h"
#import "User.h"

@interface eazesportzSelectTeamViewController : NSViewController

@property (weak) IBOutlet NSTableView *teamTableView;

@property (nonatomic, strong) NSWindow *teamSelectWindow;
@property (nonatomic, strong) Sport *sport;
@property (nonatomic, strong) User *user;

@property (nonatomic, strong, readonly) Team *team;

@end
