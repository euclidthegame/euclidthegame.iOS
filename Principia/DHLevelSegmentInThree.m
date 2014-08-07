//
//  DHLevelSegmentInThree.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-09.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelSegmentInThree.h"

#import "DHGeometricObjects.h"

@interface DHLevelSegmentInThree () {
    DHLineSegment* _lAB;
}

@end

@implementation DHLevelSegmentInThree

- (NSString*)subTitle
{
    return @"Lucky number three";
}

- (NSString*)levelDescription
{
    return (@"Construct two points, cutting the given segment into three equal pieces");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct two points, such that the segment is cut into three equal pieces.");
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
    return 6;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:150 andY:250];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:450 andY:230];
    
    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:pA andEnd:pB];

    [geometricObjects addObject:lAB];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    
    _lAB = lAB;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHPointOnLine* pC = [[DHPointOnLine alloc] initWithLine:_lAB andTValue:1/3.0];
    DHPointOnLine* pD = [[DHPointOnLine alloc] initWithLine:_lAB andTValue:2/3.0];
    pC.hideBorder = YES;
    pD.hideBorder = YES;
    [objects addObject:pC];
    [objects addObject:pD];
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
    DHPointOnLine* pC = [[DHPointOnLine alloc] initWithLine:_lAB andTValue:1/3.0];
    DHPointOnLine* pD = [[DHPointOnLine alloc] initWithLine:_lAB andTValue:2/3.0];
    
    BOOL firstPointOK = NO;
    BOOL secondPointOK = NO;
    BOOL intersectionAtFirstPointOK = NO;
    BOOL intersectionAtSecondPointOK = NO;
    
    for (id object in geometricObjects){
        if (object == _lAB || object == _lAB.start || object == _lAB.end) continue;
        
        // Do not count lines parallel with AB intersecting lines with C or D
        if (EqualDirection2(_lAB, object)) continue;
        
        if (PointOnLine(pC, object) || PointOnCircle(pC, object)) intersectionAtFirstPointOK = YES;
        if (PointOnLine(pD, object) || PointOnCircle(pD, object)) intersectionAtSecondPointOK = YES;
        if (EqualPoints(object, pC)) firstPointOK = YES;
        if (EqualPoints(object,pD)) secondPointOK = YES;
    }
    
    if (firstPointOK && secondPointOK) {
        self.progress = 100;
        return YES;
    }
    
    self.progress = (intersectionAtFirstPointOK + firstPointOK +
                     intersectionAtSecondPointOK + secondPointOK)/4.0*100;
    
    return NO;
}

- (CGPoint)testObjectsForProgressHints:(NSArray *)objects{
    
    DHPointOnLine* pC = [[DHPointOnLine alloc] initWithLine:_lAB andTValue:1/3.0];
    DHPointOnLine* pD = [[DHPointOnLine alloc] initWithLine:_lAB andTValue:2/3.0];
    
    
    for (id object in objects){
        // Do not count lines parallel with AB intersecting lines with C or D
        if (EqualDirection2(_lAB, object)) continue;
        
        if (PointOnLine(pC, object)) return Position(object);
        if (PointOnCircle(pC, object)) return Position(object);
        if (PointOnLine(pD, object)) return Position(object);
        if (PointOnCircle(pD, object)) return Position(object);
        if (EqualPoints(object, pC)) return pC.position;
        if (EqualPoints(object,pD)) return pD.position;
    }
    
    
    return CGPointMake(NAN, NAN);
}


@end

