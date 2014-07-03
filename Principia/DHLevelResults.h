//
//  DHLevelResults.h
//  Principia
//
//  Created by David Hallgren on 2014-06-30.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kLevelResultKeyCompleted;

@interface DHLevelResults : NSObject

+ (NSDictionary*)levelResults;
+ (void)clearLevelResults;
+ (void)newResult:(NSDictionary*)result forLevel:(NSString*)level;

@end
