//
//  eazesportzSelectLiveHighlightsViewController.h
//  EazesportzHighlights
//
//  Created by Gil on 3/7/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Sport.h"
#import "User.h"

@interface eazesportzSelectLiveHighlightsViewController : NSViewController

@property (nonatomic, strong) Sport *sport;
@property (nonatomic, strong) User *user;

@property (weak) IBOutlet NSTextField *teamLabel;
@property (weak) IBOutlet NSTextField *eventLabel;

- (IBAction)homeButtonClicked:(id)sender;
- (IBAction)eventButtonClicked:(id)sender;
- (IBAction)teamButtonClicked:(id)sender;

@property (weak) IBOutlet NSDatePicker *eventStartDatePicker;
@property (weak) IBOutlet NSDatePicker *eventendDatePicker;
@property (weak) IBOutlet NSTableView *eventTableView;

@end
