//
//  DHLevel1.m
//  Principia
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevel1.h"

@implementation DHLevel1

- (NSString*)title
{
    return @"Challenge 1";
}

- (NSString*)subTitle
{
    return @"Intersecting lines";
}

- (NSString*)levelDescription
{
    return @"Create 2 different lines which intersect";
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHLineToolAvailable | DHRayToolAvailable | DHCircleToolAvailable |
            DHIntersectToolAvailable | DHMoveToolAvailable);
}

- (void)setUpLevel:(NSMutableArray *)geometricObjects
{
    //DHPoint* point = [[DHPoint alloc] initWithPositionX:200 andY:200];
    //[geometricObjects addObject:point];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    if (geometricObjects.count < 2) {
        return NO;
    }
    
    for (int index1 = 0; index1 < geometricObjects.count-1; ++index1) {
        id object1 = [geometricObjects objectAtIndex:index1];
        if ([[object1 class] isSubclassOfClass:[DHLine class]] == NO) continue;
        
        for (int index2 = index1+1; index2 < geometricObjects.count; ++index2) {
            id object2 = [geometricObjects objectAtIndex:index2];
            if ([[object2 class] isSubclassOfClass:[DHLine class]] == NO) continue;
            
            DHLine* l1 = object1;
            DHLine* l2 = object2;
            
            if (DoLinesIntersect(l1, l2)) {
                return YES;
            }
        }
    }
    
    return NO;
}

@end
