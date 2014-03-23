//
//  eazesportzCameraWindowController.m
//  EazesportzHighlights
//
//  Created by Gil on 3/21/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzCameraWindowController.h"

@interface eazesportzCameraWindowController ()

@end

@implementation eazesportzCameraWindowController {
    NSArray *devices;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];

    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
            }
            else {
                NSLog(@"Device position : front");
            }
        }
    }
    [_cameraTableView reloadData];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    AVCaptureDevice *device = [devices objectAtIndex:row];
    // Get an existing cell with the MyView identifier if it exists
    
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"CameraCell" owner:self];
    
    if ([tableColumn.identifier isEqualToString:@"CameraColumn"]) {
        cellView.textField.stringValue = [device localizedName];
    }
    
    return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return devices.count;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    if ([_cameraTableView selectedRow] >= 0) {
        NSInteger selectedCamera = [_cameraTableView selectedRow];
        _camera = [devices objectAtIndex:selectedCamera];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CameraSelectedNotification" object:nil
                                                          userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"Camera", @"Result", nil]];
    }
}

@end
