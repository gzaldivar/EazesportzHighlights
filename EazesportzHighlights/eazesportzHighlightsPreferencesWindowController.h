//
//  eazesportzHighlightsPreferencesWindowController.h
//  EazesportzHighlights
//
//  Created by Gil on 3/17/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Sport.h"
#import "User.h"

@interface eazesportzHighlightsPreferencesWindowController : NSWindowController

@property (weak) IBOutlet NSComboBox *qualityComboBox;

@property (nonatomic, strong) Sport *sport;
@property (nonatomic, strong) User *user;

- (IBAction)submitButtonClicked:(id)sender;

@end
