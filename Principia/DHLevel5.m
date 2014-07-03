//
//  DHLevel5.m
//  Principia
//
//  Created by David Hallgren on 2014-07-02.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevel5.h"

#import <CoreGraphics/CGBase.h>
#import "DHGeometricObjects.h"

@interface DHLevel5 () {
    DHLine* _lineAB;
    DHLine* _lineAC;
}

@end

@implementation DHLevel5

- (NSString*)title
{
    return @"Challenge 5";
}

- (NSString*)subTitle
{
    return @"Bisecting an angle";
}

- (NSString*)levelDescription
{
    return @"Create a line segment that divides the angle between segments AB and AC in half (bisects)";
}

- (void)setUpLevel:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:300 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:500 andY:300];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:400 andY:200];
    
    DHLine* l1 = [[DHLine alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    DHLine* l2 = [[DHLine alloc] init];
    l2.start = p1;
    l2.end = p3;
    
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    [geometricObjects addObject:p3];
    [geometricObjects addObject:l1];
    [geometricObjects addObject:l2];
    
    _lineAB = l1;
    _lineAC = l2;
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([object class]  != [DHLine class]) continue;
        if (object == _lineAB || object == _lineAC) continue;
        
        DHLine* l = object;
        
        CGVector ab = _lineAB.vector;
        CGVector ac = _lineAC.vector;

        CGFloat targetAngle = CGVectorAngleBetween(ab, ac) * 0.5;
        CGFloat angleToAB = CGVectorAngleBetween(l.vector, ab);
        CGFloat angleToAC = CGVectorAngleBetween(l.vector, ac);
        
        //Compare angle to both initial lines and ensure = 0.5*
        
        if (CGFloatsEqualWithinEpsilon(angleToAB, targetAngle) &&
            CGFloatsEqualWithinEpsilon(angleToAC, targetAngle)) {
            return YES;
        }
    }
    
    return NO;
}


@end
