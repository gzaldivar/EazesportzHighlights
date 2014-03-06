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

#import <AWSiOSSDK/S3/S3Bucket.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>

#import <libavformat/avformat.h>
#import <libavcodec/avcodec.h>
#import <libavutil/imgutils.h>
#import <libavutil/opt.h>

@interface eazesportzPlayerViewController () <AmazonServiceRequestDelegate>

@end

@implementation eazesportzPlayerViewController {
    AVPlayerItem *playerItem;
    NSMutableArray *clips;
    int clipnumber, uploadedclips;
    
    AmazonS3Client *s3;
    NSString *bucket;
    dispatch_queue_t videoQueue;
    
    NSInteger selectedClip;
}

@synthesize videoUrl;
@synthesize game;
@synthesize team;
@synthesize sport;
@synthesize user;
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
    _renameTextField.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadSuccesful:) name:@"UploadSuccesfulNotfication" object:nil];

    clips = [[NSMutableArray alloc] init];
    clipnumber = 0;
    uploadedclips = 0;
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
                Float64 dur = CMTimeGetSeconds([[assetExportSession asset] duration]);
                newclip.video.duration = [NSNumber numberWithFloat:dur];
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
        _renameButton.enabled = NO;
        _deleteButton.enabled = NO;
        _reloadButton.enabled = NO;
        _activityIndicator.hidden = NO;
        [_activityIndicator startAnimation:self];
        
        videoQueue = dispatch_queue_create("Video Queue", NULL);
//        transcodeMessageQueue = dispatch_queue_create("Transcode Queue", NULL);
//        transcodeCompleteQueue = dispatch_queue_create("Transcode Complete Queue", NULL);
//        errorQueue = dispatch_queue_create("Error Queue", NULL);
        
        for (int i = 0; i < clips.count; i++) {
            if (![[clips objectAtIndex:i] uploaded]) {
                NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *storePath = [applicationDocumentsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-temp.mp4",
                                                                       [[clips objectAtIndex:i] clipName]]];

                if ([[NSFileManager defaultManager] fileExistsAtPath:storePath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:storePath error:NULL];
                }
                
                [[clips objectAtIndex:i] clip].outputURL = [NSURL fileURLWithPath:storePath];
                [[clips objectAtIndex:i] clip].outputFileType = AVFileTypeMPEG4;
                [[clips objectAtIndex:i] clip].shouldOptimizeForNetworkUse = YES;
                
                [[[clips objectAtIndex:i] clip] exportAsynchronouslyWithCompletionHandler:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self exportDidFinish:[clips objectAtIndex:i]];
                    });
                }];
            }
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
        dispatch_async(videoQueue, ^{
            clip.posterImage = [self getPosterforClip:clip.clip];
            
            AVCodecContext *codecCtx = [self HDVideo:clip];
            NSString *filetype = [[clip.clip.outputURL absoluteString] pathExtension];
            NSString *filename = [[clip.clip.outputURL absoluteString] lastPathComponent];
            NSString *thefile = [[filename componentsSeparatedByString:@"-"] objectAtIndex:0];
            
            if (codecCtx->codec->id == AV_CODEC_ID_H264) {      // content is h.264
                NSMutableArray *arguments = [[NSMutableArray alloc] init];
                NSFileManager *filemgr;
                
                filemgr = [NSFileManager defaultManager];
                NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

                [arguments addObject:[NSString stringWithFormat:@"%@/%@", documentsPath, filename]];
                
                if (highdef)
                    [arguments addObject:@"640x360"];
                else
                    [arguments addObject:@"480x360"];
                
                if ([filetype isEqualToString:@"mov"]) {
                    
                } else if ([filetype isEqualToString:@"mts"]) {
                    
                } else if ([filetype isEqualToString:@"mpeg"]) {
                    
                } else if ([filetype isEqualToString:@"mp4"]) {
                    [arguments addObject:[NSString stringWithFormat:@"%@/%@.%@", documentsPath, thefile, @"mp4"]];
                }
                
                [self runScript:arguments VideoClip:clip];
            } else {                                            // we need to convert the video to h.264
                
            }
/*
            [self uploadVideo:clip];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self uploadSuccesful:clip];
            });
 */
        });
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

