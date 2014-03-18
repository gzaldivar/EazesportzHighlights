//
//  eazesportzLoginViewController.m
//  Eazesportz Broadcast Console
//
//  Created by Gilbert Zaldivar on 2/2/14.
//  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.
//

#import "eazesportzLoginViewController.h"
#import "EazesportzLogin.h"

@interface eazesportzLoginViewController ()

@end

@implementation eazesportzLoginViewController {
    EazesportzLogin *login;
}

@synthesize user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)loadView {
    [super loadView];
    _welcomeLabel.stringValue = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"WelcomeMessage"];
    
    login = [[EazesportzLogin alloc] init];
}

- (IBAction)loginButtonClicked:(id)sender {
    if ((_emailTextField.stringValue.length > 0) && (_passwordTextField.stringValue.length > 0)) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginResult:)
                                                     name:@"LoginNotification" object:nil];
        [login Login:_emailTextField.stringValue Password:_passwordTextField.stringValue];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error"
                            defaultButton:@"OK" alternateButton:nil otherButton:nil
                             informativeTextWithFormat:@"Email and Password Required!"];
        [alert runModal];
    }
}

- (void)loginResult:(NSNotification *)notification {
    if ([[[notification userInfo] objectForKey:@"Result"] isEqualToString:@"Success"]) {
        user = login.user;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccessfulNotification" object:nil];
        [self.view removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil
                                    otherButton:nil informativeTextWithFormat:[[notification userInfo] objectForKey:@"Result"]];
        [alert runModal];
    }
}

@end
