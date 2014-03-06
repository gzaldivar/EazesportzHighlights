//
//  eazesportzSelectTeamWindowController.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/21/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzSelectTeamWindowController.h"
#import "EazesportzRetrieveTeams.h"

@interface eazesportzSelectTeamWindowController ()

@end

@implementation eazesportzSelectTeamWindowController {
    EazesportzRetrieveTeams *getTeams;
}

@synthesize sport;
@synthesize user;
@synthesize teamSelectWindow;

@synthesize team;


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    getTeams = [[EazesportzRetrieveTeams alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotTeams:) name:@"TeamListChangedNotification"
                                               object:nil];
    [getTeams retrieveTeams:sport User:user];
    [_teamTableView deselectAll:self];
}

- (void)gotTeams:(NSNotification *)notification {
    if (getTeams.teams.count == 1) {
        [self teamSelected:[getTeams.teams objectAtIndex:0]];
    } else {
        [_teamTableView reloadData];
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"TeamSelectCell" owner:self];
    
    if( [tableColumn.identifier isEqualToString:@"TeamColumn"] ) {
        Team *ateam = [getTeams.teams objectAtIndex:row];
        cellView.imageView.image = [ateam getImage:@"tiny" Sport:sport];
        cellView.textField.stringValue = ateam.team_name;
        return cellView;
    }
    return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return getTeams.teams.count;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    if ([_teamTableView selectedRow] >= 0) {
        NSInteger teamselected = [_teamTableView selectedRow];
        [self teamSelected:[getTeams.teams objectAtIndex:teamselected]];
    }
}

- (void)teamSelected:(Team *)theteam {
    team = theteam;
    [self.window close];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TeamSelectedNotification" object:nil];
}

@end
