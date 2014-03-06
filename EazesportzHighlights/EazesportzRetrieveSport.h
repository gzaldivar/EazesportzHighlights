//
//  EazesportzRetrieveSport.h
//  EazeSportz
//
//  Created by Gil on 1/9/14.
//  Copyright (c) 2014 Gil. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sport.h"

@interface EazesportzRetrieveSport : NSObject

@property(nonatomic, strong) Sport *sport;

- (void)retrieveSport:(NSString *)sportid Token:(NSString *)authtoken;

@end
