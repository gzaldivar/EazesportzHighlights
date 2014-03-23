//
//  eazesportzPlayerViewController.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/4/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzPlayerViewController.h"
#import "eazesportzAVClip.h"
#import "Video.h"
#import "ShuffleAlphabet.h"
#import "eazesportzUploadHighlight.h"
#import "eazesportzEditHighlightWindowController.h"
#import "EazesportzAppDelegate.h"

#import <AWSiOSSDK/S3/S3Bucket.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>

#import <libavformat/avformat.h>
#import <libavcodec/avcodec.h>
#import <libavutil/imgutils.h>
#import <libavutil/opt.h>

@interface eazesportzPlayerViewController () <AmazonServiceRequestDelegate>

@property (nonatomic, strong) IBOutlet eazesportzEditHighlightWindowController *editHighlightController;

@end

@implementation eazesportzPlayerViewController {
    AVPlayerItem *playerItem;
    NSMutableArray *clips;
    int clipnumber;
    
    AmazonS3Client *s3;
    NSString *bucket;
    dispatch_queue_t videoQueue;
    
    NSInteger selectedClip;
    NSFileManager *fileMgr;
    NSString *transcodeDir;
    
    eazesportzAppDelegate *appDelegate;
}

@synthesize videoUrl;
@synthesize game;
@synthesize team;
@synthesize sport;
@synthesize user;
@synthesize getPlayers;
@synthesize highdef;
@synthesize highlightDate;

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
    bucket = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"s3bucket"];
    // Initialize the S3 Client.
    s3 = [[AmazonS3Client alloc] initWithAccessKey:user.awskeyid withSecretKey:user.awssecretkey];
    
    [_activityIndicator setDisplayedWhenStopped:YES];
    _activityIndicator.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadResult:) name:@"VideoUploadCompletedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateClipTable:) name:@"UpdateClipTableNotification" object:nil];

    clips = [[NSMutableArray alloc] init];
    clipnumber = 0;
    selectedClip = -1;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *gamedate = [dateFormat dateFromString:game.startdate];
    [dateFormat setDateFormat:@"MM-dd-yyyy"];
    
    if (game) {
        _clipsLabel.stringValue = [NSString stringWithFormat:@"Clips vs %@  %@", game.opponent_mascot, [dateFormat stringFromDate:gamedate]];
        _nogameLabel.hidden = YES;
    } else if (highlightDate) {
        _clipsLabel.stringValue = [NSString stringWithFormat:@"Clips - %@", [dateFormat stringFromDate:highlightDate]];
    } else {
        _clipsLabel.stringValue = [NSString stringWithFormat:@"Clips for %@", team.team_name];
    }
        
    if (s3)
        [self reloadvideoButtonClicked:self];
    else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"Error connecting cloud storage"];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
    
    fileMgr = [NSFileManager defaultManager];
}

- (IBAction)trimButtonClicked:(id)sender {
    
    if ([_playerView canBeginTrimming]) {
        [_playerView beginTrimmingWithCompletionHandler:^(AVPlayerViewTrimResult result) {
            
            if (result == AVPlayerViewTrimOKButton) {
                CMTime inPoint = [playerItem reversePlaybackEndTime];
                CMTime outPoint = [playerItem forwardPlaybackEndTime];
                // Set time range on asset export session.
                CMTimeRange timeRange = CMTimeRangeFromTimeToTime(inPoint, outPoint);
                AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc]
                                                            initWithAsset:[AVAsset assetWithURL:videoUrl]
                                                            presetName:AVAssetExportPreset960x540];
                [assetExportSession setTimeRange:timeRange];
                eazesportzAVClip *newclip = [[eazesportzAVClip alloc] init];
                newclip.clipNumber = [NSNumber numberWithInt:++clipnumber];
                
                if (game) {
                    newclip.clipName = [NSString stringWithFormat:@"Clip %d vs %@", clipnumber, game.opponent_mascot];
                } else {
                    newclip.clipName = [NSString stringWithFormat:@"Clip %d for %@", clipnumber, team.team_name];
                }
                
                newclip.clip = assetExportSession;
                newclip.video.displayName = newclip.clipName;
                [clips addObject:newclip];
                [_clipTableView reloadData];
            } else if (result == AVPlayerViewTrimCancelButton) {
                [self reloadvideoButtonClicked:self];
            }
        }];
    }
}

