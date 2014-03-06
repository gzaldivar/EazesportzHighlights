//
//  EazesportzLogin.h
//  EazeSportz
//
//  Created by Gil on 1/10/14.
//  Copyright (c) 2014 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "User.h"

@interface EazesportzLogin : NSObject

- (void)Login:(NSString *)email Password:(NSString *)password;
- (void)Login:(NSString *)email Password:(NSString *)password Site:(NSString *)site;

@property (nonatomic, strong) User *user;

@end
