//
//  DHLevelResults.m
//  Principia
//
//  Created by David Hallgren on 2014-06-30.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelResults.h"

NSString * const kLevelResultKeyCompleted = @"Completed";

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
    
    BOOL written = [[self mutableLevelResults] writeToFile:path atomically:YES];
    if (written) {
        //NSLog(@"Wrote to file %@", path);
    } else {
        //NSLog(@"Unable to write to file: %@", path);
    }
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

+ (void)newResult:(NSDictionary*)result forLevel:(NSString*)level
{
    NSMutableDictionary* results = [self mutableLevelResults];
    NSDictionary* previousResult = [results objectForKey:level];
    if (previousResult) {
        // Change
        [results removeObjectForKey:level];
        [results setObject:result forKey:level];
    } else {
        [results setObject:result forKey:level];
    }
    [self saveLevelResults];
}

@end
