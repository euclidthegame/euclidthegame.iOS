//
//  DHLevel1.m
//  Principia
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevel1.h"

@implementation DHLevel1

- (NSString*)levelTitle
{
    return @"Challenge 1";
}

- (NSString*)levelDescription
{
    return @"Create 5 points";
}

- (void)setUpLevel:(NSMutableArray *)geometricObjects
{
    DHPoint* point = [[DHPoint alloc] initWithPositionX:200 andY:200];
    [geometricObjects addObject:point];
    
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    const NSUInteger targetPoints = 5;
    NSUInteger numberOfPointsInLevel = 0;
    for (id object in geometricObjects) {
        if ([object class] == [DHPoint class]) {
            ++numberOfPointsInLevel;
        }
    }
    
    if (numberOfPointsInLevel >= targetPoints) {
        return YES;
    }
    
    return NO;
}

@end
