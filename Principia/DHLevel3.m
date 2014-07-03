//
//  DHLevel3.m
//  Principia
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevel3.h"
#import <CoreGraphics/CGBase.h>

@interface DHLevel3 () {
    DHCircle* _initialCircle;
}

@end

@implementation DHLevel3

- (NSString*)title
{
    return @"Challenge 3";
}

- (NSString*)subTitle
{
    return @"Squares";
}

- (NSString*)levelDescription
{
    return @"Create 4 lines forming a square whose diagonal is equal to the radius of the circle";
}

- (void)setUpLevel:(NSMutableArray *)geometricObjects
{
    DHCircle* c = [[DHCircle alloc] init];
    _initialCircle = c;
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:300 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:400 andY:300];
    c.center = p1;
    c.pointOnRadius = p2;
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    [geometricObjects addObject:c];
    
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    if (geometricObjects.count < 4) {
        return NO;
    }
    
    for (int index1 = 0; index1 < geometricObjects.count-3; ++index1) {
        id object1 = [geometricObjects objectAtIndex:index1];
        if ([[object1 class] isSubclassOfClass:[DHLine class]] == NO) continue;
        
        for (int index2 = index1+1; index2 < geometricObjects.count-2; ++index2) {
            id object2 = [geometricObjects objectAtIndex:index2];
            if ([[object2 class] isSubclassOfClass:[DHLine class]] == NO) continue;
            
            for (int index3 = index2+1; index3 < geometricObjects.count-1; ++index3) {
                id object3 = [geometricObjects objectAtIndex:index3];
                if ([[object3 class] isSubclassOfClass:[DHLine class]] == NO) continue;
                
                for (int index4 = index3+1; index4 < geometricObjects.count; ++index4) {
                    id object4 = [geometricObjects objectAtIndex:index4];
                    if ([[object4 class] isSubclassOfClass:[DHLine class]] == NO) continue;
                    
                    DHLine* l1 = object1;
                    DHLine* l2 = object2;
                    DHLine* l3 = object3;
                    DHLine* l4 = object4;
                    
                    CGFloat length1 = l1.length;
                    CGFloat length2 = l2.length;
                    CGFloat length3 = l3.length;
                    CGFloat length4 = l4.length;
                    
                    CGFloat targetLength = _initialCircle.radius/M_SQRT2;
                    
                    // Ensure all lines are different
                    if (AreLinesEqual(l1, l2) || AreLinesEqual(l1, l3) || AreLinesEqual(l1, l4) ||
                        AreLinesEqual(l2, l3) || AreLinesEqual(l2, l4) || AreLinesEqual(l3, l4)) {
                        continue;
                    }
                    
                    // Ensure all lines are of equal length to the circle radius
                    if ((CGFloatsEqualWithinEpsilon(length1, length2) &&
                         CGFloatsEqualWithinEpsilon(length2, length3) &&
                         CGFloatsEqualWithinEpsilon(length3, length4) &&
                         CGFloatsEqualWithinEpsilon(length3, targetLength)) == NO) {
                        continue;
                    }
                    
                    BOOL l1_l2_connected = AreLinesConnected(l1,l2);
                    
                    BOOL connected = NO;
                    
                    if (l1_l2_connected) {
                        connected = ((AreLinesConnected(l1,l3) && AreLinesConnected(l2,l4)) ^
                                     (AreLinesConnected(l1,l4) && AreLinesConnected(l2,l3)) &&
                                     AreLinesConnected(l3,l4));
                    } else {
                        connected = ((AreLinesConnected(l1,l3) && AreLinesConnected(l1,l4)) &&
                                     (AreLinesConnected(l2,l3) && AreLinesConnected(l2,l4)) &&
                                     AreLinesConnected(l3,l4) == NO);
                    }
                    
                    if (connected) {
                        return YES;
                    }
                }
            }
        }
    }
    
    return NO;
}


@end
