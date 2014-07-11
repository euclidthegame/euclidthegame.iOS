//
//  DHLevelCircleToTangent.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-09.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelCircleToTangent.h"

#import "DHGeometricObjects.h"

@interface DHLevelCircleToTangent () {
    DHLine* _givenLine;
    DHPoint* _pA;
}

@end

@implementation DHLevelCircleToTangent

- (NSString*)subTitle
{
    return @"Circle to tangent";
}

- (NSString*)levelDescription
{
    return (@"Given a point A, a line, and a point B. Construct a circle that passes through A and is "
            @"tangent to the line at B.");
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
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:140 andY:200];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:300 andY:350];
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:400 andY:350];
    
    DHLine* lBC = [[DHLine alloc] initWithStart:pB andEnd:pC];
    
    [geometricObjects addObject:lBC];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    
    _givenLine = lBC;
    _pA = pA;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHPerpendicularLine* pl1 = [[DHPerpendicularLine alloc] init];
    pl1.point = _givenLine.start;
    pl1.line = _givenLine;
    
    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:_pA andEnd:_givenLine.start];
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = lAB.start;
    mp.end = lAB.end;

    DHPerpendicularLine* pl2 = [[DHPerpendicularLine alloc] init];
    pl2.point = mp;
    pl2.line = lAB;

    DHIntersectionPointLineLine* ip = [[DHIntersectionPointLineLine alloc] initWithLine:pl1 andLine:pl2];
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:ip andPointOnRadius:lAB.start];
    [objects insertObject:c atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _pA.position;
    CGPoint pointB = _givenLine.start.position;
    
    _pA.position = CGPointMake(pointA.x - 10, pointA.y - 10);
    _givenLine.start.position = CGPointMake(pointB.x + 10, pointB.y + 10);
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _pA.position = pointA;
     _givenLine.start.position = pointB;
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class]  isSubclassOfClass:[DHCircle class]] == NO) continue;
        
        DHCircle* circle = object;
        CGFloat radius = circle.radius;
        CGFloat distCA = DistanceBetweenPoints(_pA.position, circle.center.position);
        CGFloat distCB = DistanceBetweenPoints(_givenLine.start.position, circle.center.position);
        CGVector vCB = CGVectorNormalize(CGVectorBetweenPoints(_givenLine.start.position, circle.center.position));
        CGVector vLine = CGVectorNormalize(_givenLine.vector);
        CGFloat tangentAngle = CGVectorDotProduct(vCB, vLine);
        if (fabs(distCA - radius) < 0.01 && fabs(distCB-radius) < 0.01 && fabs(tangentAngle) < 0.01) {
            return YES;
        }
    }
    
    return NO;
}


@end
