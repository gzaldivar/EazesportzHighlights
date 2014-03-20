//
//  eazesportzBroadcastPreferencesWindowController.h
//  EazesportzHighlights
//
//  Created by Gil on 3/20/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Sport.h"
#import "User.h"

@interface eazesportzBroadcastPreferencesWindowController : NSWindowController

@property (weak) IBOutlet NSComboBox *qualityComboBox;
@property (weak) IBOutlet NSButton *allStreamsCheckBox;

@property (nonatomic, strong) Sport *sport;
@property (nonatomic, strong) User *user;

- (IBAction)submitButtonClicked:(id)sender;
@end