- (IBAction)reloadvideoButtonClicked:(id)sender {
    AVAsset *asset = [AVAsset assetWithURL:videoUrl];
    playerItem = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    [_playerView setPlayer:player];
}

- (IBAction)saveButtonClicked:(id)sender {
    if (clips.count > 0) {
        _saveButton.enabled = NO;
        _trimButton.enabled = NO;
        _deleteButton.enabled = NO;
        _reloadButton.enabled = NO;
        _activityIndicator.hidden = NO;
        [_activityIndicator startAnimation:self];
        
        videoQueue = dispatch_queue_create("Video Queue", NULL);
        NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        transcodeDir = [applicationDocumentsDir stringByAppendingPathComponent:team.teamid];
        
        if (game)
            transcodeDir = [transcodeDir stringByAppendingPathComponent:game.opponent_mascot];
        
        if ([fileMgr createDirectoryAtPath:transcodeDir withIntermediateDirectories:YES attributes:nil error:nil]) {
            for (int i = 0; i < clips.count; i++) {
                if (![[[clips objectAtIndex:i] uploaded] isEqualToString:@"Error"]) {
                    NSString *storePath = [transcodeDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_temp.mp4", [[clips objectAtIndex:i] clipName]]];

                    if ([fileMgr fileExistsAtPath:storePath]) {
                        [fileMgr removeItemAtPath:storePath error:NULL];
                    }
                    
                    [[clips objectAtIndex:i] clip].outputURL = [NSURL fileURLWithPath:storePath];
                    [[clips objectAtIndex:i] clip].outputFileType = AVFileTypeMPEG4;
                    [[clips objectAtIndex:i] clip].shouldOptimizeForNetworkUse = YES;
                    
                    [[[clips objectAtIndex:i] clip] exportAsynchronouslyWithCompletionHandler:^{
//                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self exportDidFinish:[clips objectAtIndex:i]];
//                        });
                    }];
                }
            }
        } else {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                               otherButton:nil informativeTextWithFormat:@"Error creating transcode directory. Please contact Admin."];
            [alert setIcon:[sport getImage:@"tiny"]];
            [alert runModal];
        }
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Notice" defaultButton:@"OK" alternateButton:nil
                                           otherButton:nil informativeTextWithFormat:@"No clips to upload!"];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

-(void)exportDidFinish:(eazesportzAVClip *)clip {
    if ([clip.clip status] == AVAssetExportSessionStatusCompleted) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
        AVCodecContext *codecCtx = [self HDVideo:clip];
        AVURLAsset* asset = [AVURLAsset URLAssetWithURL:clip.clip.outputURL options:nil];
        CMTime duration = asset.duration;
        clip.video.duration = [NSNumber numberWithFloat:CMTimeGetSeconds(duration)];
        NSString *filetype = [[clip.clip.outputURL absoluteString] pathExtension];
        NSString *filename = [[clip.clip.outputURL path] lastPathComponent];
        NSArray *filebits = [filename componentsSeparatedByString:@"_"];
    
        if (codecCtx->codec->id == AV_CODEC_ID_H264) {      // content is h.264
            NSMutableArray *arguments = [[NSMutableArray alloc] init];
                [arguments addObject:[clip.clip.outputURL path]];
            
            if (highdef)
                [arguments addObject:@"852x480"];
            else
                [arguments addObject:@"480x360"];
            
            if ([filetype isEqualToString:@"mov"]) {
                
            } else if ([filetype isEqualToString:@"mts"]) {
                
            } else if ([filetype isEqualToString:@"mpeg"]) {
                
            } else if ([filetype isEqualToString:@"mp4"]) {
//                    [arguments addObject:[NSString stringWithFormat:@"%@/%@.%@", documentsPath, filename, @"mp4"]];
                [arguments addObject:[NSString stringWithFormat:@"%@/%@.mp4", transcodeDir, [filebits objectAtIndex:0]]];
            }
            
            [arguments addObject:[NSString stringWithFormat:@"%@/Contents/Resources/ffmpeg", [[NSBundle mainBundle] bundlePath]]];
            
            if (highdef)
                [arguments addObject:@"1111k"];
            else
                [arguments addObject:@"600k"];
            
            [self runScript:arguments VideoClip:clip];
        } else {                                            // we need to convert the video to h.264
            
        }
//        });
    } else if ([clip.clip status] == AVAssetExportSessionStatusFailed) {
        NSAlert *alert = [NSAlert alertWithError:[clip.clip error]];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    } else {
        NSAlert *alert = [NSAlert alertWithError:[clip.clip error]];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert runModal];
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    eazesportzAVClip *aclip = [clips objectAtIndex:row];
    
    if([tableColumn.identifier isEqualToString:@"ClipNumberColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"ClipNumberColumn" owner:self];
        cellView.textField.stringValue = [aclip.clipNumber stringValue];
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"ClipNameColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"ClipNameColumn" owner:self];
        cellView.textField.stringValue = aclip.clipName;
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"ClipDurationColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"ClipDurationColumn" owner:self];
        CMTimeRange timerange = [[aclip clip] timeRange];
        CMTime durationV = timerange.duration;
        
        NSUInteger dTotalSeconds = CMTimeGetSeconds(durationV);
        
        NSUInteger dHours = floor(dTotalSeconds / 3600);
        NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
        NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
        cellView.textField.stringValue = [NSString stringWithFormat:@"%lu:%lu", (unsigned long)dMinutes,
                                          (unsigned long)dSeconds];
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"ClipUploadedColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"ClipUploadedColumn" owner:self];
        if ([aclip.uploaded isEqualToString:@"YES"]) {
            cellView.textField.textColor = [NSColor blueColor];
            cellView.textField.stringValue = @"Yes";
        } else if ([aclip.uploaded isEqualToString:@"Error"]) {
            cellView.textField.textColor = [NSColor redColor];
            cellView.textField.stringValue = @"Error";
        } else {
            cellView.textField.stringValue = @"No";
        }
        
        return cellView;
        
    }
    return [tableView makeViewWithIdentifier:@"ClipTableCell" owner:self];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return clips.count;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    selectedClip = [_clipTableView selectedRow];
    
    if (selectedClip > -1) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Edit"];
        [alert addButtonWithTitle:@"Delete"];
        [alert setInformativeText:[NSString stringWithFormat:@"Clip - %@", [[clips objectAtIndex:selectedClip] clipName]]];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert setIcon:[sport getImage:@"tiny"]];
        [alert beginSheetModalForWindow:appDelegate.window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        self.editHighlightController = [[eazesportzEditHighlightWindowController alloc] initWithWindowNibName:@"eazesportzEditHighlightWindowController"];
        self.editHighlightController.sport = sport;
        self.editHighlightController.team = team;
        self.editHighlightController.game = game;
        self.editHighlightController.user = user;
        self.editHighlightController.getPlayers = getPlayers;
        self.editHighlightController.clipname = [[clips objectAtIndex:selectedClip] clipName];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(highlightUpdated:) name:@"HighlightsDataUpdtedNotification" object:nil];
        [self.editHighlightController showWindow:self];
    } else {
        [self deleteButtonClicked:self];
    }
}

