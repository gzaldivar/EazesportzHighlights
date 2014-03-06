//
//  eazesportzVideoFileWindowController.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 3/1/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzVideoFileWindowController.h"
#import "EazesportzRetrieveVideos.h"

@interface eazesportzVideoFileWindowController ()

@end

@implementation eazesportzVideoFileWindowController {
    EazesportzRetrieveVideos *getVideos;
}

@synthesize sport;
@synthesize team;
@synthesize game;
@synthesize user;
@synthesize video;
@synthesize event;

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
    getVideos = [[EazesportzRetrieveVideos alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotVideos:) name:@"VideoListChangedNotification" object:nil];
    _teamLabel.stringValue = team.team_name;
    
    if (game)
        _gameLabel.stringValue = [game vsOpponent];
    
    [getVideos retrieveVideos:sport Team:team Game:game User:user];
    
    [_activityIndicator setDisplayedWhenStopped:YES];
    _activityIndicator.hidden = NO;
    [_activityIndicator startAnimation:self];
}

- (void)gotVideos:(NSNotification *)notification {
    [_activityIndicator stopAnimation:self];
    _activityIndicator.hidden = YES;
    [_videoTableView reloadData];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    Video *avideo = [getVideos.videos objectAtIndex:row];
    
    if( [tableColumn.identifier isEqualToString:@"HiddenTableColumn"] ) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"VideoTextTableCell" owner:self];
       
        cellView.textField.stringValue = [self convertTimeFromSeconds:[NSString stringWithFormat:@"%d", [avideo.duration intValue]]];
        
/*        if (avideo.hidden)
            cellView.textField.stringValue = @"True";
        else
            cellView.textField.stringValue = @"False"; */
        
        return cellView;
    } else if ([tableColumn.identifier isEqualToString:@"GameTableColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"OpponentTextTableCell" owner:self];
        
        if (avideo.game)
            cellView.textField.stringValue = [avideo.game opponent_mascot];
        else
            cellView.textField.stringValue = @"";
        
        return cellView;
    } else {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"VideoTableCell" owner:self];
        cellView.imageView.image = [avideo posterImage];
        cellView.textField.stringValue = avideo.displayName;
                
        return  cellView;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return getVideos.videos.count;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    if ([_videoTableView selectedRow] >= 0) {
        NSInteger videoselected = [_videoTableView selectedRow];
        video = [getVideos.videos objectAtIndex:videoselected];
        [self downloadVideo];
    }
}

- (void)downloadVideo {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];

    [openDlg setPrompt:@"Select Directory"];

    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setCanChooseFiles:NO];
    [openDlg setFloatingPanel:YES];
    
    [openDlg beginWithCompletionHandler:^(NSInteger result){
        NSArray* files = [openDlg URLs];
        NSData *data;
        NSString *filepath = [[files objectAtIndex:0] path];
        filepath = [filepath stringByAppendingPathComponent:video.displayName];
        
        NSURL *url = [[NSURL alloc] initFileURLWithPath:filepath];
        _downloadFileLabel.stringValue = [url path];
        
        if (url) {
            _activityIndicator.hidden = NO;
            [_activityIndicator startAnimation:self];
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:video.video_url]];
            NSLog(@"%@",filepath);
            //do something with the file at filePath
            
            if (data) {
                [data writeToFile:[url path] atomically:YES];
            }
            
            event.eventurl = [url path];
            
            _activityIndicator.hidden = YES;
            [_activityIndicator stopAnimation:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoDownloadedNotification" object:nil];
            [self.window close];
        }
    }];
    
}

- (NSString *)convertTimeFromSeconds:(NSString *)seconds {
    
    // Return variable.
    NSString *result = @"";
    
    // Int variables for calculation.
    int secs = [seconds intValue];
    int tempHour    = 0;
    int tempMinute  = 0;
    int tempSecond  = 0;
    
    NSString *hour      = @"";
    NSString *minute    = @"";
    NSString *second    = @"";
    
    // Convert the seconds to hours, minutes and seconds.
    tempHour    = secs / 3600;
    tempMinute  = secs / 60 - tempHour * 60;
    tempSecond  = secs - (tempHour * 3600 + tempMinute * 60);
    
    hour    = [[NSNumber numberWithInt:tempHour] stringValue];
    minute  = [[NSNumber numberWithInt:tempMinute] stringValue];
    second  = [[NSNumber numberWithInt:tempSecond] stringValue];
    
    // Make time look like 00:00:00 and not 0:0:0
    if (tempHour < 10) {
        hour = [@"0" stringByAppendingString:hour];
    }
    
    if (tempMinute < 10) {
        minute = [@"0" stringByAppendingString:minute];
    }
    
    if (tempSecond < 10) {
        second = [@"0" stringByAppendingString:second];
    }
    
    if (tempHour == 0) {
        
        NSLog(@"Result of Time Conversion: %@:%@", minute, second);
        result = [NSString stringWithFormat:@"%@:%@", minute, second];
        
    } else {
        
        NSLog(@"Result of Time Conversion: %@:%@:%@", hour, minute, second);
        result = [NSString stringWithFormat:@"%@:%@:%@",hour, minute, second];
        
    }
    
    return result;
    
}

@end
