//
//  eazesportzLiveVideoViewController.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/18/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzLiveHighlightViewController.h"
#import "eazesportzSelectTeamWindowController.h"
#import "Team.h"
#import "GameSchedule.h"
#import "eazesportzAVClip.h"
#import "EazesportzRetrieveEvents.h"
#import "Event.h"
#import "eazesportzUploadHighlight.h"

#import <AWSiOSSDK/S3/S3Bucket.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>

@interface eazesportzLiveHighlightViewController ()

@property (nonatomic, strong) IBOutlet eazesportzSelectTeamWindowController *selectTeamController;

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
    EazesportzRetrieveEvents *getEvents;
    Event *event;
}

@synthesize user;
@synthesize sport;

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
    
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"BroadcastTestUrl"] length] == 0) {
        // Initialize the S3 Client.
        s3 = [[AmazonS3Client alloc] initWithAccessKey:user.awskeyid withSecretKey:user.awssecretkey];
    }
    
    clips = [[NSMutableArray alloc] init];
    startclip = NO;
    clipnumber = 0;
    _uploadButton.enabled = NO;
    filemgr = [NSFileManager defaultManager];
    documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _playerView.hidden = YES;
    [_eventendDatePicker setDateValue:[[NSDate alloc] init]];
    [_eventStartDatePicker setDateValue:[[NSDate alloc] init]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadResult:) name:@"ClipUploadNotification" object:nil];
}

- (IBAction)homeButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisplayMainViewController" object:nil
                                            userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"LiveView", @"Message", nil]];
}

- (IBAction)eventButtonClicked:(id)sender {
    if (team) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotEvents:) name:@"EventListChangedNotification" object:nil];
        getEvents = [[EazesportzRetrieveEvents alloc] init];
        getEvents.startdate = _eventStartDatePicker.dateValue;
        getEvents.enddate = _eventendDatePicker.dateValue;
        [getEvents retrieveEvents:sport Team:team Token:user];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Please select a team."];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (void)gotEvents:(NSNotification *)notification {
    if ([[[notification userInfo] valueForKey:@"Result"] isEqualToString:@"Success"]) {
        [_eventTableView reloadData];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Error retrieving events"];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
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
                _uploadButton.enabled = YES;

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
                _uploadButton.enabled = NO;

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
                        
                        if ((team) && (game)) {
                            _highlightNameTextField.stringValue = [NSString stringWithFormat:@"%@ - %d", [game vsOpponent], clipnumber];
                        } else {
                            _highlightNameTextField.stringValue = clipfile;
                        }
                        
                        if ([filemgr createDirectoryAtPath:highlightsPath withIntermediateDirectories:YES attributes:nil error:nil]) {
                            self.clipTask = [[NSTask alloc] init];
                            self.clipTask.launchPath = path;
                            NSMutableArray *arguments = [[NSMutableArray alloc] init];
                            NSString *playbackstring;
                            
                            if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"BroadcastTestUrl"] length] == 0)
                                playbackstring = [NSString stringWithFormat:@"%@/%@/%@.m3u8",
                                                            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"s3streamingurl"], event.event_id, team.teamid];
                            else {
                                NSString *testDirectory = [documentsPath stringByAppendingPathComponent:
                                                           [[NSBundle mainBundle] objectForInfoDictionaryKey:@"streamingdirectory"]];
                                playbackstring = [NSString stringWithFormat:@"%@/%@.m3u8", testDirectory, team.teamid];
                            }
                            
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
                                           otherButton:nil informativeTextWithFormat:@"Team and event must be selected to create clips."];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    Event *anevent = [getEvents.videoEventList objectAtIndex:row];
    // Get an existing cell with the MyView identifier if it exists
    
    if ([tableColumn.identifier isEqualToString:@"DateColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"DateTableCellView" owner:self];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        cellView.textField.stringValue = [dateFormat stringFromDate:anevent.startdate];
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"StartTimeColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"StartTimeTableCellView" owner:self];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
        timeFormatter.dateFormat = @"HH:mm";
        cellView.textField.stringValue = [timeFormatter stringFromDate:anevent.startdate];
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"StopTimeColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"StopTimeTableCellView" owner:self];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
        timeFormatter.dateFormat = @"HH:mm";
        cellView.textField.stringValue = [timeFormatter stringFromDate:anevent.enddate];
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"EventColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"EventTableCellView" owner:self];
        cellView.textField.stringValue = anevent.eventname;
        return cellView;
    } else {
        // if ([tableColumn.identifier isEqualToString:@"OpponentColumn"])
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"OpponnentTableCellView" owner:self];
        
        if (anevent.gameschedule_id.length > 0)
            cellView.textField.stringValue = [[anevent getGame:sport Team:team User:user] opponent_mascot];
        else
            cellView.textField.stringValue = @"";
        
        return cellView;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return getEvents.videoEventList.count;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    if ([_eventTableView selectedRow] >= 0) {
        NSInteger eventSelected = [_eventTableView selectedRow];
        event = [getEvents.videoEventList objectAtIndex:eventSelected];
        
        if (event) {
            if (event.gameschedule_id.length > 0)
                game = [event getGame:sport Team:team User:user];
            
            NSString *playbackstring = [NSString stringWithFormat:@"%@/%@/%@.m3u8",
                                        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"s3streamingurl"], event.event_id, team.teamid];
            playbackstring = [playbackstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            S3GetObjectRequest *getObjectRequest = [[S3GetObjectRequest alloc] initWithKey:playbackstring withBucket:bucket];
            
            if (getObjectRequest) {
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
        } else {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                               otherButton:nil informativeTextWithFormat:@"Event data is null."];
            [alert setIcon:[sport getImage:@"tiny"]];
            [alert runModal];
        }
    }
}

- (IBAction)uploadHighlighButtonClicked:(id)sender {
    eazesportzUploadHighlight *upload = [[eazesportzUploadHighlight alloc] init];
    upload.sport = sport;
    upload.team = team;
    upload.game = game;
    upload.user = user;
    upload.bucket = bucket;
    upload.s3 = s3;
    
    for (int i = 0; i < clips.count; i++) {
        if (![[[clips objectAtIndex:i] lastPathComponent] isEqualToString:[_uploadComboBox.objectValues objectAtIndex:i]]) {
            NSString *newpath = [[clips objectAtIndex:i] stringByDeletingLastPathComponent];
            newpath = [newpath stringByAppendingPathComponent:[_uploadComboBox.objectValues objectAtIndex:i]];
            
            if ([filemgr moveItemAtPath:[clips objectAtIndex:i] toPath:newpath error:nil]) {
                [clips replaceObjectAtIndex:i withObject:newpath];
             } else {
                NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                otherButton:nil informativeTextWithFormat:@"Error moving file. Did you name it the same as an already existing file?"];
                [alert setIcon:[sport getImage:@"tiny"]];
                [alert runModal];
                NSLog(@"Error moving file %@. Did you name it the same as an already existing file?", [clips objectAtIndex:i]);
            }
        }
        
        [upload uploadVideo:[clips objectAtIndex:i] Hidden:NO];
    }
}

- (void)uploadResult:(NSNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"Result"] isEqualToString:@"Success"]) {
        for (int i = 0; i < clips.count; i++) {
            if ([[clips objectAtIndex:i] isEqualToString:[[notification userInfo] objectForKey:@"clipname"]]) {
                [clips removeObjectAtIndex:i];
                [_uploadComboBox removeItemAtIndex:i];
                break;
            }
        }
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Fatal error uploading clip %@",
                                            [[notification userInfo] objectForKey:@"clipname"]];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

@end
