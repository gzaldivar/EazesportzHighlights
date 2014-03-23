//
//  eazesportzAppDelegate.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 1/29/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzAppDelegate.h"
#import "EazesportzRetrieveSport.h"
#import "eazesportzLoginViewController.h"
#import "eazesportzScheduleBroadcastViewController.h"
#import "eazesportzLiveVideoViewController.h"

#import "eazesportzSelectTeamWindowController.h"
#import "eazesportzBroadcastPreferencesWindowController.h"

#import <AWSiOSSDK/AmazonErrorHandler.h>

@interface  eazesportzAppDelegate()

@property (nonatomic, strong) IBOutlet eazesportzLoginViewController *loginViewController;
@property (nonatomic, strong) IBOutlet eazesportzScheduleBroadcastViewController *broadcastScheduleController;
@property (nonatomic, strong) IBOutlet eazesportzLiveVideoViewController *liveVideoController;
@property (nonatomic, strong) IBOutlet eazesportzBroadcastPreferencesWindowController *preferencesController;

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
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginResult:)
                                                 name:@"LoginSuccessfulNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(homeView:)
                                                 name:@"DisplayMainViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liveVideoView:)
                                                 name:@"LiveVideoViewNotification" object:nil];
    
    [self.window setBackgroundColor:[NSColor colorWithPatternImage:[NSImage imageNamed:@"Footballbkg.png"]]];
    _window = self.window;
    
    self.loginViewController =
                [[eazesportzLoginViewController alloc] initWithNibName:@"eazesportzLoginViewController" bundle:nil];
    
    [self.loginViewController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self resizeWindowForContentSize:[self.loginViewController.view frame].size];
    [self.window.contentView addSubview:self.loginViewController.view];
}
// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "eazesportz.com.Eazesportz_Broadcast_Console" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"eazesportz.com.Eazesportz_Broadcast_Console"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Eazesportz_Broadcast_Console" withExtension:@"momd"];
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
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Eazesportz_Broadcast_Console.storedata"];
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

- (IBAction)sdMenuItemClicked:(id)sender {
    [_sdmenuitem setState:NSOnState];
    [_hdmenuitem setState:NSOffState];
}

- (IBAction)hdMenuItemClicked:(id)sender {
    [_sdmenuitem setState:NSOffState];
    [_sdmenuitem setState:NSOnState];
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
        self.broadcastScheduleController =
            [[eazesportzScheduleBroadcastViewController alloc] initWithNibName:@"eazesportzScheduleBroadcastViewController" bundle:nil];
        self.broadcastScheduleController.sport = getSport.sport;
        self.broadcastScheduleController.user = self.loginViewController.user;

        [self.broadcastScheduleController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self resizeWindowForContentSize:[self.broadcastScheduleController.view frame].size];
        [self.window.contentView addSubview:self.broadcastScheduleController.view];
    }
}

- (void)homeView:(NSNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"Message"] isEqualToString:@"LiveView"]) {
        [self.liveVideoController.view removeFromSuperview];
    }
    
    [self.broadcastScheduleController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self resizeWindowForContentSize:[self.broadcastScheduleController.view frame].size];
    [self.window.contentView addSubview:self.broadcastScheduleController.view];
}

- (void)resizeWindowForContentSize:(NSSize)size {
    NSWindow *window = [self window];
    
    NSRect windowFrame = [window contentRectForFrameRect:[window frame]];
    NSRect newWindowFrame = [window frameRectForContentRect:
                             NSMakeRect( NSMinX( windowFrame ), NSMaxY( windowFrame ) - size.height, size.width, size.height )];
    [window setFrame:newWindowFrame display:YES animate:[window isVisible]];
}

/*
- (void)scheduleBroadcast:(NSNotification *)notification {
    [self.processVideoController.view removeFromSuperview];
    self.broadcastScheduleController = [[eazesportzScheduleBroadcastViewController alloc]
                                        initWithNibName:@"eazesportzScheduleBroadcastViewController" bundle:nil];
    self.broadcastScheduleController.user = self.loginViewController.user;
    self.broadcastScheduleController.sport = getSport.sport;
    
    [self.broadcastScheduleController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self resizeWindowForContentSize:[self.broadcastScheduleController.view frame].size];
    [self.window.contentView addSubview:self.broadcastScheduleController.view];
}
 */

- (void)liveVideoView:(NSNotification *)notification {
    self.liveVideoController = [[eazesportzLiveVideoViewController alloc] initWithNibName:@"eazesportzLiveVideoViewController" bundle:nil];
    [self.broadcastScheduleController.view removeFromSuperview];
    self.liveVideoController.user = self.loginViewController.user;
    self.liveVideoController.sport = getSport.sport;
    self.liveVideoController.team = self.broadcastScheduleController.team;
    self.liveVideoController.event = self.broadcastScheduleController.event;
    
    [self.liveVideoController.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self resizeWindowForContentSize:[self.liveVideoController.view frame].size];
    [self.window.contentView addSubview:self.liveVideoController.view];
}

- (IBAction)preferencesButtonClicked:(id)sender {
    if (self.loginViewController.user.userid.length > 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesChanged:) name:@"PreferencesChangedNotification" object:nil];
        self.preferencesController = [[eazesportzBroadcastPreferencesWindowController alloc] initWithWindowNibName:@"eazesportzBroadcastPreferencesWindowController"];
        self.preferencesController.sport = getSport.sport;
        self.preferencesController.user = self.loginViewController.user;
        [self.preferencesController showWindow:self];
    }
}

- (void)preferencesChanged:(NSNotification *)notification {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Success" defaultButton:@"OK" alternateButton:nil
                                       otherButton:nil informativeTextWithFormat:@"Broadcast preferences updated"];
    [alert setIcon:[getSport.sport getImage:@"tiny"]];
    [alert runModal];
}

@end
