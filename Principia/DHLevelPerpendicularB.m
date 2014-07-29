//
//  DHLevelPerpendicularB.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-04.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelPerpendicularB.h"

#import <CoreGraphics/CGBase.h>
#import "DHGeometricObjects.h"

@interface DHLevelPerpendicularB () {
    DHPoint* _pointA;
    DHPoint* _pointB;
    DHLine* _lineA;
    
}

@end

@implementation DHLevelPerpendicularB

- (NSString*)subTitle
{
    return @"Perpendicular again";
}

- (NSString*)levelDescription
{
    return @"Construct a line (segment) perpendicular to the given line going through point B";
}

- (NSUInteger)minimumNumberOfMoves
{
    return 2;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 3;
}

- (NSString *)additionalCompletionMessage
{
    return @"You unlocked a new tool: Constructing perpendicular lines!";
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable);
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:300];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:400 andY:200];
    
    DHLine* l1 = [[DHLine alloc] initWithStart:p1 andEnd:p2];
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    //[geometricObjects addObject:p2];
    [geometricObjects addObject:p3];
    
    _pointA = p1;
    _pointB = p3;
    _lineA = l1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHCircle* c = [[DHCircle alloc] initWithCenter:_pointB andPointOnRadius:_lineA.end];
    DHIntersectionPointLineCircle* ip = [[DHIntersectionPointLineCircle alloc] init];
    ip.c = c;
    ip.l = _lineA;
    ip.preferEnd = NO;
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:ip andPoint2:_lineA.end];
    
    DHLineSegment* sPerp = [[DHLineSegment alloc] init];
    sPerp.start = _pointB;
    sPerp.end = mp;
    
    [objects insertObject:sPerp atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _lineA.start.position;
    CGPoint pointB = _lineA.end.position;
    
    _lineA.start.position = CGPointMake(100, 250);
    _lineA.end.position = CGPointMake(600, 400);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _lineA.start.position = pointA;
    _lineA.end.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    BOOL pointOnLineEquidistantOK = NO;
    BOOL pointOnPerpLineOK = NO;
    
    DHPerpendicularLine* pl = [[DHPerpendicularLine alloc] initWithLine:_lineA andPoint:_pointB];
    CGVector vLine = CGVectorNormalize(_lineA.vector);
    CGFloat distAB = DistanceBetweenPoints(_lineA.start.position, _pointB.position);
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if (object == _lineA.start || object == _pointB) continue;
        
        if ([[object class]  isSubclassOfClass:[DHPoint class]]) {
            DHPoint* p = object;
            CGFloat distPB = DistanceBetweenPoints(p.position, _pointB.position);
            CGFloat distPLine = DistanceFromPointToLine(p, _lineA);
            if (fabs(distAB-distPB) < 0.001 && distPLine < 0.0001) {
                pointOnLineEquidistantOK = YES;
            }

            CGFloat distPPerpLine = DistanceFromPointToLine(p, pl);
            if (distPPerpLine < 0.0001) {
                pointOnPerpLineOK = YES;
            }
        }
        
        if ([[object class]  isSubclassOfClass:[DHLineObject class]]) {
            DHLineObject* l = object;
            CGFloat distAL = DistanceFromPointToLine(_pointB, l);
            CGFloat lDotLine = CGVectorDotProduct(CGVectorNormalize(l.vector), vLine);
            if (distAL < 0.0001 && fabs(lDotLine) < 0.0001) {
                self.progress = 100;
                return YES;
            }
        }
    }
    
    self.progress = (pointOnLineEquidistantOK + pointOnPerpLineOK*4)/10.0 * 100;
    
    return NO;
}

- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    DHPerpendicularLine* perp = [[DHPerpendicularLine alloc] init];
    perp.line = _lineA;
    perp.point = _pointB;
    
    for (id object in objects){
        
        if (EqualCircles(object,[[DHCircle alloc] initWithCenter:_pointB andPointOnRadius:_pointA]))
            return _pointB.position;
        
        if ([object class]==[DHIntersectionPointLineCircle class] && PointOnLine(object,_lineA))
        {
            DHPoint* p = object;
            return p.position;
        }
        if (PointOnLine(object,perp)){ DHPoint* p = object; return p.position; }
        if (EqualDirection(object,perp) && PointOnLine(_pointB, object))  return _pointB.position;
        
    }
    return CGPointMake(NAN, NAN);
}

@end
