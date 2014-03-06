//
//  EazesportzRetrieveGames.h
//  EazeSportz
//
//  Created by Gil on 1/9/14.
//  Copyright (c) 2014 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"

@interface EazesportzRetrieveGames : NSObject

- (void)retrieveGames:(Sport *)sport Team:(NSString *)teamid Token:(NSString *)authtoken;

@property(nonatomic, strong, readonly) NSMutableArray *gameList;

@end
