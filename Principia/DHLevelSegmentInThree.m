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
    if (geometricObjects.count < 3) {
        return NO;
    }
    
    for (int index1 = 0; index1 < geometricObjects.count-1; ++index1) {
        id object1 = [geometricObjects objectAtIndex:index1];
        if (object1 == _lAB || object1 == _lAB.start || object1 == _lAB.end) continue;
        if ([[object1 class] isSubclassOfClass:[DHPoint class]] == NO) continue;
        
        for (int index2 = index1+1; index2 < geometricObjects.count; ++index2) {
            id object2 = [geometricObjects objectAtIndex:index2];
            if (object2 == _lAB || object2 == _lAB.start || object2 == _lAB.end) continue;
            if ([[object2 class] isSubclassOfClass:[DHPoint class]] == NO) continue;
            
            DHPoint* p1 = object1;
            DHPoint* p2 = object2;

            // Ensure both points are on AB-line
            CGFloat p1toAB = DistanceFromPointToLine(p1, _lAB);
            CGFloat p2toAB = DistanceFromPointToLine(p2, _lAB);
            
            BOOL onLine = p1toAB < 0.01 && p2toAB < 0.01;
            if (onLine == NO) {
                continue;
            }
            
            // Ensure they split line in three
            CGFloat p1toA = DistanceBetweenPoints(p1.position, _lAB.start.position);
            CGFloat p1toB = DistanceBetweenPoints(p1.position, _lAB.end.position);
            CGFloat p2toA = DistanceBetweenPoints(p2.position, _lAB.start.position);
            CGFloat p2toB = DistanceBetweenPoints(p2.position, _lAB.end.position);
            
            BOOL splitInThree = NO;
            if (p1toA < p2toA) {
                splitInThree = fabs(p1toA-p2toB) < 0.01 && fabs(p1toA*2 - p1toB) < 0.01 && fabs(p2toB*2-p2toA) < 0.01;
            } else {
                splitInThree = fabs(p2toA-p1toB) < 0.01 && fabs(p2toA*2 - p2toB) < 0.01 && fabs(p1toB*2-p1toA) < 0.01;
            }
            
            if (splitInThree) {
                self.progress = 100;
                return YES;
            }

        }
    }
    
    return NO;
}


@end

