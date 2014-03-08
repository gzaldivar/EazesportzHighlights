//
//  eazesportzUploadHighlight.m
//  EazesportzHighlights
//
//  Created by Gilbert Zaldivar on 3/6/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzUploadHighlight.h"

#import <libavformat/avformat.h>

@implementation eazesportzUploadHighlight {
    float duration;
    int height;
    int width;
    int bitrate;
    float framerate;
}

- (void)uploadVideo:(NSString *)pathname Hidden:(BOOL)hidden {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSError *err;
        
        if ([[NSURL fileURLWithPath:pathname] checkResourceIsReachableAndReturnError:&err]) {
            NSImage *posterImage = [self getPosterforClip:[NSURL fileURLWithPath:pathname]];
            
            if (posterImage) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/sports/%@/videoclips/createclient.json?auth_token=%@",
                                                   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzUrl"], _sport.id, _user.authtoken]];
                
                NSData *videoData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:pathname]];
                
                NSMutableDictionary *videoDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: [pathname lastPathComponent], @"filename",
                                                  [pathname lastPathComponent], @"displayname", @"video/mp4", @"filetype", _team.teamid, @"team_id",
                                                  _user.userid, @"user_id", _game.id, @"gameschedule_id",
                                                  [NSString stringWithFormat:@"%f", duration], @"duration",
                                                  [NSString stringWithFormat:@"%lu", videoData.length], @"size",
                                                  [NSString stringWithFormat:@"%d", (int)posterImage.size.width], @"width",
                                                  [NSString stringWithFormat:@"%d", (int)posterImage.size.height], @"height",
                                                  [NSString stringWithFormat:@"%d", hidden], @"hidden", nil];
                
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
                    Video *video = [[Video alloc] initWithDirectory:items];
                    
                    NSString *posterpath = [NSString stringWithFormat:@"videos/%@", video.videoid];
                    NSString *awsposterobject = [NSString stringWithFormat:@"%@/%@", _bucket, posterpath];
                    
                    @try {
                        // upload poster ...
                        
                        [posterImage lockFocus];
                        NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, posterImage.size.width,
                                                                                                                   posterImage.size.height)];
                        [posterImage unlockFocus];
                        NSData *photoData = [bitmapRep representationUsingType:NSPNGFileType properties:Nil];
                        
                        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:
                                                   [NSString stringWithFormat:@"%@.jpg", [pathname lastPathComponent]] inBucket:awsposterobject];
                        por.contentType = @"image/jpeg";
                        por.data = photoData;
                        [_s3 putObject:por];
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
                        
                        NSString *videopath = [NSString stringWithFormat:@"videos/%@", video.videoid];
                        NSString *awsvideoobject = [NSString stringWithFormat:@"%@/%@", _bucket, videopath];
                        por = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@.mp4", [pathname lastPathComponent]]
                                                             inBucket:awsvideoobject];
                        por.contentType = @"video/mp4";
                        por.data = videoData;
                        por.contentLength = [videoData length];
                        [_s3 putObject:por];
                        
                        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/sports/%@/videoclips/%@.json?auth_token=%@",
                                                           [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzUrl"],
                                                           _sport.id, video.videoid, _user.authtoken]];
                        
                        NSMutableDictionary *videoDict =  [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                           [NSString stringWithFormat:@"%@.mp4", [pathname lastPathComponent]],
                                                           @"filename", [pathname lastPathComponent], @"displayname", @"video/mp4", @"filetype",
                                                           _team.teamid, @"team_id", _user.userid, @"user_id", _game.id, @"gameschedule_id",
                                                           [video.duration stringValue], @"duration",
                                                           [NSString stringWithFormat:@"%@/%@.jpg", posterpath, [pathname lastPathComponent]],
                                                           @"poster_filepath",
                                                           [NSString stringWithFormat:@"%@/%@.mp4", videopath, [pathname lastPathComponent]],
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
                            video = [[Video alloc] initWithDirectory:items];
                            [self uploadSuccessful:pathname];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ClipUploadNotification" object:nil
                                                                userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Success", @"Result",
                                                                          [pathname lastPathComponent], @"clipname", nil]];
                        } else {
                            [self uploadFailed:pathname Video:video];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ClipUploadNotification" object:nil
                                                userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Error updating meta data. Contact admin.",
                                                          @"Result", [pathname lastPathComponent], @"clipname", nil]];
                        }
                    }
                    @catch ( AmazonServiceException *exception ) {
                        NSLog( @"Upload Failed, Reason: %@", exception );
                        [self uploadFailed:pathname Video:video];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClipUploadNotification" object:nil
                                                            userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:exception.reason, @"Result",
                                                            [pathname lastPathComponent], @"clipname", nil]];
                    }
                    
                } else {
                    [self uploadFailed:pathname Video:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClipUploadNotification" object:nil
                            userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Error Creating video meta data. Contact admin.", @"Result",
                                      [pathname lastPathComponent], @"clipname", nil]];
                }
            } else {
                [self uploadFailed:pathname Video:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ClipUploadNotification" object:nil
                                        userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Error Creating viposter image. Contact admin.", @"Result",
                                                                            [pathname lastPathComponent], @"clipname", nil]];
            }
        } else {
            [self uploadFailed:pathname Video:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ClipUploadNotification" object:nil
                        userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Video not found.", @"Result", [pathname lastPathComponent], @"clipname", nil]];
        }
    });
}

- (NSImage *)getPosterforClip:(NSURL *)videoUrl {
    AVAsset *myAsset = [AVAsset assetWithURL:videoUrl];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:myAsset];
    
    duration = CMTimeGetSeconds([myAsset duration]);
    CMTime midpoint = CMTimeMakeWithSeconds(duration/2.0, 600);
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

- (void)uploadSuccessful:(NSString *)pathname {
    [[NSFileManager defaultManager] removeItemAtPath:pathname error:nil];
}

- (void)uploadFailed:(NSString *)pathname Video:(Video *)video {
    [[NSFileManager defaultManager] removeItemAtPath:pathname error:nil];
    
    if (video) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/sports/%@/videoclips/%@.json?auth_token=%@",
                                           [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzUrl"], _sport.id, video.videoid,
                                           _user.authtoken]];
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
                                 informativeTextWithFormat:@"Error uploading clip %@ to cloud", [pathname lastPathComponent]];
            [alert setIcon:[_sport getImage:@"tiny"]];
            [alert runModal];
        }
    }
}

@end
