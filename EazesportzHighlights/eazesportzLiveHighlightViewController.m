//
//  eazesportzLiveVideoViewController.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/18/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzLiveHighlightViewController.h"
#import "eazesportzSelectTeamWindowController.h"
#import "GameSchedule.h"
#import "eazesportzAVClip.h"
#import "EazesportzRetrieveEvents.h"
#import "eazesportzEditHighlightWindowController.h"
#import "eazesportzUploadHighlight.h"
#import "eazesportzAppDelegate.h"

#import <AWSiOSSDK/S3/S3Bucket.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>

@interface eazesportzLiveHighlightViewController () <NSAlertDelegate>

@property (nonatomic, strong) IBOutlet eazesportzSelectTeamWindowController *selectTeamController;
@property (nonatomic, strong) IBOutlet eazesportzEditHighlightWindowController *editHighlightController;

@end

@implementation eazesportzLiveHighlightViewController {
    AmazonS3Client *s3;
    NSString *bucket;
    NSString *videoname;
//    __block BOOL broadcasting;
    BOOL startclip;
    AVPlayerItem *playerItem;
    NSURL *videoUrl;
    long selectedItem;
    int clipnumber;
    NSMutableArray *clips;
    
    NSFileManager *filemgr;
    NSString *documentsPath;
    
    GameSchedule *game;
    EazesportzRetrieveEvents *getEvents;
    eazesportzAppDelegate *appDelegate;
    NSMutableArray *videos;
}

@synthesize user;
@synthesize sport;
@synthesize team;
@synthesize event;
@synthesize getPlayers;

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
    videos = [[NSMutableArray alloc] init];
    bucket = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"s3bucket"];
    appDelegate = (eazesportzAppDelegate *)[[NSApplication sharedApplication] delegate];
    
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"BroadcastTestUrl"] length] == 0) {
        // Initialize the S3 Client.
        s3 = [[AmazonS3Client alloc] initWithAccessKey:user.awskeyid withSecretKey:user.awssecretkey];
    }
    
    clips = [[NSMutableArray alloc] init];
    startclip = NO;
    clipnumber = 0;
    filemgr = [NSFileManager defaultManager];
    documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _playerView.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadResult:) name:@"VideoUploadCompletedNotification" object:nil];
    videoname = team.teamid;

    if (event.gameschedule_id.length > 0)
        game = [event getGame:sport Team:team User:user];
    
    NSString *playbackstring = [NSString stringWithFormat:@"%@/%@/%@.m3u8", sport.streamingurl, event.event_id, team.teamid];
    playbackstring = [playbackstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *key = [NSString stringWithFormat:@"%@/%@", event.event_id, [playbackstring lastPathComponent]];

    S3GetObjectMetadataRequest *getMetadataRequest = [[S3GetObjectMetadataRequest alloc] initWithKey:key withBucket:sport.streamingbucket];
    S3GetObjectMetadataResponse *getMetadataResponse = [s3 getObjectMetadata:getMetadataRequest];
    
    if (getMetadataResponse.lastModified) {
        NSURL *playbackurl = [NSURL URLWithString:playbackstring];
        NSLog(@"%@", playbackurl);
        AVAsset *asset = [AVAsset assetWithURL:playbackurl];
        playerItem = [AVPlayerItem playerItemWithAsset:asset];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
        [_playerView setPlayer:player];
        [_playerView.player play];
        _playerView.hidden = NO;
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Broadcast has not started. Please contact broadcastor."];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (IBAction)homeButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisplayMainViewController" object:nil
                                            userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"LiveView", @"Message", nil]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)cleanupDirectories {
    NSString *streamingPath = [documentsPath stringByAppendingPathComponent:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"streamingdirectory"]];
    [filemgr removeItemAtPath:streamingPath error:nil];
}

