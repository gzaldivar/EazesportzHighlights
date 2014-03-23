//
//  eazesportzAppDelegate.m
//  EazesportzHighlights
//
//  Created by Gilbert Zaldivar on 3/4/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzAppDelegate.h"

#import "EazesportzRetrieveSport.h"
#import "eazesportzMasterViewController.h"
#import "eazesportzLoginViewController.h"
#import "eazesportzPlayerViewController.h"
#import "eazesportzMainViewController.h"
#import "eazesportzLiveHighlightViewController.h"
#import "eazesportzSelectLiveHighlightsViewController.h"
#import "eazesportzHighlightsPreferencesWindowController.h"

#import "eazesportzSelectTeamWindowController.h"

#import <AWSiOSSDK/AmazonErrorHandler.h>

@interface  eazesportzAppDelegate()

@property (nonatomic, strong) IBOutlet eazesportzMasterViewController *masterViewController;
@property (nonatomic, strong) IBOutlet eazesportzLoginViewController *loginViewController;
@property (nonatomic, strong) IBOutlet eazesportzPlayerViewController *playerController;
@property (nonatomic, strong) IBOutlet eazesportzMainViewController *processVideoController;
@property (nonatomic, strong) IBOutlet eazesportzLiveHighlightViewController *liveHighlightsController;
@property (nonatomic, strong) IBOutlet eazesportzSelectLiveHighlightsViewController *selectLiveHighlightsController;
@property (nonatomic, strong) IBOutlet eazesportzHighlightsPreferencesWindowController *highlightsPreferencesController;

@end

@implementation eazesportzAppDelegate {
    EazesportzRetrieveSport *getSport;
    NSString *teamSelectRequest;
}

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [AmazonErrorHandler shouldNotThrowExceptions];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginResult:) name:@"LoginSuccessfulNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPlayerView:) name:@"PlayerReadyNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processVideoView:) name:@"DisplayProcessVideoNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(homeView:) name:@"DisplayMainViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liveHighlights:) name:@"CreateLiveHighlightsNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(highlightClips:) name:@"DisplayLiveHighlightsNotification" object:nil];
    
    [self.window setBackgroundColor:[NSColor colorWithPatternImage:[NSImage imageNamed:@"Footballbkg.png"]]];
    _window = self.window;
    
    self.loginViewController = [[eazesportzLoginViewController alloc] initWithNibName:@"eazesportzLoginViewController" bundle:nil];
    
    [self.loginViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self resizeWindowForContentSize:[self.loginViewController.view frame].size];
    [self.window.contentView addSubview:self.loginViewController.view];
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "eazesportz.com.EazesportzHighlights" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"eazesportz.com.EazesportzHighlights"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"EazesportzHighlights" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"EazesportzHighlights.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction)preferencesMenuItemClicked:(id)sender {
    if (self.loginViewController.user.userid.length > 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesChanged:) name:@"PreferencesChangedNotification" object:nil];
        self.highlightsPreferencesController = [[eazesportzHighlightsPreferencesWindowController alloc] initWithWindowNibName:@"eazesportzHighlightsPreferencesWindowController"];
        self.highlightsPreferencesController.sport = getSport.sport;
        self.highlightsPreferencesController.user = self.loginViewController.user;
        [self.highlightsPreferencesController showWindow:self];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (void)loginResult:(NSNotification *)notification {
    //    [_loginWindow close];
    getSport = [[EazesportzRetrieveSport alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotSport:) name:@"SportChangedNotification"
                                               object:nil];
    [getSport retrieveSport:_loginViewController.user.default_site Token:_loginViewController.user.authtoken];
}

- (void)gotSport:(NSNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"Result"] isEqualToString:@"Success"]) {
        [self.loginViewController.view removeFromSuperview];
        self.processVideoController = [[eazesportzMainViewController alloc] initWithNibName:@"eazesportzMainViewController" bundle:nil];
        self.processVideoController.sport = getSport.sport;
        
        [self.processVideoController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self resizeWindowForContentSize:[self.processVideoController.view frame].size];
        [self.window.contentView addSubview:self.processVideoController.view];
        
        if (![getSport.sport.highlightAppVersion isEqualToString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"Dismiss"];
            [alert addButtonWithTitle:@"Download"];
            [alert setInformativeText:@"A newer version is available. Please visit Eazesportz.com to down load it!"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert setIcon:[getSport.sport getImage:@"tiny"]];
            [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        }
    }
}

- (void) alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if (returnCode == NSAlertSecondButtonReturn) {
        NSString *downloaddir = [NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dmgpath = [NSString stringWithFormat:@"%@/%@", downloaddir, @"EazesportzHighlights.dmg"];
        NSData *dmgdata = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", getSport.sport.streamingurl, @"EazesportzHighlights.dmg"]]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dmgpath])
            [[NSFileManager defaultManager] createFileAtPath:dmgpath contents:dmgdata attributes:nil];
        else {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                               otherButton:nil informativeTextWithFormat:@"EazesportzHighlights.dmg exists in your downloads directory. Please delete the old one."];
            [alert setIcon:[getSport.sport getImage:@"tiny"]];
            [alert runModal];
        }
    }
}

