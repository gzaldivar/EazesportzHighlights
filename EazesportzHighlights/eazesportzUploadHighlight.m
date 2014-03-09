//
//  eazesportzUploadHighlight.m
//  EazesportzHighlights
//
//  Created by Gilbert Zaldivar on 3/6/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzUploadHighlight.h"

#import <libavformat/avformat.h>
#import <AVFoundation/AVFoundation.h>

@implementation eazesportzUploadHighlight {
    float duration;
    int height;
    int width;
    int bitrate;
    float framerate;
}

- (void)uploadVideo:(NSString *)pathname Video:(Video *)video Hidden:(BOOL)hidden {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSError *err;
        
        if ([[NSURL fileURLWithPath:pathname] checkResourceIsReachableAndReturnError:&err]) {
            NSImage *posterImage = [self getPosterforClip:[NSURL fileURLWithPath:pathname]];
            
            if (posterImage) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/sports/%@/videoclips/createclient.json?auth_token=%@",
                                                   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EazesportzUrl"], _sport.id, _user.authtoken]];
                
                NSData *videoData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:pathname]];
                
                NSMutableDictionary *videoDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys: video.displayName, @"filename",
                                                  video.displayName, @"displayname", @"video/mp4", @"filetype", _team.teamid, @"team_id",
                                                  _user.userid, @"user_id", _game.id, @"gameschedule_id", video.gamelog, @"gamelog_id",
                                                  [video.duration stringValue], @"duration", video.description, @"description",
                                                  [NSString stringWithFormat:@"%lu", videoData.length], @"size",
                                                  [NSString stringWithFormat:@"%d", (int)posterImage.size.width], @"width",
                                                  [NSString stringWithFormat:@"%d", (int)posterImage.size.height], @"height",
                                                  [NSString stringWithFormat:@"%d", hidden], @"hidden",
                                                  video.description, @"description", nil];
                
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
                                                           [NSString stringWithFormat:@"%@.mp4", video.displayName], @"filename",
                                                           video.displayName, @"displayname", @"video/mp4", @"filetype",
                                                           _team.teamid, @"team_id", _user.userid, @"user_id", _game.id, @"gameschedule_id",
                                                           [video.duration stringValue], @"duration", video.description, @"description",
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
                            [self uploadSuccessful:pathname Video:[[Video alloc] initWithDirectory:items]];
                        } else {
                            [self uploadFailed:pathname Video:video];
                        }
                    }
                    @catch ( AmazonServiceException *exception ) {
                        NSLog( @"Upload Failed, Reason: %@", exception );
                        [self uploadFailed:pathname Video:video];
                    }
                    
                } else {
                    [self uploadFailed:pathname Video:nil];
               }
            } else {
                [self uploadFailed:pathname Video:nil];
            }
        } else {
            [self uploadFailed:pathname Video:nil];
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

- (void)uploadSuccessful:(NSString *)pathname Video:(Video *)video {
    [[NSFileManager defaultManager] removeItemAtPath:pathname error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoUploadCompletedNotification" object:video
                                        userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Success", @"Result", _clipindex, @"clipindex", nil]];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoUploadCompletedNotification" object:video
                                                      userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Upload Error", @"Result", nil]];
}

- (void)addVideoTags:(Video *)avideo {
/*    NSURL *aurl = [NSURL URLWithString:[sportzServerInit tagAthletesVideo:video Token:currentSettings.user.authtoken]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aurl];
    NSMutableDictionary *tagDict = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < [addtags count]; i++) {
        [tagDict setObject:[[addtags objectAtIndex:i] athleteid] forKey:[[addtags objectAtIndex:i] logname]];
    }
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tagDict, @"videoclip", nil];
    NSError *jsonSerializationError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonSerializationError];
    
    if (!jsonSerializationError) {
        NSString *serJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Serialized JSON: %@", serJson);
    } else {
        NSLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:jsonData];
    
    //Capturing server response
    NSURLResponse* response;
    NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&jsonSerializationError];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:&jsonSerializationError];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    if ([httpResponse statusCode] != 200) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error updating videoclip data" message:[json objectForKey:@"error"]
                                                       delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    } */
}

@end
