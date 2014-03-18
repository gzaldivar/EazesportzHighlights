//
//  eazesportzLiveVideoViewController.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/18/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzLiveVideoViewController.h"
#import "eazesportzSelectGameWindowController.h"
#import "eazesportzSelectTeamWindowController.h"
#import "Team.h"
#import "GameSchedule.h"
#import "eazesportzAVClip.h"

#import <AWSiOSSDK/S3/S3Bucket.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>

@interface eazesportzLiveVideoViewController ()

@property (nonatomic, assign) BOOL IsBroadcasting;

@property (nonatomic, strong) IBOutlet eazesportzSelectTeamWindowController *selectTeamController;
@property (nonatomic, strong) IBOutlet eazesportzSelectGameWindowController *selectGameController;

@end

@implementation eazesportzLiveVideoViewController {
    AmazonS3Client *s3;
    NSString *bucket;
    NSString *videoname;
    BOOL startclip;
    AVPlayerItem *playerItem;
    NSURL *videoUrl;
    
    int clipnumber;
    NSMutableArray *clips;
    
    NSFileManager *filemgr;
    NSString *documentsPath;
}

@synthesize user;
@synthesize sport;
@synthesize team;
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
    bucket = sport.streamingbucket;
    
    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"BroadcastTesturl"] length] == 0) {
        // Initialize the S3 Client.
        s3 = [[AmazonS3Client alloc] initWithAccessKey:user.awskeyid withSecretKey:user.awssecretkey];
    }
    
    self.IsBroadcasting = NO;
    _teamLabel.stringValue = team.team_name;
    
    if (event.gameschedule_id.length > 0)
        _gameLabel.stringValue = [[event getGame:sport Team:team User:user] vsOpponent];
    
    _eventLabel.stringValue = event.eventname;

    if ([event.videoevent intValue] > 1) {
        videoUrl = [NSURL fileURLWithPath:event.eventurl];
    }
    
    videoname = team.teamid;
    clips = [[NSMutableArray alloc] init];
    startclip = NO;
    clipnumber = 0;
    filemgr = [NSFileManager defaultManager];
    documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

- (IBAction)startBroadcastButtonClicked:(id)sender {
    if (videoUrl) {
        NSMutableArray *arguments = [[NSMutableArray alloc] init];
        NSString *videopath = [videoUrl path];
        [arguments addObject:videopath];
        
        [self streamFileScript:arguments];
        
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"No video asset has been selected for streaming!"];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (IBAction)homeButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisplayMainViewController" object:nil
                                            userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"LiveView", @"Message", nil]];
}

- (IBAction)stopBroadcastButtonClicked:(id)sender {
    self.IsBroadcasting = NO;
    [self.buildTask terminate];
    sleep(5);
    [self cleanupDirectories];
}

