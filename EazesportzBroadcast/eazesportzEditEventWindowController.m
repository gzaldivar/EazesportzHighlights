//
//  eazesportzEditEventWindowController.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/26/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzEditEventWindowController.h"
#import "eazesportzSelectGameWindowController.h"
#import "eazesportzVideoFileWindowController.h"
#import "eazesportzGetGame.h"

@interface eazesportzEditEventWindowController ()

@property (nonatomic, strong) IBOutlet eazesportzSelectGameWindowController *selectGameController;
@property (nonatomic, strong) IBOutlet eazesportzVideoFileWindowController *selectVideoController;

@end

@implementation eazesportzEditEventWindowController {
    GameSchedule *game;
    NSURL *fileurl;
    
    eazesportzGetGame *getGame;
}

@synthesize team;
@synthesize sport;
@synthesize user;
@synthesize event;
@synthesize startdate;
@synthesize getEvents;

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
    _teamLabel.stringValue = team.team_name;
    
    if (event) {
        [_starttimeDatePicker setDateValue:event.startdate];
        [_stoptimeDatePicker setDateValue:event.enddate];
        _eventTitleTextField.stringValue = event.eventname;
        [_mediaRadioButton selectCellWithTag:[event.videoevent intValue]];
        _eventDescriptionTextView.string = event.eventdesc;
        
        if (event.gameschedule_id.length > 0) {
            getGame = [[eazesportzGetGame alloc] init];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameRetrieved:) name:@"GameRetrievedNotification" object:nil];
            [getGame retrieveGame:sport Team:team Game:event.gameschedule_id User:user];
        }
    } else {
        _deleteEventButton.enabled = NO;
        _deleteEventButton.hidden = YES;
        
        if (startdate) {
            [_starttimeDatePicker setDateValue:startdate];
            [_stoptimeDatePicker setDateValue:startdate];
        } else {
            [_starttimeDatePicker setDateValue:[[NSDate alloc] init]];
            [_stoptimeDatePicker setDateValue:[[NSDate alloc] init]];
        }
        event = [[Event alloc] init];
        event.videoevent = [NSNumber numberWithInt:0];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameSelected:) name:@"GameSelectedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDownloaded:) name:@"VideoDownloadedNotification" object:nil];
}

- (void)gameRetrieved:(NSNotification *)notification {
    game = getGame.game;
    _gameLabel.stringValue = [game vsOpponent];
}

- (IBAction)scheduleEventButtonClicked:(id)sender {
    event.startdate = _starttimeDatePicker.dateValue;
    event.enddate = _stoptimeDatePicker.dateValue;
    event.eventname = _eventTitleTextField.stringValue;
    event.eventdesc = _eventDescriptionTextView.string;

    if ([event saveEvent:sport Team:team Game:game User:user]) {
        _deleteEventButton.enabled = YES;
        _deleteEventButton.hidden = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EventAddedNotification" object:nil];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM-dd-yyyy"];
        NSAlert *alert = [NSAlert alertWithMessageText:@"Success!" defaultButton:@"OK" alternateButton:nil
                                otherButton:nil informativeTextWithFormat:@"Event %@ added for date %@", event.eventname,
                          [dateFormat stringFromDate:event.startdate]];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Error adding event!"];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
//    [self.window close];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.window close];
}

- (IBAction)deleteEventButtonClicked:(id)sender {
    if (event) {
        if ([event deleteEvent:user]) {
            [getEvents.videoEventList removeObject:event];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EventAddedNotification" object:nil];
            [self.window close];
        }
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"No event to delete!"];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (IBAction)selectGameButtonClicked:(id)sender {
    if (team) {
        self.selectGameController = [[eazesportzSelectGameWindowController alloc] initWithWindowNibName:@"eazesportzSelectGameWindowController"];        
        self.selectGameController.sport = sport;
        self.selectGameController.user = user;
        self.selectGameController.team = team;
        [self.selectGameController showWindow:self];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Please select a team."];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (void)gameSelected:(NSNotification *)notification {
    _gameLabel.stringValue = [self.selectGameController.game vsOpponent];
    game = self.selectGameController.game;
    [_starttimeDatePicker setDateValue:game.gamedatetime];
}

- (IBAction)openfileButtonClicked:(id)sender {
    // Create a File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Set array of file types
    NSArray *fileTypesArray;
    fileTypesArray = [NSArray arrayWithObjects:@"mts", @"mp4", @"mpeg", @"mov", nil];
    
    // Enable options in the dialog.
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowedFileTypes:fileTypesArray];
    [openDlg setAllowsMultipleSelection:NO];
    
    // Display the dialog box.  If the OK pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton ) {
        // Gets list of all files selected
        NSArray *files = [openDlg URLs];
        [openDlg close];
        fileurl = [files objectAtIndex:0];
        _eventTitleTextField.stringValue = [fileurl path];
        event.eventurl = _eventTitleTextField.stringValue;
    } else {
        fileurl = nil;
    }
}

- (IBAction)mediaRadioButtonClicked:(id)sender {
    NSInteger tag = [[sender selectedCell] tag];
    switch ( tag ) {
        case 1:
            event.videoevent = [NSNumber numberWithInt:1];
            break;
        case 2:
            event.videoevent = [NSNumber numberWithInt:2];
            [self openfileButtonClicked:self];
            break;
            
        case 3:
            event.videoevent = [NSNumber numberWithInt:3];
            self.selectVideoController = [[eazesportzVideoFileWindowController alloc] initWithWindowNibName:@"eazesportzVideoFileWindowController"];
            self.selectVideoController.sport = sport;
            self.selectVideoController.user = user;
            self.selectVideoController.team = team;
            self.selectVideoController.game = game;
            self.selectVideoController.event = event;
            [self.selectVideoController showWindow:self];
    }
}

- (void)videoDownloaded:(NSNotification *)notification {
    _eventTitleTextField.stringValue = event.eventurl;
}

@end
