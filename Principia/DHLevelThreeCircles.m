//
//  DHLevelThreeCircles.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-09.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelThreeCircles.h"

#import "DHGeometricObjects.h"

@interface DHLevelThreeCircles () {
    DHLineSegment* _lAB;
    DHCircle* _circle1;
}

@end

@implementation DHLevelThreeCircles

- (NSString*)subTitle
{
    return @"Stacking circles";
}

- (NSString*)levelDescription
{
    return (@"Construct two new circles of radius AB where each pair of the three circles is tangent. "
            @"One of the two circles must also touch point B.");
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable | DHTranslateToolAvailable |
            DHCompassToolAvailable);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 4;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 5;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:300 andY:350];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:400 andY:350];
    
    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:pA andEnd:pB];
    DHCircle* c1 = [[DHCircle alloc] init];
    c1.center = pA;
    c1.pointOnRadius = pB;
    
    [geometricObjects addObject:lAB];
    [geometricObjects addObject:c1];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    
    _lAB = lAB;
    _circle1 = c1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    CGPoint pc1Pos = _circle1.center.position;
    
    DHTranslatedPoint* pc2 = [[DHTranslatedPoint alloc] init];
    pc2.startOfTranslation = _lAB.end;
    pc2.translationStart = _lAB.start;
    pc2.translationEnd = _lAB.end;
    
    DHCircle* c2 = [[DHCircle alloc] initWithCenter:pc2 andPointOnRadius:_lAB.end];
    [objects insertObject:c2 atIndex:0];
    
    CGVector vAC2 = CGVectorBetweenPoints(_lAB.start.position, c2.center.position);
    CGVector vAC3 = CGVectorRotateByAngle(vAC2, M_PI/3.0);
    
    DHPoint* pc3 = [[DHPoint alloc] initWithPositionX:pc1Pos.x+vAC3.dx andY:pc1Pos.y - vAC3.dy];
    DHPoint* pc3r = [[DHPoint alloc] initWithPositionX:pc1Pos.x+0.5*vAC3.dx andY:pc1Pos.y - 0.5*vAC3.dy];
    
    DHCircle* c3 = [[DHCircle alloc] initWithCenter:pc3 andPointOnRadius:pc3r];
    [objects insertObject:c3 atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _lAB.start.position;
    CGPoint pointB = _lAB.end.position;
    
    _lAB.start.position = CGPointMake(pointA.x - 10, pointA.y - 10);
    _lAB.end.position = CGPointMake(pointB.x + 10, pointB.y + 10);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _lAB.start.position = pointA;
    _lAB.end.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    if (geometricObjects.count < 3) {
        return NO;
    }
    
    for (int index2 = 0; index2 < geometricObjects.count-1; ++index2) {
        id object2 = [geometricObjects objectAtIndex:index2];
        if ([[object2 class] isSubclassOfClass:[DHCircle class]] == NO) continue;
        
        for (int index3 = index2+1; index3 < geometricObjects.count; ++index3) {
            id object3 = [geometricObjects objectAtIndex:index3];
            if ([[object3 class] isSubclassOfClass:[DHCircle class]] == NO) continue;
            
            DHCircle* c1 = _circle1;
            DHCircle* c2 = object2;
            DHCircle* c3 = object3;
            
            CGFloat radius1 = c1.radius;
            CGFloat radius2 = c2.radius;
            CGFloat radius3 = c3.radius;
            
            // Ensure all radii are equal
            BOOL radiiOK = fabs(radius1-radius2) < 0.01 && fabs(radius1-radius3) < 0.01 && fabs(radius2-radius3) < 0.01;
            if (radiiOK == NO) {
                continue;
            }
            
            CGFloat dist12 = DistanceBetweenPoints(c1.center.position, c2.center.position);
            CGFloat dist13 = DistanceBetweenPoints(c1.center.position, c3.center.position);
            CGFloat dist23 = DistanceBetweenPoints(c2.center.position, c3.center.position);
            
            // Ensure all distances are equal to 2*radius
            CGFloat doubRad = 2*radius1;
            BOOL distOK = fabs(dist12 - doubRad) < 0.01 && fabs(dist13 - doubRad) < 0.01 && fabs(dist23 - doubRad) < 0.01;
            if (distOK == NO) {
                continue;
            }
            
            // Ensure one circle touches B
            CGFloat distB2 = DistanceBetweenPoints(_circle1.pointOnRadius.position, c2.center.position);
            CGFloat distB3 = DistanceBetweenPoints(_circle1.pointOnRadius.position, c3.center.position);
            BOOL oneCircleTouchesB = fabs(distB2-radius1) < 0.01 || fabs(distB3-radius1) < 0.01;

            if (oneCircleTouchesB) {
                return YES;
            }
        }
    }
    
    return NO;
}


@end

