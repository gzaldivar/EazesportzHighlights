//
//  eazesportzAppDelegate.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 1/29/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface eazesportzAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

- (IBAction)sdMenuItemClicked:(id)sender;
- (IBAction)hdMenuItemClicked:(id)sender;
@property (weak) IBOutlet NSMenuItem *hdmenuitem;
@property (weak) IBOutlet NSMenuItem *sdmenuitem;
- (IBAction)preferencesButtonClicked:(id)sender;

@end
