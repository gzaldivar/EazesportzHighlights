//
//  eazesportzMainViewController.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/18/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Sport.h"

@interface eazesportzMainViewController : NSViewController

@property (nonatomic, strong) Sport *sport;

@property (weak) IBOutlet NSImageView *logoImage;
@property (weak) IBOutlet NSTextField *sportLabel;
- (IBAction)processVideoButtonClicked:(id)sender;
- (IBAction)createLiveHighlightsButtonClicked:(id)sender;

@end
