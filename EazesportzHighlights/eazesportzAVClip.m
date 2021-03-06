//
//  eazesportzAVClip.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/11/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzAVClip.h"

@implementation eazesportzAVClip

@synthesize clipNumber;
@synthesize clipName;
@synthesize clip;
@synthesize awsposterobject;
@synthesize awsvideoobject;
@synthesize video;
@synthesize posterImage;
@synthesize uploaded;

- (id)init {
    if (self = [super init]) {
        self.video = [[Video alloc] init];
        uploaded = NO;
        return self;
    } else
        return nil;
}

@end
