//
//  eazesportzBroadcastPreferencesWindowController.m
//  EazesportzHighlights
//
//  Created by Gil on 3/20/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzBroadcastPreferencesWindowController.h"

@interface eazesportzBroadcastPreferencesWindowController ()

@end

@implementation eazesportzBroadcastPreferencesWindowController

@synthesize sport;
@synthesize user;

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
    if ([sport.streamquality isEqualToString:@"Low"])
        [_qualityComboBox selectItemAtIndex:0];
    else if ([sport.streamquality isEqualToString:@"Medium"])
        [_qualityComboBox selectItemAtIndex:1];
    else if ([sport.streamquality isEqualToString:@"High"])
            [_qualityComboBox selectItemAtIndex:2];
    
    _allStreamsCheckBox.state = sport.allstreams;
}

- (IBAction)submitButtonClicked:(id)sender {
    sport.streamquality = _qualityComboBox.stringValue;
    sport.allstreams = _allStreamsCheckBox.state;
    if ([sport saveSport:user]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PreferencesChangedNotification" object:self];
        [self close];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Error saving preferences"];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

@end
