//
//  eazesportzLoginViewController.h
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/2/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "User.h"

@interface eazesportzLoginViewController : NSViewController
@property (weak) IBOutlet NSTextField *emailTextField;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;
- (IBAction)loginButtonClicked:(id)sender;
@property (weak) IBOutlet NSTextField *welcomeLabel;

@property (nonatomic, strong) User *user;

@end