- (void)streamFileScript:(NSMutableArray *)arguments {
    S3DeleteObjectResponse *response = [s3 deleteObjectWithKey:[NSString stringWithFormat:@"%@/%@.m3u8", event.event_id, videoname] withBucket:bucket];
    NSLog(@"%@", response.error);
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"transcode-errors.txt"];
    
    if (![filemgr fileExistsAtPath:filePath] == YES)
        [filemgr createFileAtPath:filePath contents:nil attributes:nil];
    
    NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    if (file == nil)
        NSLog(@"Failed to open file");
    
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        
        @try {
            NSString *path;
            
            if (videoUrl) {
                path  = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"StreamFile" ofType:@"command"]];
            } else {
                
            }
            
            NSString *streamingPath = [documentsPath stringByAppendingPathComponent:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"streamingdirectory"]];
            streamingPath = [streamingPath stringByAppendingPathComponent:videoname];
            
            if ([filemgr createDirectoryAtPath:streamingPath withIntermediateDirectories:YES attributes:nil error:nil]) {
                self.buildTask = [[NSTask alloc] init];
                self.buildTask.launchPath = path;
                NSString *segmentfile = [NSString stringWithFormat:@"%@.m3u8", videoname];
                [arguments addObject:[streamingPath stringByAppendingPathComponent:segmentfile]];
                self.buildTask.arguments = arguments;
                
                self.outputPipe = [[NSPipe alloc] init];
                self.buildTask.standardOutput = self.outputPipe;
                
                [[self.outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
                
                [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[self.outputPipe fileHandleForReading] queue:nil usingBlock:^(NSNotification *notification){
                    
                    NSData *output = [[self.outputPipe fileHandleForReading] availableData];
                    NSString *outStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        NSString *messagestring = [NSString stringWithFormat:@"\n%@", outStr];
                        [file seekToEndOfFile];
                        [file writeData:[messagestring dataUsingEncoding:NSUTF8StringEncoding]];
                    });
                    [[self.outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
                }];
                
                [self.buildTask launch];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    self.IsBroadcasting = YES;
                    int counter = 0, filecount = 0;
                    NSString *lastfile = @"";
                    NSString *videofile;
//                    NSDate *lastmodified = [NSDate date];
                    
                    if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"BroadcastTestUrl"] length] == 0) {
                        while (self.IsBroadcasting) {
                            @try {
                                if ([filemgr fileExistsAtPath:[streamingPath stringByAppendingPathComponent:segmentfile]]) {
                                    NSDictionary *attributes = [filemgr attributesOfItemAtPath:[streamingPath stringByAppendingPathComponent:segmentfile]
                                                                                         error:nil];
//                                    NSDate *filemodified = [attributes objectForKey:NSFileModificationDate];
                                    
//                                    if ([lastmodified compare:filemodified] == NSOrderedAscending) {
//                                        videofile = [NSString stringWithFormat:@"%@%d.ts", videoname, filecount];
                                    NSString *stringdata = [NSString stringWithContentsOfFile:[streamingPath stringByAppendingPathComponent:segmentfile]
                                                                                         encoding:NSUTF8StringEncoding error:nil];
                                    if (stringdata != nil) {
                                        if (stringdata.length > 0) {
                                            NSArray *m3u8array = [stringdata componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                                            if (m3u8array.count > 2) {
                                                long pos = m3u8array.count - 2;
                                                NSString *thesegment = [m3u8array objectAtIndex:pos];
                                                NSArray *filenamebits = [thesegment componentsSeparatedByString:@"."];
                                                if (filenamebits.count == 2) {
                                                    if ([[filenamebits objectAtIndex:1] isEqualToString:@"ts"])
                                                        videofile = thesegment;
                                                    else
                                                        videofile = lastfile;
                                                } else
                                                    videofile = lastfile;
                                            } else
                                                videofile = lastfile;
                                        } else
                                            videofile = lastfile;
                                    } else
                                        videofile = lastfile;
                                
                                    if (![lastfile isEqualToString:videofile]) {
                                        
                                        NSString *segmentfile = [NSString stringWithFormat:@"%@.m3u8", videoname];
                                        NSData *videoData = [[NSData alloc] initWithContentsOfFile:[streamingPath stringByAppendingPathComponent:videofile]];
                                        NSData *segmentData = [stringdata dataUsingEncoding:NSUTF8StringEncoding];

                                        NSString *s3path = [NSString stringWithFormat:@"%@/%@", event.event_id, videofile];
                                        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:s3path inBucket:bucket];
                                        por.contentType = @"video/mp4";
                                        por.contentDisposition = @"inline";
                                        por.data = videoData;
                                        [s3 putObject:por];
                                        
                                        s3path = [NSString stringWithFormat:@"%@/%@", event.event_id, segmentfile];
                                        S3PutObjectRequest *seg = [[S3PutObjectRequest alloc] initWithKey:s3path inBucket:bucket];
                                        seg.contentType = @"video/mp4";
                                        seg.contentDisposition = @"inline";
                                        seg.data = segmentData;
                                        [s3 putObject:seg];
                                        
                                        if (counter == 1) {
                                            NSString *playbackstring = [NSString stringWithFormat:@"%@/%@/%@.m3u8", sport.streamingurl,
                                                                        event.event_id, team.teamid];
                                            playbackstring = [playbackstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                            NSURL *playbackurl = [NSURL URLWithString:playbackstring];
                                            NSLog(@"%@", playbackurl);
                                            AVAsset *asset = [AVAsset assetWithURL:playbackurl];
                                            playerItem = [AVPlayerItem playerItemWithAsset:asset];
                                            AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                                            [_playerView setPlayer:player];
                                            
                                            [_playerView.player play];
                                        }
                                        
                                        counter++;
                                        
                                        if (filecount == 4)
                                            filecount = 0;
                                        else
                                            filecount++;
                                        
                                        lastfile = videofile;
//                                        lastmodified = filemodified;
                                        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
                                        [dateformatter setDateFormat:@"YYYY-mm-dd HH:mm:ss"];
//                                        NSLog(@"last date end of loop=%@", [dateformatter stringFromDate:lastmodified]);
                                        NSLog(@"last file=%@", videofile);
                                    } else {
                                        sleep(3);
                                        NSLog(@"sleep videofile=%@", videofile);
                                    }
                                }
                                
                            }
                            @catch ( AmazonServiceException *exception ) {
                                NSLog( @"Upload Failed, Reason: %@", exception );
                            }
                        }
                    }
                });
                
                [self.buildTask waitUntilExit];
                int status = [self.buildTask terminationStatus];
                [file closeFile];
                
                if (status == 0) {
                    self.IsBroadcasting = NO;
                } else {
                    self.IsBroadcasting = NO;
                }
                
                [self cleanupDirectories];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Problem Running Task: %@", [exception description]);
        }
        @finally {
            self.isRunning = NO;
        }
    });
}

- (void)cleanupDirectories {
    NSString *streamingPath = [documentsPath stringByAppendingPathComponent:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"streamingdirectory"]];
    [filemgr removeItemAtPath:streamingPath error:nil];
}

@end