- (void)highlightUpdated:(NSNotification *)notification {
    eazesportzAVClip *theclip = [clips objectAtIndex:selectedClip];
    theclip.clipName = self.editHighlightController.highlightNameTextField.stringValue;
    theclip.video.displayName = theclip.clipName;
    theclip.video.description = self.editHighlightController.highlightsDescription.stringValue;
    theclip.video.players = self.editHighlightController.players;
    theclip.video.gamelog = self.editHighlightController.gamelog.gamelogid;
    
    if (self.editHighlightController.game.id.length > 0)
        theclip.video.schedule = self.editHighlightController.game.id;
    
    theclip.video.teamid = team.teamid;
    
    [_clipTableView reloadData];
}

- (IBAction)deleteButtonClicked:(id)sender {
    if (selectedClip > -1) {
        [clips removeObjectAtIndex:selectedClip];
        [_clipTableView deselectColumn:selectedClip];
        selectedClip = -1;
    }
    
    [_clipTableView reloadData];
}

- (void)stopTranscodeTask {
    if ([self.buildTask isRunning]) {
        [self.buildTask terminate];
    }
}

- (void)runScript:(NSArray*)arguments VideoClip:(eazesportzAVClip *)videoClip {
    eazesportzUploadHighlight *upload = [[eazesportzUploadHighlight alloc] init];
    upload.sport = sport;
    upload.team = team;
    upload.game = game;
    upload.user = user;
    upload.bucket = bucket;
    upload.s3 = s3;
    
    NSFileManager *filemgr;
    
    filemgr = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"transcode-errors.txt"];
    
    if (![filemgr fileExistsAtPath:filePath] == YES)
        [filemgr createFileAtPath:filePath contents:nil attributes:nil];

    NSFileHandle *file;