- (IBAction)clipButtonClicked:(id)sender {
    if ((team) && (event)) {
        __block NSFileHandle *writer;
        __block NSString *clipfile;

        if (event) {
            NSString *highlightsPath = [documentsPath stringByAppendingPathComponent:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"highlightsdirectory"]];
            _highlightsDir.stringValue = highlightsPath;
            
            if (startclip) {
                startclip = NO;

//                [writer writeData:[@"q" dataUsingEncoding:NSUTF8StringEncoding]];
                clipnumber++;
                [_clipButton setTitle:@"Start Clip Recording"];
                [_clipTask terminate];
                
                if ([filemgr fileExistsAtPath:clipfile] == YES) {
                    [clips addObject:clipfile];
                    [_uploadComboBox addItemWithObjectValue:[clipfile lastPathComponent]];
                }
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
                        NSString *path  = [NSString stringWithFormat:@"%@",
                                           [[NSBundle mainBundle] pathForResource:@"HighlightScript" ofType:@"command"]];
                        clipfile = [highlightsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d.mp4", videoname, clipnumber]];
                        
/*                        if ((team) && (game)) {
                            _highlightNameTextField.stringValue = [NSString stringWithFormat:@"%@ - %d", [game vsOpponent], clipnumber];
                        } else {
                            _highlightNameTextField.stringValue = clipfile;
                        }
*/
                        if ([filemgr createDirectoryAtPath:highlightsPath withIntermediateDirectories:YES attributes:nil error:nil]) {
                            self.clipTask = [[NSTask alloc] init];
                            self.clipTask.launchPath = path;
                            NSMutableArray *arguments = [[NSMutableArray alloc] init];
                            NSString *playbackstring;
                            
                            if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"BroadcastTestUrl"] length] == 0)
                                playbackstring = [NSString stringWithFormat:@"%@/%@/%@.m3u8", sport.streamingurl, event.event_id, team.teamid];
                            else {
                                NSString *testDirectory = [documentsPath stringByAppendingPathComponent:
                                                           [[NSBundle mainBundle] objectForInfoDictionaryKey:@"streamingdirectory"]];
                                playbackstring = [NSString stringWithFormat:@"%@/%@.m3u8", testDirectory, team.teamid];
                            }
                            
                            [arguments addObject:playbackstring];
                            [arguments addObject:clipfile];
                            [arguments addObject:[NSString stringWithFormat:@"%@/Contents/Resources/ffmpeg", [[NSBundle mainBundle] bundlePath]]];
                            self.clipTask.arguments = arguments;
                            
                            NSPipe *writePipe = [NSPipe pipe];
                            writer = [writePipe fileHandleForWriting];
                            
                            [self.clipTask setStandardInput: writePipe];
                            
                            [self.clipTask launch];
                            
                            [self.clipTask waitUntilExit];
                            int status = [self.clipTask terminationStatus];
                            [file closeFile];
                            Video *avideo = [[Video alloc] init];
                            avideo.displayName = [clipfile lastPathComponent];
                            AVURLAsset* asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:clipfile] options:nil];
                            CMTime duration = asset.duration;
                            avideo.duration = [NSNumber numberWithFloat:CMTimeGetSeconds(duration)];
                            [videos addObject:avideo];
                            [clips addObject:clipfile];
                            [_uploadComboBox reloadData];
                            
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
                                           otherButton:nil informativeTextWithFormat:@"Team and event must be selected to create clips."];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (void)uploadResult:(NSNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"Result"] isEqualToString:@"Success"]) {
        int clipindex = [[[notification userInfo] objectForKey:@"clipindex"] intValue];
        [clips removeObjectAtIndex:clipindex];
        [videos removeObjectAtIndex:clipindex];
        _uploadComboBox.stringValue = @"";
        [_uploadComboBox reloadData];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Fatal error uploading clip %@",
                                            [[notification userInfo] objectForKey:@"clipname"]];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    return videos.count;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
//    return [clips objectAtIndex:index];
    return [[videos objectAtIndex:index] displayName];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    if (videos.count > 0 ) {
        NSLog(@"[%@ %@] value == %@", NSStringFromClass([self class]),
              NSStringFromSelector(_cmd), [clips objectAtIndex:
                                           [(NSComboBox *)[notification object] indexOfSelectedItem]]);
        selectedItem = [(NSComboBox *)[notification object] indexOfSelectedItem];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Edit"];
        [alert addButtonWithTitle:@"Delete"];
        [alert addButtonWithTitle:@"Upload"];
        [alert setMessageText:@"Video Clip"];
        [alert setInformativeText:[NSString stringWithFormat:@"Clip - %@", [[videos objectAtIndex:selectedItem] displayName]]];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert beginSheetModalForWindow:appDelegate.window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSAlertFirstButtonReturn) {
		// Do something
        self.editHighlightController = [[eazesportzEditHighlightWindowController alloc] initWithWindowNibName:@"eazesportzEditHighlightWindowController"];
        self.editHighlightController.sport = sport;
        self.editHighlightController.user = user;
        self.editHighlightController.team = team;
        self.editHighlightController.game = game;
        self.editHighlightController.getPlayers = getPlayers;
        self.editHighlightController.clipname = [[clips objectAtIndex:selectedItem] lastPathComponent];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(highlightUpdated:) name:@"HighlightsDataUpdtedNotification" object:nil];
        [self.editHighlightController showWindow:self];
	} else if (returnCode == NSAlertSecondButtonReturn) {
        [filemgr removeItemAtPath:[clips objectAtIndex:selectedItem] error:nil];
        [clips removeObjectAtIndex:selectedItem];
        [videos removeObjectAtIndex:selectedItem];
        [_uploadComboBox reloadData];
    } else {
        eazesportzUploadHighlight *upload = [[eazesportzUploadHighlight alloc] init];
        upload.sport = sport;
        upload.team = team;
        upload.game = game;
        upload.user = user;
        upload.bucket = bucket;
        upload.s3 = s3;
        upload.clipindex = (int)selectedItem;
        [upload uploadVideo:[clips objectAtIndex:selectedItem] Video:[videos objectAtIndex:selectedItem] Hidden:NO];
    }
}

- (void)highlightUpdated:(NSNotification *)notification {
    _uploadComboBox.stringValue = @"";
    Video *video = [videos objectAtIndex:selectedItem];
    video.displayName = self.editHighlightController.highlightNameTextField.stringValue;
    video.description = self.editHighlightController.highlightsDescription.stringValue;
    video.players = self.editHighlightController.players;
    video.gamelog = self.editHighlightController.gamelog.gamelogid;
    
    if (self.editHighlightController.game.id.length > 0)
        video.schedule = self.editHighlightController.game.id;
    
    video.teamid = team.teamid;
    [_uploadComboBox reloadData];
}

@end
