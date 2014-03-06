//
//  eazesportzSelectTeamViewController.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 1/31/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzSelectTeamViewController.h"
#import "EazesportzRetrieveTeams.h"

@interface eazesportzSelectTeamViewController ()

@end

@implementation eazesportzSelectTeamViewController {
    EazesportzRetrieveTeams *getTeams;
}

@synthesize sport;
@synthesize user;
@synthesize teamSelectWindow;

@synthesize team;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    getTeams = [[EazesportzRetrieveTeams alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotTeams:) name:@"TeamListChangedNotification"
                                               object:nil];
    [getTeams retrieveTeams:sport User:user];
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
    
//    if (getTeams.teams.count > 0) {
//        [_teamTableView scrollRowToVisible:getTeams.teams.count];
//    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSInteger teamselected = [_teamTableView selectedRow];
    [self teamSelected:[getTeams.teams objectAtIndex:teamselected]];
}

- (void)teamSelected:(Team *)theteam {
    team = theteam;
    [self.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TeamSelectedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
