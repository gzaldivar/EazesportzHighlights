//
//  eazesportzEditEventWindowController.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/26/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Team.h"
#import "Sport.h"
#import "User.h"
#import "Event.h"
#import "EazesportzRetrieveEvents.h"

@interface eazesportzEditEventWindowController : NSWindowController

@property (weak) IBOutlet NSTextField *eventTitleTextField;

- (IBAction)selectGameButtonClicked:(id)sender;
@property (weak) IBOutlet NSTextField *teamLabel;
@property (weak) IBOutlet NSTextField *gameLabel;
- (IBAction)scheduleEventButtonClicked:(id)sender;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)deleteEventButtonClicked:(id)sender;
@property (weak) IBOutlet NSButton *deleteEventButton;

@property (nonatomic, strong) Team *team;
@property (nonatomic, strong) Sport *sport;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) EazesportzRetrieveEvents *getEvents;

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSDate *startdate;
@property (weak) IBOutlet NSDatePicker *starttimeDatePicker;
@property (weak) IBOutlet NSDatePicker *stoptimeDatePicker;
@property (weak) IBOutlet NSMatrix *mediaRadioButton;
- (IBAction)mediaRadioButtonClicked:(id)sender;
@property (unsafe_unretained) IBOutlet NSTextView *eventDescriptionTextView;

@end
