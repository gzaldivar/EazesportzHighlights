//
//  eazesportzScheduleBroadcastViewController.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/21/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzScheduleBroadcastViewController.h"
#import "eazesportzLiveVideoViewController.h"
#import "eazesportzSelectGameWindowController.h"
#import "eazesportzSelectTeamWindowController.h"
#import "eazesportzEditEventWindowController.h"
#import "EazesportzRetrieveEvents.h"
#import "Event.h"
#import "eazesportzGetGame.h"

@interface eazesportzScheduleBroadcastViewController ()

@property (nonatomic, strong) IBOutlet eazesportzSelectTeamWindowController *selectTeamController;
@property (nonatomic, strong) IBOutlet eazesportzEditEventWindowController *editEventController;

@end

@implementation eazesportzScheduleBroadcastViewController {
    BOOL broadcast;
    
    EazesportzRetrieveEvents *getEvents;
}

@synthesize sport;
@synthesize user;
@synthesize team;
@synthesize event;

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
    broadcast = NO;
    [_startDatePicker setDateValue:[[NSDate alloc] init]];
    [_endDatePicker setDateValue:[[NSDate alloc] init]];
    getEvents = [[EazesportzRetrieveEvents alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventsReceived:) name:@"EventListChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventSelected:) name:@"EventListUpdatedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addEvent:) name:@"EventAddedNotification" object:nil];
}

- (void)controlTextDidChange:(NSNotification *)notification {
 }

- (IBAction)homeButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisplayMainViewController" object:nil
                            userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"BroadcastView", @"Message", nil]];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)selectTeamButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(teamSelected:) name:@"TeamSelectedNotification" object:nil];
    self.selectTeamController = [[eazesportzSelectTeamWindowController alloc] initWithWindowNibName:@"eazesportzSelectTeamWindowController"];
    self.selectTeamController.sport = sport;
    self.selectTeamController.user = user;
    [self.selectTeamController showWindow:self];
}

- (void)teamSelected:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TeamSelectedNotification" object:nil];
    _teamLabel.stringValue = self.selectTeamController.team.team_name;
    team = self.selectTeamController.team;
}

- (IBAction)newScheduleButtonClicked:(id)sender {
    if (team) {
        [self editSchedule:nil];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil
                             informativeTextWithFormat:@"No team selected! You must select a team to schedule an event."];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (void)getEventsFromCloud {
    getEvents.startdate = _startDatePicker.dateValue;
    getEvents.enddate = _endDatePicker.dateValue;
    [getEvents retrieveEvents:sport Team:team Token:user];
}

- (void)addEvent:(NSNotification *)notification {
    [self getEventsFromCloud];
}

- (void)eventsReceived:(NSNotification *)notification {
    [_scheduleTableView reloadData];
    
    if (getEvents.videoEventList.count == 0) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM-dd-yyyy"];
        NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil otherButton:nil
                             informativeTextWithFormat:@"No events schedule for date range %@ - %@",
                                [dateFormat stringFromDate:_startDatePicker.dateValue], [dateFormat stringFromDate:_endDatePicker.dateValue]];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    Event *anevent = [getEvents.videoEventList objectAtIndex:row];
    // Get an existing cell with the MyView identifier if it exists

    if ([tableColumn.identifier isEqualToString:@"DateColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"DateTableCellView" owner:self];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM-dd-yyyy"];
        cellView.textField.stringValue = [dateFormat stringFromDate:anevent.startdate];
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"StartTimeColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"StartTimeTableCellView" owner:self];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
        timeFormatter.dateFormat = @"HH:mm:ss";
        cellView.textField.stringValue = [timeFormatter stringFromDate:anevent.startdate];
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"StopTimeColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"StopTimeTableCellView" owner:self];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
        timeFormatter.dateFormat = @"HH:mm:ss";
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
            cellView.textField.stringValue = [[anevent getGame:sport Team:team User:user] vsOpponent];
         else
            cellView.textField.stringValue = @"";
         
        return cellView;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return getEvents.videoEventList.count;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    if ([_scheduleTableView selectedRow] >= 0) {
        NSInteger eventSelected = [_scheduleTableView selectedRow];
        event = [getEvents.videoEventList objectAtIndex:eventSelected];
        
        if (broadcast) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LiveVideoViewNotification" object:nil
                                            userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"NotEvent", @"Message", event.eventurl, @"videourl", nil]];
//            [[NSNotificationCenter defaultCenter] removeObserver:self];
       } else {
            [self editSchedule:event];
        }
    }
}

- (IBAction)broadcastScheduleButtonClicked:(id)sender {
    if (broadcast) {
        [_broadcastScheduleButton setTitle:@"Edit"];
        broadcast = NO;
    } else {
        [_broadcastScheduleButton setTitle:@"Broadcast"];
        broadcast = YES;
    }
}

- (void)eventSelected:(NSNotification *)notification {
    [_scheduleTableView reloadData];
}

- (void)editSchedule:(Event *)anevent {
    self.editEventController = [[eazesportzEditEventWindowController alloc] initWithWindowNibName:@"eazesportzEditEventWindowController"];
    self.editEventController.sport = sport;
    self.editEventController.user = user;
    self.editEventController.team = team;
    self.editEventController.event = anevent;
    self.editEventController.getEvents = getEvents;
    [self.editEventController showWindow:self];
}

- (IBAction)searchEventsButtonClicked:(id)sender {
    if (([_startDatePicker.dateValue compare:_endDatePicker.dateValue] == NSOrderedAscending) && (team)) {
        [self getEventsFromCloud];
    } else if ([_startDatePicker.dateValue compare:_endDatePicker.dateValue] == NSOrderedDescending) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM-dd-yyyy"];
        NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil otherButton:nil
                             informativeTextWithFormat:@"Invalid date range %@ - %@",
                          [dateFormat stringFromDate:_startDatePicker.dateValue], [dateFormat stringFromDate:_endDatePicker.dateValue]];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil otherButton:nil
                             informativeTextWithFormat:@"Please select a team before searching for events!"];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

@end
