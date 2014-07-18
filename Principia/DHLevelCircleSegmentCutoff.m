//
//  DHLevelCircleSegmentCutoff.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-09.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelCircleSegmentCutoff.h"

#import "DHGeometricObjects.h"

@interface DHLevelCircleSegmentCutoff () {
    DHLineSegment* _lAB;
    DHLine* _givenLine;
    DHPoint* _pC;
}

@end

@implementation DHLevelCircleSegmentCutoff

- (NSString*)subTitle
{
    return @"Cut it out";
}

- (NSString*)levelDescription
{
    return (@"Given a line, a line segment AB, and a point C. Construct a circle with center C that cuts off a line "
            @"segment on the given line that has the same length as segment AB.");
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
    return 7;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:100 andY:150];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:250 andY:100];
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:300 andY:400];

    DHPoint* pD = [[DHPoint alloc] initWithPositionX:300 andY:300];
    DHPoint* pE = [[DHPoint alloc] initWithPositionX:400 andY:300];

    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:pA andEnd:pB];
    DHLine* lDE = [[DHLine alloc] initWithStart:pD andEnd:pE];
    
    [geometricObjects addObject:lAB];
    [geometricObjects addObject:lDE];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    [geometricObjects addObject:pC];
    
    _lAB = lAB;
    _givenLine = lDE;
    _pC = pC;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    CGPoint pPos;
    pPos.x = _pC.position.x - _lAB.length*0.5;
    pPos.y = _givenLine.start.position.y;
    DHPoint* p = [[DHPoint alloc] initWithPositionX:pPos.x andY:pPos.y];
    
    DHCircle* c = [[DHCircle alloc] init];
    c.center = _pC;
    c.pointOnRadius = p;
    [objects insertObject:c atIndex:0];
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
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class]  isSubclassOfClass:[DHCircle class]] == NO) continue;
        
        DHCircle* circle = object;
        if (circle.center != _pC) {
            continue;
        }
        
        DHIntersectionResult r1 = IntersectionTestLineCircle(_givenLine, circle, NO);
        DHIntersectionResult r2 = IntersectionTestLineCircle(_givenLine, circle, YES);
        
        if (r1.intersect && r2.intersect) {
            CGPoint ip1 = r1.intersectionPoint;
            CGPoint ip2 = r2.intersectionPoint;
            CGFloat dist = DistanceBetweenPoints(ip1, ip2);
            CGFloat distAB = _lAB.length;
            
            if (fabs(dist - distAB) < 0.001) {
                return YES;
            }
            
        }
    }
    
    return NO;
}


@end
