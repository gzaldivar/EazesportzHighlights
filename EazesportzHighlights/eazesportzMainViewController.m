//
//  eazesportzMainViewController.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/18/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzMainViewController.h"

@interface eazesportzMainViewController ()

@end

@implementation eazesportzMainViewController

@synthesize sport;

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
    
    _sportLabel.stringValue = sport.sitename;
    _logoImage.image = [sport getImage:@"thumb"];
}

- (IBAction)processVideoButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisplayProcessVideoNotification" object:nil];
}

- (IBAction)createLiveHighlightsButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateLiveHighlightsNotification" object:nil];
}

@end