- (NSImage *)getPosterforClip:(AVAssetExportSession *)session {
    AVAsset *myAsset = [AVAsset assetWithURL:session.outputURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:myAsset];
    
    Float64 durationSeconds = CMTimeGetSeconds([myAsset duration]);
    CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
    NSError *error;
    CMTime actualTime;
    
    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
    
    if (halfWayImage != NULL) {
        
        NSString *actualTimeString = (__bridge NSString *)CMTimeCopyDescription(NULL, actualTime);
        NSString *requestedTimeString = (__bridge NSString *)CMTimeCopyDescription(NULL, midpoint);
        NSLog(@"Got halfWayImage: Asked for %@, got %@", requestedTimeString, actualTimeString);

        NSImage *animage = [[NSImage alloc] initWithCGImage:halfWayImage size:NSZeroSize];
        return animage;
    } else
        return nil;
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
        _renameTextField.stringValue = [[clips objectAtIndex:selectedClip] clipName];
        _renameTextField.hidden = NO;
    } else {
        _renameTextField.hidden = YES;
    }
}

- (void)uploadVideo:(eazesportzAVClip *)videoclip {
    NSError *err;
    
    if ([videoclip.clip.outputURL checkResourceIsReachableAndReturnError:&err]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/sports/%@/videoclips/createclient.json?auth_token=%@",
                                           [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzUrl"], sport.id, user.authtoken]];
        
        NSData *videoData = [NSData dataWithContentsOfURL:[videoclip.clip outputURL]];
        videoclip.video.size = [NSNumber numberWithInt:videoData.length];
        
        NSMutableDictionary *videoDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: [NSString stringWithFormat:@"%@.mp4",videoclip.clipName],
                                          @"filename",  videoclip.clipName, @"displayname", @"video/mp4", @"filetype", team.teamid, @"team_id",
                                          user.userid, @"user_id", game.id, @"gameschedule_id", [videoclip.video.duration stringValue], @"duration",
                                          [videoclip.video.size stringValue], @"size", [NSString stringWithFormat:@"%lu", [_hideClipsButton state]],
                                          @"hidden", nil];
        
        NSMutableURLRequest *urlrequest = [NSMutableURLRequest requestWithURL:url];
        NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:videoDict, @"videoclip", nil];
        
        NSError *jsonSerializationError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonSerializationError];
        
        if (!jsonSerializationError) {
            NSString *serJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"Serialized JSON: %@", serJson);
        } else {
            NSLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
        }
        
        [urlrequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlrequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [urlrequest setHTTPMethod:@"POST"];
        [urlrequest setHTTPBody:jsonData];
        
        //Capturing server response
        NSURLResponse* urlresponse;
        NSData* result = [NSURLConnection sendSynchronousRequest:urlrequest  returningResponse:&urlresponse error:&jsonSerializationError];
        NSMutableDictionary *serverData = [NSJSONSerialization JSONObjectWithData:result options:0
                                                                            error:&jsonSerializationError];
        NSLog(@"%@", serverData);
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)urlresponse;
        
        if ([httpResponse statusCode] == 200) {
            NSDictionary *items = [serverData objectForKey:@"videoclip"];
            videoclip.video = [[Video alloc] initWithDirectory:items];
            
            NSString *posterpath = [NSString stringWithFormat:@"videos/%@", videoclip.video.videoid];
            videoclip.awsposterobject = [NSString stringWithFormat:@"%@/%@", bucket, posterpath];
            
            @try {
                // upload poster ...
            
                [videoclip.posterImage lockFocus];
                NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, videoclip.posterImage.size.width,
                                                                                  videoclip.posterImage.size.height)];
                [videoclip.posterImage unlockFocus];
                NSData *photoData = [bitmapRep representationUsingType:NSPNGFileType properties:Nil];

                S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@.jpg", videoclip.clipName]
                                                                         inBucket:videoclip.awsposterobject];
                por.contentType = @"image/jpeg";
                por.data = photoData;
                [s3 putObject:por];
