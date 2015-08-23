//
//  DHLevelResults.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-30.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelResults.h"
#import "DHLevels.h"

NSString * const kLevelResultKeyCompleted = @"Completed";
NSString * const kLevelResultKeyMinimumMoves = @"MinimumMoves";

static NSMutableDictionary* s_LevelResults;

@implementation DHLevelResults

#pragma mark - Private helper methods

+ (NSMutableDictionary*)mutableLevelResults
{
    if (s_LevelResults) {
        return s_LevelResults;
    }
    
    NSString* path = [self levelResultsDataPath];
    s_LevelResults = [[NSMutableDictionary dictionaryWithContentsOfFile:path] mutableCopy];
    
    // If no previous level data was found, create an empty dictionary
    if (!s_LevelResults) {
        s_LevelResults = [[NSMutableDictionary alloc] init];
    }
    
    return s_LevelResults;
}

+ (NSString*)levelResultsDataPath
{
    // Create path for level data file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths firstObject];
    if (!directory) {
        return nil;
    }
    NSString *path = [[NSString alloc] initWithString:directory];
    path = [path stringByAppendingPathComponent:@"LevelResultsData.plist"];
    return path;
}

+ (void)saveLevelResults
{
    NSString* path = [self levelResultsDataPath];
    if (!path) {
        return;
    }
    
    [[self mutableLevelResults] writeToFile:path atomically:YES];
}
#pragma mark - Manage level results data
+ (NSDictionary*)levelResults
{
    return [self mutableLevelResults];
}

+ (void)clearLevelResults
{
    [self.mutableLevelResults removeAllObjects];
    [self saveLevelResults];
}

+ (void)newResult:(NSMutableDictionary*)result forLevel:(NSString*)level
{
    NSMutableDictionary* results = [self mutableLevelResults];
    NSDictionary* previousResult = [results objectForKey:level];
    if (previousResult) {
        // Change
        [results removeObjectForKey:level];
        
        // Ensure new result does not downgrade previous
        NSNumber* completed = [previousResult objectForKey:kLevelResultKeyCompleted];
        NSNumber* minimumMoves = [previousResult objectForKey:kLevelResultKeyMinimumMoves];
        if (completed.boolValue) {
            [result setObject:[NSNumber numberWithBool:YES] forKey:kLevelResultKeyCompleted];
        }
        if (minimumMoves.boolValue) {
            [result setObject:[NSNumber numberWithBool:YES] forKey:kLevelResultKeyMinimumMoves];
        }
        
        [results setObject:result forKey:level];
    } else {
        [results setObject:result forKey:level];
    }
    [self saveLevelResults];
}

+ (NSUInteger)numberOfLevesCompletedForGameMode:(NSUInteger)gameMode
{
    NSUInteger levelsCompleted = 0;
    
    NSMutableArray* levels = [[NSMutableArray alloc] init];
    FillLevelArray(levels);
    NSDictionary* results = [self levelResults];
    
    for (id level in levels) {
        NSString* resultKey = [NSStringFromClass([level class]) stringByAppendingFormat:@"/%lu",
                               (unsigned long)gameMode];
        NSDictionary* levelResult = [results objectForKey:resultKey];
        if (levelResult) {
            NSNumber* completed = [levelResult objectForKey:kLevelResultKeyCompleted];
            if (completed.boolValue) {
                levelsCompleted++;
            }
        }
    }
    
    return levelsCompleted;
}

@end
