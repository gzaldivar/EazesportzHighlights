//
//  eazesportzSelectGameWindowController.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/21/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzSelectGameWindowController.h"
#import "EazesportzRetrieveGames.h"
#import "eazesportzSelectGameWindowController.h"

@interface eazesportzSelectGameWindowController ()

@property (nonatomic, strong) IBOutlet eazesportzSelectGameWindowController *selectGameController;

@end

@implementation eazesportzSelectGameWindowController {
    EazesportzRetrieveGames *getGames;
}

@synthesize sport;
@synthesize team;
@synthesize user;
@synthesize game;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotGames:) name:@"GameListChangedNotification"
                                               object:nil];
    getGames = [[EazesportzRetrieveGames alloc] init];
    [getGames retrieveGames:sport Team:team.teamid Token:user.authtoken];
    [_gamesTableView deselectAll:self];
}

- (void)gotGames:(NSNotification *)notification {
    [_gamesTableView reloadData];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    GameSchedule *agame = [getGames.gameList objectAtIndex:row];
    
    if ([tableColumn.identifier isEqualToString:@"GameScheduleColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"GameScheduleCell" owner:self];
        cellView.imageView.image = [agame opponentImage];        
        cellView.textField.stringValue = [NSString stringWithFormat:@" vs. %@", agame.opponent_mascot];
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"GameTimeColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"GameTimeTableCell" owner:self];
        cellView.textField.stringValue = agame.starttime;
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"LiveNowColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"LiveTableCell" owner:self];
        
        if ([agame isaLiveGame]) {
            [cellView.textField setTextColor:[NSColor redColor]];
            cellView.textField.stringValue = @"Live";
        } else {
            cellView.textField.stringValue = @"";
        }
        
        return cellView;
    } else { //if ([tableColumn.identifier isEqualToString:@"GameDateColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"GameDateTableCell" owner:self];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSDate *gamedate = [dateFormat dateFromString:agame.startdate];
        [dateFormat setDateFormat:@"MM-dd-yyyy"];
        cellView.textField.stringValue = [dateFormat stringFromDate:gamedate];
        return cellView;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return getGames.gameList.count;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    if ([_gamesTableView selectedRow] >= 0) {
        NSInteger gameselected = [_gamesTableView selectedRow];
        game = [getGames.gameList objectAtIndex:gameselected];
        [self.window close];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GameSelectedNotification" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

@end
