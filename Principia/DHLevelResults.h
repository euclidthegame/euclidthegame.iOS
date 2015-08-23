//
//  DHLevelResults.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-30.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <Foundation/Foundation.h>
#import "DHGameModes.h"

extern NSString* const kLevelResultKeyCompleted;
extern NSString* const kLevelResultKeyMinimumMoves;

@interface DHLevelResults : NSObject

+ (NSDictionary*)levelResults;
+ (void)clearLevelResults;
+ (void)newResult:(NSMutableDictionary*)result forLevel:(NSString*)level;
+ (NSUInteger)numberOfLevesCompletedForGameMode:(NSUInteger)gameMode;

@end
