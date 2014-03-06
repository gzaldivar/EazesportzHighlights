//
//  eazesportzUploadHLStoS3.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/22/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzUploadHLStoS3.h"

#import <AWSiOSSDK/S3/S3Bucket.h>
#import <AWSiOSSDK/S3/AmazonS3Client.h>

@implementation eazesportzUploadHLStoS3 {
    AmazonS3Client *s3;
    NSString *bucket;
    NSString *videoname;
}

@synthesize videopipe;
@synthesize videoname;
@synthesize user;

- (void)main {
    bucket = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"s3bucket"];
    // Initialize the S3 Client.
    s3 = [[AmazonS3Client alloc] initWithAccessKey:user.awskeyid withSecretKey:user.awssecretkey];
    [self writeHLSFileToS3];
}

- (void)writeHLSFileToS3 {
    NSFileManager *filemgr;
    
    filemgr = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"transcode-errors.txt"];
    
    if (![filemgr fileExistsAtPath:filePath] == YES)
        [filemgr createFileAtPath:filePath contents:nil attributes:nil];
    
    NSFileHandle *file;
    int filecounter = 0;

    for(;;) {
        @try {
            
            S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:@"foo.jpg" inBucket:bucket];
            por.contentType = @"video/mp4";
            por.contentDisposition = @"inline";
    //        por.data = photoData;
            [s3 putObject:por];
        }
        @catch ( AmazonServiceException *exception ) {
            NSLog( @"Upload Failed, Reason: %@", exception );
        }
    }
}

@end
