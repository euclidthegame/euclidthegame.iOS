//
//  DHLevel3.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelSquare.h"
#import <CoreGraphics/CGBase.h>

@interface DHLevelSquare () {
    DHCircle* _initialCircle;
}

@end

@implementation DHLevelSquare

- (NSString*)levelDescription
{
    return @"Create 4 lines forming a square whose diagonal is equal to the radius of the circle";
}

- (NSUInteger)minimumNumberOfMoves
{
    return 6;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
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
        if ([[object1 class] isSubclassOfClass:[DHLineSegment class]] == NO) continue;
        
        for (int index2 = index1+1; index2 < geometricObjects.count-2; ++index2) {
            id object2 = [geometricObjects objectAtIndex:index2];
            if ([[object2 class] isSubclassOfClass:[DHLineSegment class]] == NO) continue;
            
            for (int index3 = index2+1; index3 < geometricObjects.count-1; ++index3) {
                id object3 = [geometricObjects objectAtIndex:index3];
                if ([[object3 class] isSubclassOfClass:[DHLineSegment class]] == NO) continue;
                
                for (int index4 = index3+1; index4 < geometricObjects.count; ++index4) {
                    id object4 = [geometricObjects objectAtIndex:index4];
                    if ([[object4 class] isSubclassOfClass:[DHLineSegment class]] == NO) continue;
                    
                    DHLineSegment* l1 = object1;
                    DHLineSegment* l2 = object2;
                    DHLineSegment* l3 = object3;
                    DHLineSegment* l4 = object4;
                    
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
