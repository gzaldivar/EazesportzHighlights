//
//  eazesportzCameraWindowController.h
//  EazesportzHighlights
//
//  Created by Gil on 3/21/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@interface eazesportzCameraWindowController : NSWindowController

@property (weak) IBOutlet NSTableView *cameraTableView;
@property (weak) IBOutlet NSTextField *cameraLabel;

@property (nonatomic, strong, readonly) AVCaptureDevice *camera;

@end
