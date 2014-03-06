//
//  eazesportzLiveVideoViewController.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/18/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzLiveHighlightViewController.h"
#import "eazesportzSelectGameWindowController.h"
#import "eazesportzSelectTeamWindowController.h"
#import "Team.h"
#import "GameSchedule.h"
#import "eazesportzAVClip.h"

#import <AWSiOSSDK/S3/S3Bucket.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>

@interface eazesportzLiveHighlightViewController ()

@property (nonatomic, assign) BOOL IsBroadcasting;

@property (nonatomic, strong) IBOutlet eazesportzSelectTeamWindowController *selectTeamController;
@property (nonatomic, strong) IBOutlet eazesportzSelectGameWindowController *selectGameController;

@end

@implementation eazesportzLiveHighlightViewController {
    AmazonS3Client *s3;
    NSString *bucket;
    NSString *videoname;
//    __block BOOL broadcasting;
    BOOL startclip;
    AVPlayerItem *playerItem;
    NSURL *videoUrl;
    
    int clipnumber;
    NSMutableArray *clips;
    
    NSFileManager *filemgr;
    NSString *documentsPath;
    
    GameSchedule *game;
    Team *team;
}

@synthesize user;
@synthesize sport;
@synthesize event;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        [self.playerView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    bucket = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"s3streamingbucket"];
    // Initialize the S3 Client.
    s3 = [[AmazonS3Client alloc] initWithAccessKey:user.awskeyid withSecretKey:user.awssecretkey];
    self.IsBroadcasting = NO;
    clips = [[NSMutableArray alloc] init];
    startclip = NO;
    clipnumber = 0;
    _highlightsDir.hidden = YES;
    filemgr = [NSFileManager defaultManager];
    documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

- (IBAction)homeButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisplayMainViewController" object:nil
                                            userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"LiveView", @"Message", nil]];
}

- (IBAction)gameButtonClicked:(id)sender {
    if (team) {
        self.selectGameController = [[eazesportzSelectGameWindowController alloc] initWithWindowNibName:@"eazesportzSelectGameWindowController"];
        self.selectGameController.sport = sport;
        self.selectGameController.user = user;
        self.selectGameController.team = team;
        [self.selectGameController showWindow:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameSelected:) name:@"GameSelectedNotification" object:nil];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Please select a team."];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (void)gameSelected:(NSNotification *)notification {
    game = self.selectGameController.game;
    _gameLabel.stringValue = [game vsOpponent];
    [self.selectGameController close];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
//    _sportNameLabel.stringValue = [NSString stringWithFormat:@"%@%@%@", sport.sitename, @" - ", self.selectTeamController.team.team_name];
    team = self.selectTeamController.team;
    _teamLabel.stringValue = team.team_name;
    videoname = team.teamid;
    [self.selectTeamController close];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)cleanupDirectories {
    NSString *streamingPath = [documentsPath stringByAppendingPathComponent:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"streamingdirectory"]];
    [filemgr removeItemAtPath:streamingPath error:nil];
}

- (IBAction)clipButtonClicked:(id)sender {
    if ((team) && (game)) {
        __block NSFileHandle *writer;

        if (self.IsBroadcasting) {
            _highlightsDir.hidden = NO;
            NSString *highlightsPath = [documentsPath stringByAppendingPathComponent:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"highlightsdirectory"]];
            _highlightsDir.stringValue = highlightsPath;
            
            if (startclip) {
                startclip = NO;
                [writer writeData:[@"q" dataUsingEncoding:NSUTF8StringEncoding]];
                clipnumber++;
                [_clipButton setTitle:@"Start Clip Recording"];
            } else {
                startclip = YES;
                [_clipButton setTitle:@"Stop Clip Recording"];
                NSString *filePath = [documentsPath stringByAppendingPathComponent:@"createclip-errors.txt"];
                
                if (![filemgr fileExistsAtPath:filePath] == YES)
                    [filemgr createFileAtPath:filePath contents:nil attributes:nil];
                
                NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:filePath];
                
                if (file == nil)
                    NSLog(@"Failed to open file");
                
                dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
                dispatch_async(taskQueue, ^{
                    
                    @try {
                        NSString *path  = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"HighlightScript" ofType:@"command"]];
                        NSString *clipfile = [highlightsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.mp4", videoname, clipnumber]];
                        
                        if ([filemgr createDirectoryAtPath:highlightsPath withIntermediateDirectories:YES attributes:nil error:nil]) {
                            self.clipTask = [[NSTask alloc] init];
                            self.clipTask.launchPath = path;
                            NSMutableArray *arguments = [[NSMutableArray alloc] init];
                            NSString *playbackstring = [NSString stringWithFormat:@"%@/%@/%@.m3u8",
                                                        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"s3streamingurl"], event.event_id, team.teamid];
                            [arguments addObject:playbackstring];
                            [arguments addObject:clipfile];
                            self.clipTask.arguments = arguments;
                            
                            NSPipe *writePipe = [NSPipe pipe];
                            writer = [writePipe fileHandleForWriting];
                            
                            [self.clipTask setStandardInput: writePipe];
                            
                            [self.clipTask launch];
                            
                            [self.clipTask waitUntilExit];
                            int status = [self.clipTask terminationStatus];
                            [file closeFile];
                            
                            if (status != 0) {
                                NSLog(@"Clip Error = %d", status);
                            }
                        }
                    }
                    @catch (NSException *exception) {
                        NSLog(@"Problem Running Task: %@", [exception description]);
                    }
                    @finally {
                    }
                });
            }
        } else {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil
                                               otherButton:nil informativeTextWithFormat:@"Please start a broadcast to create clips."];
            [alert setIcon:[sport getImage:@"tiny"]];
            [alert runModal];
        }
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Team and game must be selected to create clips."];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

@end