//    NSData *databuffer;
    
    file = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    if (file == nil)
        NSLog(@"Failed to open file");
    
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        
        self.isRunning = YES;
        
        @try {
            NSString *path  = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"TranscodeClip" ofType:@"command"]];
            
            self.buildTask = [[NSTask alloc] init];
            self.buildTask.launchPath = path;
            self.buildTask.arguments  = arguments;
            
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
            
            [self.buildTask waitUntilExit];
            int status = [self.buildTask terminationStatus];
            [file closeFile];
            
            if (status == 0) {
                upload.clipindex = [videoClip.clipNumber intValue];
                [upload uploadVideo:[arguments objectAtIndex:2] Video:videoClip.video Hidden:[_hideClipsButton state]];
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

- (AVCodecContext *)HDVideo:(eazesportzAVClip *)video {
    int i, videoStream;
    AVCodecContext  *codecCtxIn;
    AVFormatContext *formatCtx = NULL;
    AVCodec         *codecIn;
    
    // Register all formats and codecs
    av_register_all();
    
    NSString *urlstring = video.clip.outputURL.path;
    const char *url = [urlstring cStringUsingEncoding:NSUTF8StringEncoding];
    
    //    int ret = avformat_open_input(&s, url, NULL, NULL);
    //    if (ret < 0)
    //        abort();
    
    int err;
    
    if ((err = avformat_open_input(&formatCtx, url, NULL, NULL) < 0)) {
        NSLog(@"avopen error = %d", err);
        video.uploaded = @"Error";
        return nil;
    }
    
    // Retrieve stream information
    if (avformat_find_stream_info(formatCtx, NULL) < 0)
        return nil; // Couldn't find stream information
    
    // Dump information about file onto standard error
    av_dump_format(formatCtx, 0, url, 0);
    
    // Find the first video stream
    videoStream = -1;
    
    for (i = 0; i < formatCtx->nb_streams; i++) {
        if (formatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO) {
            videoStream = i;
            break;
        }
    }
    
    if (videoStream == -1)
        return  nil; // Didn't find a video stream
    
    // Get a pointer to the codec context for the video stream
    codecCtxIn = formatCtx->streams[videoStream]->codec;
    
    // Find the decoder for the video stream
    codecIn = avcodec_find_decoder(codecCtxIn -> codec_id);
    
    if (codecIn == NULL) {
        fprintf(stderr, "Unsupported codec!\n");
        return nil; // Codec not found
    }
    
    // Open codec
    if (avcodec_open2(codecCtxIn, codecIn, NULL) < 0)
        return nil; // Could not open codec
    
    // Close the codec
//    avcodec_close(codecCtxIn);
    
//    avformat_close_input(&formatCtx);
    
    return codecCtxIn;
}

- (IBAction)homeButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DisplayMainViewController" object:nil
                                                userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"VideoClipView", @"Message", nil]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)uploadResult:(NSNotification *)notification {
    eazesportzAVClip *clip;
    
    for (int theclip = 0; theclip < clips.count; theclip++) {
        if ([[[clips objectAtIndex:theclip] clipNumber] intValue] == [[[notification userInfo] objectForKey:@"clipindex"] intValue]) {
            clip = [clips objectAtIndex:theclip];
            break;
        }
    }
    
    if ([[[notification userInfo] objectForKey:@"Result"] isEqualToString:@"Success"]) {
        [clips removeObject:clip];
        [[NSFileManager defaultManager] removeItemAtPath:[clip.clip.outputURL path] error:nil];
    } else {
        clip.uploaded = @"Error";
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateClipTableNotification" object:self];
}

- (void)updateClipTable:(NSNotification *)notification {

    if (clips.count == 0) {
        _activityIndicator.hidden = YES;
        [_activityIndicator stopAnimation:self];
        _saveButton.enabled = YES;
        _trimButton.enabled = YES;
        _deleteButton.enabled = YES;
        _reloadButton.enabled = YES;
        
        [fileMgr removeItemAtPath:[transcodeDir stringByDeletingLastPathComponent] error:nil];
    }
    
    [_clipTableView reloadData];
}

@end