/*                S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
                override.contentType = @"image/jpeg";
                S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
                gpsur.key     = [NSString stringWithFormat:@"%@.jpg", videoclip.clipName];
                gpsur.bucket  = bucket;
                gpsur.expires = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 473040000];
                gpsur.responseHeaderOverrides = override;
                NSURL *posterurl = [s3 getPreSignedURL:gpsur];
                videoclip.video.poster_url = [posterurl absoluteString];  */
                
                // upload video ....
                
                NSString *videopath = [NSString stringWithFormat:@"videos/%@", videoclip.video.videoid];
                videoclip.awsvideoobject = [NSString stringWithFormat:@"%@/%@", bucket, videopath];
                por = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@.mp4", videoclip.clipName] inBucket:videoclip.awsvideoobject];
                por.contentType = @"video/mp4";
                por.data = videoData;
                por.contentLength = [videoData length];
                [s3 putObject:por];
                
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/sports/%@/videoclips/%@.json?auth_token=%@",
                                                   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzUrl"],
                                                   sport.id, videoclip.video.videoid, user.authtoken]];
                NSMutableDictionary *videoDict =  [[NSMutableDictionary alloc] initWithObjectsAndKeys: [NSString stringWithFormat:@"%@.mp4",videoclip.clipName],
                                                   @"filename", videoclip.clipName, @"displayname", @"video/mp4", @"filetype", team.teamid, @"team_id",
                                                   user.userid, @"user_id", game.id, @"gameschedule_id", [videoclip.video.duration stringValue],
                                                   @"duration", [NSString stringWithFormat:@"%@/%@.jpg", posterpath, videoclip.clipName],
                                                   @"poster_filepath", [NSString stringWithFormat:@"%@/%@.mp4", videopath, videoclip.clipName],
                                                   @"filepath", nil];
                
                NSMutableURLRequest *urlrequest = [NSMutableURLRequest requestWithURL:url];
                NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:videoDict, @"videoclip", nil];
                
                NSError *jsonSerializationError = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonSerializationError];
                
                if (!jsonSerializationError) {
                    NSString *serJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    NSLog(@"Serialized JSON: %@", serJson);
                } else {
                    NSLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
                }
                
                [urlrequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [urlrequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
                [urlrequest setHTTPMethod:@"PUT"];
                [urlrequest setHTTPBody:jsonData];
                
                //Capturing server response
                NSURLResponse* urlresponse;
                NSData* result = [NSURLConnection sendSynchronousRequest:urlrequest  returningResponse:&urlresponse error:&jsonSerializationError];
                NSMutableDictionary *serverData = [NSJSONSerialization JSONObjectWithData:result options:0 error:&jsonSerializationError];
                NSLog(@"%@", serverData);
                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)urlresponse;
                
                if ([httpResponse statusCode] == 200) {
                    NSDictionary *items = [serverData objectForKey:@"videoclip"];
                    videoclip.video = [[Video alloc] initWithDirectory:items];
                    
                    videoclip.uploaded = @"YES";
                } else {
                    videoclip.uploaded = @"Error";
                }
            }
            @catch ( AmazonServiceException *exception ) {
                NSLog( @"Upload Failed, Reason: %@", exception );
                videoclip.uploaded = @"Error";
            }
            
        } else {
            videoclip.uploaded = @"Error";
        }
    } else {
        videoclip.uploaded = @"Error";
    }
}