- (void)homeView:(NSNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"Message"] isEqualToString:@"VideoClipView"]) {
        [self.playerController.view removeFromSuperview];
        self.playerController = nil;
    } else if ([[[notification userInfo] objectForKey:@"Message"] isEqualToString:@"SelectOpponentView"]) {
        [self.masterViewController.view removeFromSuperview];
    } else if ([[[notification userInfo] objectForKey:@"Message"] isEqualToString:@"LiveView"]) {
        [self.liveHighlightsController.view removeFromSuperview];
        self.liveHighlightsController = nil;
    } else if ([[[notification userInfo] objectForKey:@"Message"] isEqualToString:@"SelectHighlightView"]) {
        [self.selectLiveHighlightsController.view removeFromSuperview];
        self.selectLiveHighlightsController = nil;
    }
    
    [self.processVideoController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self resizeWindowForContentSize:[self.processVideoController.view frame].size];
    [self.window.contentView addSubview:self.processVideoController.view];
}

- (void)resizeWindowForContentSize:(NSSize)size {
    NSWindow *window = [self window];
    
    NSRect windowFrame = [window contentRectForFrameRect:[window frame]];
    NSRect newWindowFrame = [window frameRectForContentRect:
                             NSMakeRect( NSMinX( windowFrame ), NSMaxY( windowFrame ) - size.height, size.width, size.height )];
    [window setFrame:newWindowFrame display:YES animate:[window isVisible]];
}

- (void)loadPlayerView:(NSNotification *)notification {
    [self.masterViewController.view removeFromSuperview];
    self.playerController = [[eazesportzPlayerViewController alloc] initWithNibName:@"eazesportzPlayerViewController" bundle:nil];
    self.playerController.videoUrl = self.masterViewController.videoUrl;
    self.playerController.game = self.masterViewController.game;
    self.playerController.team = self.masterViewController.team;
    self.playerController.sport = getSport.sport;
    self.playerController.user = self.loginViewController.user;
    self.playerController.getPlayers = self.masterViewController.getPlayers;
    self.playerController.highlightDate = [self.masterViewController.highlightDate dateValue];
    
    if ([self.highlightsPreferencesController.qualityComboBox.stringValue isEqualToString:@"SD"])
        self.playerController.highdef = NO;
    else
        self.playerController.highdef = YES;
    
    [self.playerController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self resizeWindowForContentSize:[self.playerController.view frame].size];
    [self.window.contentView addSubview:[self.playerController view]];
}

- (void)processVideoView:(NSNotification *)notification {
    [self.processVideoController.view removeFromSuperview];
    self.masterViewController = [[eazesportzMasterViewController alloc] initWithNibName:@"eazesportzMasterViewController" bundle:nil];
    self.masterViewController.sport = getSport.sport;
    self.masterViewController.user = self.loginViewController.user;
    
    [self.masterViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self resizeWindowForContentSize:[self.masterViewController.view frame].size];
    [self.window.contentView addSubview:self.masterViewController.view];
    self.masterViewController.masterWindow = self.window;
}

- (void)highlightClips:(NSNotification *)notification {
    [self.selectLiveHighlightsController.view removeFromSuperview];
    self.liveHighlightsController = [[eazesportzLiveHighlightViewController alloc] initWithNibName:@"eazesportzLiveHighlightViewController" bundle:nil];
    self.liveHighlightsController.sport = getSport.sport;
    self.liveHighlightsController.team = self.selectLiveHighlightsController.team;
    self.liveHighlightsController.user = self.loginViewController.user;
    self.liveHighlightsController.event = self.selectLiveHighlightsController.event;
    self.liveHighlightsController.getPlayers = self.selectLiveHighlightsController.getPlayers;
    [self.liveHighlightsController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self resizeWindowForContentSize:[self.liveHighlightsController.view frame].size];
    [self.window.contentView addSubview:self.liveHighlightsController.view];
}

- (void)liveHighlights:(NSNotification *)notification {
    [self.processVideoController.view removeFromSuperview];
    self.selectLiveHighlightsController = [[eazesportzSelectLiveHighlightsViewController alloc] initWithNibName:@"eazesportzSelectLiveHighlightsViewController" bundle:nil];
    self.selectLiveHighlightsController.sport = getSport.sport;
    self.selectLiveHighlightsController.user = self.loginViewController.user;
    [self.selectLiveHighlightsController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self resizeWindowForContentSize:[self.selectLiveHighlightsController.view frame].size];
    [self.window.contentView addSubview:self.selectLiveHighlightsController.view];
}

- (IBAction)preferencesButtonClicked:(id)sender {
}

- (void)preferencesChanged:(NSNotification *)notification {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Success" defaultButton:@"OK" alternateButton:nil
                                       otherButton:nil informativeTextWithFormat:@"Highlight preferences updated"];
    [alert setIcon:[getSport.sport getImage:@"tiny"]];
    [alert runModal];
}

@end
