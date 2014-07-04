//
//  DHLevel2.m
//  Principia
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelEquiTri.h"

@implementation DHLevelEquiTri

- (NSString*)title
{
    return @"Challenge 2";
}

- (NSString*)subTitle
{
    return @"Making triangles";
}

- (NSString*)levelDescription
{
    return @"Create 3 lines forming an equilateral triangle (a triangle whose sides all are of equal length)";
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHLineToolAvailable | DHRayToolAvailable | DHCircleToolAvailable |
            DHIntersectToolAvailable | DHMoveToolAvailable);
}

- (void)setUpLevel:(NSMutableArray *)geometricObjects
{
    
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    if (geometricObjects.count < 3) {
        return NO;
    }
    
    for (int index1 = 0; index1 < geometricObjects.count-2; ++index1) {
        id object1 = [geometricObjects objectAtIndex:index1];
        if ([[object1 class] isSubclassOfClass:[DHLine class]] == NO) continue;
        
        for (int index2 = index1+1; index2 < geometricObjects.count-1; ++index2) {
            id object2 = [geometricObjects objectAtIndex:index2];
            if ([[object2 class] isSubclassOfClass:[DHLine class]] == NO) continue;
            
            for (int index3 = index2+1; index3 < geometricObjects.count; ++index3) {
                id object3 = [geometricObjects objectAtIndex:index3];
                if ([[object3 class] isSubclassOfClass:[DHLine class]] == NO) continue;
                
                DHLine* l1 = object1;
                DHLine* l2 = object2;
                DHLine* l3 = object3;
                
                CGFloat length1 = l1.length;
                CGFloat length2 = l2.length;
                CGFloat length3 = l3.length;
                
                // Ensure all lines are different
                if (AreLinesEqual(l1, l2) || AreLinesEqual(l1, l3) || AreLinesEqual(l2, l3)) {
                    continue;
                }
                
                // Ensure all lines are connected and of same length
                BOOL connected = AreLinesConnected(l1,l2) && AreLinesConnected(l2,l3) && AreLinesConnected(l3,l1);
                if (connected &&
                    CGFloatsEqualWithinEpsilon(length1, length2) &&
                    CGFloatsEqualWithinEpsilon(length2, length3)) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}


@end