- (void)uploadSuccesful:(eazesportzAVClip *)videoclip {
    [[NSFileManager defaultManager] removeItemAtURL:videoclip.clip.outputURL error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:[videoclip getFilepathFromOutputUrl] error:nil];
    
    uploadedclips++;
    
    if (uploadedclips == clips.count) {
        _activityIndicator.hidden = YES;
        [_activityIndicator stopAnimation:self];
        _saveButton.enabled = YES;
        _trimButton.enabled = YES;
        _renameButton.enabled = YES;
        _deleteButton.enabled = YES;
        _reloadButton.enabled = YES;
    }
    
    if (!videoclip.uploaded) {
        if (videoclip.video.videoid.length > 0) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/sports/%@/videoclips/%@.json?auth_token=%@",
                                               [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzUrl"], sport.id, videoclip.video.videoid,
                                               user.authtoken]];
            NSMutableURLRequest *urlrequest = [NSMutableURLRequest requestWithURL:url];
            NSDictionary *jsonDict = [[NSDictionary alloc] init];
            NSError *jsonSerializationError = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonSerializationError];
            
            if (!jsonSerializationError) {
                NSString *serJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSLog(@"Serialized JSON: %@", serJson);
            } else {
                NSLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
            }
            
            [urlrequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [urlrequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
            [urlrequest setHTTPMethod:@"DELETE"];
            [urlrequest setHTTPBody:jsonData];
            
            //Capturing server response
            NSURLResponse* urlresponse;
            NSData* result = [NSURLConnection sendSynchronousRequest:urlrequest  returningResponse:&urlresponse error:&jsonSerializationError];
            NSMutableDictionary *videodict = [NSJSONSerialization JSONObjectWithData:result options:0 error:&jsonSerializationError];
            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)urlresponse;
            if ([httpResponse statusCode] != 200) {
                NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil
                                     informativeTextWithFormat:@"Error uploading clip %@ to cloud", videoclip.clipName];
                [alert setIcon:[sport getImage:@"tiny"]];
                [alert runModal];
            }
        }
    }
    
    [_clipTableView reloadData];
}

- (IBAction)renameButtonClicked:(id)sender {
    if (selectedClip > -1) {
        eazesportzAVClip *theclip = [clips objectAtIndex:selectedClip];
        theclip.clipName = _renameTextField.stringValue;
        [_clipTableView deselectColumn:selectedClip];
        [_clipTableView reloadData];
        selectedClip = -1;
        _renameTextField.hidden = YES;
    }
}

- (IBAction)deleteButtonClicked:(id)sender {
    if (selectedClip > -1) {
        [clips removeObjectAtIndex:selectedClip];
        [_clipTableView deselectColumn:selectedClip];
        [_clipTableView reloadData];
        selectedClip = -1;
        _renameTextField.hidden = YES;
    }
}

- (void)stopTranscodeTask {
    if ([self.buildTask isRunning]) {
        [self.buildTask terminate];
    }
}

- (void)runScript:(NSArray*)arguments VideoClip:(eazesportzAVClip *)videoClip {
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
//            self.stderrorPipe = [[NSPipe alloc] init];
//            self.buildTask.standardError = self.stderrorPipe;
            
            [[self.outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
//            [[self.stderrorPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            
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
/*
            [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[self.stderrorPipe fileHandleForReading]
                                                               queue:nil usingBlock:^(NSNotification *notification){
                
                NSData *erroutput = [[self.stderrorPipe fileHandleForReading] availableData];
                NSString *outStr = [[NSString alloc] initWithData:erroutput encoding:NSUTF8StringEncoding];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSString *errstring = [NSString stringWithFormat:@"\n%@", outStr];
                    [file seekToEndOfFile];
                    [file writeData:[errstring dataUsingEncoding:NSUTF8StringEncoding]];
                });
                [[self.stderrorPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            }];
 */

            [self.buildTask launch];
            
            [self.buildTask waitUntilExit];
            int status = [self.buildTask terminationStatus];
            [file closeFile];
            
            if (status == 0) {
                [self uploadVideo:videoClip];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self uploadSuccesful:videoClip];
                });
            } else {
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

@end
