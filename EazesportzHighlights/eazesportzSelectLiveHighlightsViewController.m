//
//  eazesportzSelectLiveHighlightsViewController.m
//  EazesportzHighlights
//
//  Created by Gil on 3/7/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzSelectLiveHighlightsViewController.h"
#import "EazesportzRetrieveEvents.h"
#import "eazesportzSelectTeamWindowController.h"

#import "Event.h"
#import "GameSchedule.h"

@interface eazesportzSelectLiveHighlightsViewController ()

@property (nonatomic, strong) IBOutlet eazesportzSelectTeamWindowController *selectTeamController;

@end

@implementation eazesportzSelectLiveHighlightsViewController {
    EazesportzRetrieveEvents *getEvents;
    GameSchedule *game;
}

@synthesize sport;
@synthesize team;
@synthesize user;
@synthesize event;
@synthesize getPlayers;

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
    [_eventendDatePicker setDateValue:[[NSDate alloc] init]];
    [_eventStartDatePicker setDateValue:[[NSDate alloc] init]];
    getPlayers = [[EazesportzRetrievePlayers alloc] init];

}

- (IBAction)homeButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisplayMainViewController" object:nil
                                                      userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"SelectHighlightView", @"Message", nil]];
}

- (IBAction)eventButtonClicked:(id)sender {
    if (team) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotEvents:) name:@"EventListChangedNotification" object:nil];
        getEvents = [[EazesportzRetrieveEvents alloc] init];
        getEvents.startdate = _eventStartDatePicker.dateValue;
        getEvents.enddate = _eventendDatePicker.dateValue;
        [getEvents retrieveEvents:sport Team:team Token:user];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Please select a team."];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (void)gotEvents:(NSNotification *)notification {
    if ([[[notification userInfo] valueForKey:@"Result"] isEqualToString:@"Success"]) {
        if (getEvents.eventlist.count > 0)
            [_eventTableView reloadData];
        else {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                               otherButton:nil informativeTextWithFormat:@"No events match date range!"];
            [alert setIcon:[sport getImage:@"tiny"]];
            [alert runModal];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EventListChangedNotification" object:nil];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Error retrieving events"];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (IBAction)teamButtonClicked:(id)sender {
    self.selectTeamController = [[eazesportzSelectTeamWindowController alloc] initWithWindowNibName:@"eazesportzSelectTeamWindowController"];
    self.selectTeamController.sport = sport;
    self.selectTeamController.user = user;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(teamSelected:) name:@"TeamSelectedNotification" object:nil];
    [self.selectTeamController showWindow:self];
}

- (void)teamSelected:(NSNotification *)notification {
    //    _sportNameLabel.stringValue = [NSString stringWithFormat:@"%@%@%@", sport.sitename, @" - ", self.selectTeamController.team.team_name];
    team = self.selectTeamController.team;
    _teamLabel.stringValue = team.team_name;
    [_activityIndicator startAnimation:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TeamSelectedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotPlayers:) name:@"RosterChangedNotification" object:nil];
    [getPlayers retrievePlayers:sport Team:team User:user];
}

- (void)gotPlayers:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RosterChangedNotification" object:nil];
    [_activityIndicator stopAnimation:self];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    Event *anevent = [getEvents.videoEventList objectAtIndex:row];
    // Get an existing cell with the MyView identifier if it exists
    
    if ([tableColumn.identifier isEqualToString:@"DateColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"DateTableCellView" owner:self];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        cellView.textField.stringValue = [dateFormat stringFromDate:anevent.startdate];
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"StartTimeColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"StartTimeTableCellView" owner:self];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
        timeFormatter.dateFormat = @"HH:mm";
        cellView.textField.stringValue = [timeFormatter stringFromDate:anevent.startdate];
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"StopTimeColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"StopTimeTableCellView" owner:self];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
        timeFormatter.dateFormat = @"HH:mm";
        cellView.textField.stringValue = [timeFormatter stringFromDate:anevent.enddate];
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"EventColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"EventTableCellView" owner:self];
        cellView.textField.stringValue = anevent.eventname;
        return cellView;
    } else {
        // if ([tableColumn.identifier isEqualToString:@"OpponentColumn"])
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"OpponnentTableCellView" owner:self];
        
        if (anevent.gameschedule_id.length > 0)
            cellView.textField.stringValue = [[anevent getGame:sport Team:team User:user] opponent_mascot];
        else
            cellView.textField.stringValue = @"";
        
        return cellView;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return getEvents.videoEventList.count;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    if ([_eventTableView selectedRow] >= 0) {
        NSInteger eventSelected = [_eventTableView selectedRow];
        event = [getEvents.videoEventList objectAtIndex:eventSelected];
        
        if (event) {
            if (event.gameschedule_id.length > 0)
                game = [event getGame:sport Team:team User:user];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DisplayLiveHighlightsNotification" object:nil];
        } else {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                               otherButton:nil informativeTextWithFormat:@"Event data is null."];
            [alert setIcon:[sport getImage:@"tiny"]];
            [alert runModal];
        }
    }
}

@end
