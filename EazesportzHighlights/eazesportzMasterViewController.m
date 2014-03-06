//
//  eazesportzMasterViewController.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 1/31/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzMasterViewController.h"
#import "eazesportzPlayerViewController.h"
#import "eazesportzSelectTeamWindowController.h"
#import "eazesportzSelectGameWindowController.h"
#import "eazesportzVideoFileWindowController.h"

#import <DVDPlayback/DVDPlayback.h>

@interface eazesportzMasterViewController ()

@property (nonatomic, strong) IBOutlet eazesportzSelectTeamWindowController *selectTeamController;
@property (nonatomic, strong) IBOutlet eazesportzSelectGameWindowController *selectGameController;
@property (nonatomic, strong) IBOutlet eazesportzVideoFileWindowController *selectVideoController;

@end

@implementation eazesportzMasterViewController {
    BOOL dvdPlayer;
}

@synthesize sport;
@synthesize user;
@synthesize videoUrl;
@synthesize game;
@synthesize team;

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
    
    _sportNameLabel.stringValue = sport.sitename;
    _homeTeamImage.image = [sport getImage:@"tiny"];
    [_highlightDate setDateValue:[[NSDate alloc] init]];
    
//    OSStatus err = DVDInitialize();
    
//    if (err != noErr) {
        dvdPlayer = NO;
//    }
}

- (IBAction)teamButtonClicked:(id)sender {
    self.selectTeamController = [[eazesportzSelectTeamWindowController alloc] initWithWindowNibName:@"eazesportzSelectTeamWindowController"];
    self.selectTeamController.sport = sport;
    self.selectTeamController.user = user;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(teamSelected:) name:@"TeamSelectedNotification"
                                               object:nil];
    [self.selectTeamController showWindow:self];
}

- (void)teamSelected:(NSNotification *)notification {
    _sportNameLabel.stringValue = [NSString stringWithFormat:@"%@%@%@", sport.sitename, @" - ", self.selectTeamController.team.team_name];
    team = self.selectTeamController.team;
    _teamLabel.stringValue = team.team_name;
    [self.selectTeamController close];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)videoSegmentControlClicked:(id)sender {
    if (game) {
        
        switch (_videoTypeSegmentedControl.selectedSegment) {
            case 0:
                break;
                
            case 1:
/*
                if (dvdPlayer) {
                    [self onOpenMediaFolder:self];
                } else {
                    NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil
                                                       otherButton:nil informativeTextWithFormat:@"No DVD Player"];
                    [alert setIcon:[sport getImage:@"tiny"]];
                    [alert runModal];
                }
 */
                break;
               
            default:
                break;
        }
        
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Select Game to Process Video"];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (IBAction) onOpenMediaFolder:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    
    if ([panel runModal] == NSOKButton) {
        NSString *folderPath = [[panel URLs] objectAtIndex:0]; // 3
        const char *cPath = [folderPath cStringUsingEncoding:NSASCIIStringEncoding]; // 4
        FSRef fileRef;
        OSStatus err = FSPathMakeRef ((UInt8*)cPath, &fileRef, NULL); // 5
        [self openMedia:&fileRef isVolume:NO]; // 6
    }
}

- (BOOL) openMedia:(FSRef *)media isVolume:(BOOL)isVolume {
    Boolean isValid;
    OSStatus err = DVDIsValidMediaRef (media, &isValid);
    
    if (isValid) {
        if ([self hasMedia] == YES) {
//            [self closeMedia];
        }
        
        if (isVolume) {
            err = DVDOpenMediaVolume (media);
        }
        else {
            err = DVDOpenMediaFile (media);
        }
    }
    return isValid;
}

- (BOOL)hasMedia {
    return YES;
}

- (void) handleDVDError:(DVDErrorCode)error {
    NSLog(@"fatal error %d", error);
    [NSApp terminate:self];
}

//-----------------
//NSOpenPanel: Displaying a File Open Dialog in OS X 10.7
//-----------------
// Any ole method
- (NSURL *)importVideoFile {
    
    // Loop counter.
//    int i;
    
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
        return  [files objectAtIndex:0];
    } else {
        return  nil;
    }
}

- (IBAction)homeButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisplayMainViewController" object:nil
                                userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"SelectOpponentView", @"Message", nil]];
}

- (IBAction)processVideoButtonClicked:(id)sender {
    videoUrl = [self importVideoFile];
    if ((videoUrl) && (team)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerReadyNotification" object:nil];
    } else if (!team) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Team required, Try again?"];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"No video selected, Try again?"];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (IBAction)gameButtonClicked:(id)sender {
    if (team) {
        self.selectGameController = [[eazesportzSelectGameWindowController alloc]
                                     initWithWindowNibName:@"eazesportzSelectGameWindowController"];
        self.selectGameController.sport = sport;
        self.selectGameController.user = user;
        self.selectGameController.team = team;
        [self.selectGameController showWindow:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameSelected:) name:@"GameSelectedNotification"
                                                   object:nil];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Please select a team."];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (void)gameSelected:(NSNotification *)notification {
    game = self.selectGameController.game;
    _gameLabel.stringValue = game.opponent_name;
    [self.selectGameController close];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)downloadFileButtonClicked:(id)sender {
    if (team) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDownloaded:) name:@"VideoDownloadedNotification" object:nil];
        self.selectVideoController = [[eazesportzVideoFileWindowController alloc] initWithWindowNibName:@"eazesportzVideoFileWindowController"];
        self.selectVideoController.sport = sport;
        self.selectVideoController.user = user;
        self.selectVideoController.team = team;
        self.selectVideoController.game = game;
        self.selectVideoController.event = [[Event alloc] init];
        [self.selectVideoController showWindow:self];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Please select a team."];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (void)videoDownloaded:(NSNotification *)notification {
    videoUrl = [NSURL fileURLWithPath:self.selectVideoController.event.eventurl];
    
    if (videoUrl) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerReadyNotification" object:nil];
    }
}

@end
