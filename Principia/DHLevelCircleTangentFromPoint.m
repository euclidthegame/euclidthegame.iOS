//
//  DHCircleTangentFromPoint.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-11.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelCircleTangentFromPoint.h"

#import "DHGeometricObjects.h"

@interface DHLevelCircleTangentFromPoint () {
    DHPoint* _pointA;
    DHCircle* _circle;
}

@end

@implementation DHLevelCircleTangentFromPoint

- (NSString*)subTitle
{
    return @"Barely touching";
}

- (NSString*)levelDescription
{
    return (@"Construct two tangents to the given circle from the point A");
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineToolAvailable | DHRayToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable | DHTranslateToolAvailable |
            DHCompassToolAvailable);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 4;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:500 andY:400];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:200 andY:200];
    DHPoint* pRadius = [[DHPoint alloc] initWithPositionX:300 andY:200];
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:pB andPointOnRadius:pRadius];
    
    [geometricObjects addObject:c];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    
    _pointA = pA;
    _circle = c;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = _pointA;
    mp.end = _circle.center;
    
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_pointA];
    
    DHIntersectionPointCircleCircle* ip1 = [[DHIntersectionPointCircleCircle alloc] init];
    ip1.c1 = c1;
    ip1.c2 = _circle;
    ip1.onPositiveY = YES;

    DHIntersectionPointCircleCircle* ip2 = [[DHIntersectionPointCircleCircle alloc] init];
    ip2.c1 = c1;
    ip2.c2 = _circle;
    ip2.onPositiveY = NO;
    
    DHRay* r1 = [[DHRay alloc] initWithStart:_pointA andEnd:ip1];
    DHRay* r2 = [[DHRay alloc] initWithStart:_pointA andEnd:ip2];
    
    [objects insertObject:r1 atIndex:0];
    [objects insertObject:r2 atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _pointA.position;
    CGPoint pointB = _circle.center.position;
    
    _pointA.position = CGPointMake(pointA.x - 10, pointA.y - 10);
    _circle.center.position = CGPointMake(pointB.x + 10, pointB.y + 10);
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _pointA.position = pointA;
    _circle.center.position = pointB;
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    for (int index1 = 0; index1 < geometricObjects.count-1; ++index1) {
        id object1 = [geometricObjects objectAtIndex:index1];
        if ([[object1 class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;

        for (int index2 = index1+1; index2 < geometricObjects.count; ++index2) {
            id object2 = [geometricObjects objectAtIndex:index2];
            if ([[object2 class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
            
            DHLineObject* l1 = object1;
            if ((l1.start == _pointA || l1.end == _pointA) == NO) continue;
            DHLineObject* l2 = object2;
            if ((l2.start == _pointA || l2.end == _pointA) == NO) continue;
            
            DHMidPoint* mp = [[DHMidPoint alloc] init];
            mp.start = _pointA;
            mp.end = _circle.center;
            
            DHCircle* c1 = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_pointA];
            
            DHIntersectionPointCircleCircle* ip1 = [[DHIntersectionPointCircleCircle alloc] init];
            ip1.c1 = c1;
            ip1.c2 = _circle;
            ip1.onPositiveY = YES;
            
            DHIntersectionPointCircleCircle* ip2 = [[DHIntersectionPointCircleCircle alloc] init];
            ip2.c1 = c1;
            ip2.c2 = _circle;
            ip2.onPositiveY = NO;
            
            CGFloat distL1ToIp1 = DistanceFromPointToLine(ip1, l1);
            CGFloat distL1ToIp2 = DistanceFromPointToLine(ip2, l1);
            CGFloat distL2ToIp1 = DistanceFromPointToLine(ip1, l2);
            CGFloat distL2ToIp2 = DistanceFromPointToLine(ip2, l2);
            
            if ((distL1ToIp1 < 0.01 ||  distL2ToIp1 < 0.01) && (distL1ToIp2 < 0.01 ||  distL2ToIp2 < 0.01)) {
                return YES;
            }
        }
    }
    
    return NO;
}


@end


