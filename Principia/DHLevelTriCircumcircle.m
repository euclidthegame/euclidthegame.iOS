//
//  DHLevelTriCircumcircle.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-09.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelTriCircumcircle.h"

#import "DHGeometricObjects.h"

@interface DHLevelTriCircumcircle () {
    DHLineSegment* _lAB;
    DHLineSegment* _lAC;
    DHLineSegment* _lBC;
}

@end

@implementation DHLevelTriCircumcircle

- (NSString*)subTitle
{
    return @"Drawing outside the lines";
}

- (NSString*)levelDescription
{
    return (@"Construct the circumcircle of a triangle.");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct the circumcircle of a triangle. \n\nA circumcircle is a circle that passes through all three "
            @"points of a triangle.");
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
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:168 andY:498];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:403 andY:480];
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:335 andY:330];
    
    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:pA andEnd:pB];
    DHLineSegment* lAC = [[DHLineSegment alloc] initWithStart:pA andEnd:pC];
    DHLineSegment* lBC = [[DHLineSegment alloc] initWithStart:pB andEnd:pC];
    
    [geometricObjects addObject:lAB];
    [geometricObjects addObject:lAC];
    [geometricObjects addObject:lBC];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    [geometricObjects addObject:pC];
    
    _lAB = lAB;
    _lAC = lAC;
    _lBC = lBC;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHPerpendicularLine* pl1 = [[DHPerpendicularLine alloc] initWithLine:_lAB andPoint:_lAB.start];
    DHPerpendicularLine* pl2 = [[DHPerpendicularLine alloc] initWithLine:_lBC andPoint:_lBC.end];
    DHIntersectionPointLineLine* ip = [[DHIntersectionPointLineLine alloc] initWithLine:pl1 andLine:pl2];
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:ip andPoint2:_lAB.end];
    DHCircle* c = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_lAB.start];
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
    DHPerpendicularLine* pl1 = [[DHPerpendicularLine alloc] initWithLine:_lAB andPoint:_lAB.start];
    DHPerpendicularLine* pl2 = [[DHPerpendicularLine alloc] initWithLine:_lBC andPoint:_lBC.end];
    DHIntersectionPointLineLine* ip = [[DHIntersectionPointLineLine alloc] initWithLine:pl1 andLine:pl2];
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:ip andPoint2:_lAB.end];
    DHCircle* c = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_lAB.start];

    BOOL centerPointOK = NO;
    
    for (id object in geometricObjects) {
        if (EqualPoints(object, mp)) centerPointOK = YES;
        if (EqualCircles(object,c)) {
            self.progress = 100;
            return YES;
        }
    }

    self.progress = (centerPointOK)/2.0*100;

    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects{
    DHPerpendicularLine* pl1 = [[DHPerpendicularLine alloc] init];
    pl1.line = _lAB;
    pl1.point = _lAB.start;
    DHPerpendicularLine* pl2 = [[DHPerpendicularLine alloc] init];
    pl2.line = _lBC;
    pl2.point = _lBC.end;
    
    DHIntersectionPointLineLine* ip = [[DHIntersectionPointLineLine alloc] init];
    ip.l1 = pl1;
    ip.l2 = pl2;
    
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = ip;
    mp.end = _lAB.end;
    
    DHCircle* c = [[DHCircle alloc] init];
    c.center = mp;
    c.pointOnRadius = _lAB.start;
    for (id object in objects){
        
        if (EqualPoints(object, mp)) return mp.position;
        if (PointOnCircle(object, c)) return Position(object);
        if (EqualCircles(object,c)) return c.center.position;
    }
    return CGPointMake(NAN, NAN);
}


@end
