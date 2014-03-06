//
//  eazesportzBroadcastScheduleTableCellView.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/21/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface eazesportzBroadcastScheduleTableCellView : NSTableCellView

@property (weak) IBOutlet NSImageView *broadcastImage;
@property (weak) IBOutlet NSTextField *eventTitle;
@property (weak) IBOutlet NSTextField *durationLabel;
@property (weak) IBOutlet NSTextField *opponent;

@end
