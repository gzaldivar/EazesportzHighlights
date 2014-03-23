//
//  eazesportzHighlightsPreferencesWindowController.m
//  EazesportzHighlights
//
//  Created by Gil on 3/17/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzHighlightsPreferencesWindowController.h"

@interface eazesportzHighlightsPreferencesWindowController ()

@end

@implementation eazesportzHighlightsPreferencesWindowController

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
    if ([sport.sdhdhighlights isEqualToString:@"SD"])
        [_qualityComboBox selectItemAtIndex:0];
    else if ([sport.sdhdhighlights isEqualToString:@"HD"])
        [_qualityComboBox selectItemAtIndex:1];
}

- (IBAction)submitButtonClicked:(id)sender {
    sport.sdhdhighlights = _qualityComboBox.stringValue;
    
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
