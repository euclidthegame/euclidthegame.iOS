//
//  DHLevel5.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-02.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelBisect.h"

#import <CoreGraphics/CGBase.h>
#import "DHGeometricObjects.h"

@interface DHLevelBisect () {
    DHRay* _lineAB;
    DHRay* _lineAC;
}
@end

@implementation DHLevelBisect

- (NSString*)subTitle
{
    return @"Bisecting an angle";
}

- (NSString*)levelDescription
{
    return @"Create a line (segment) that bisects (divides in half) the given angle";
}

- (NSString *)additionalCompletionMessage
{
    return @"You unlocked a new tool: Constructing a bisector!";
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 3;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 4;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:300 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:500 andY:300];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:450 andY:170];
    
    DHRay* l1 = [[DHRay alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    DHRay* l2 = [[DHRay alloc] init];
    l2.start = p1;
    l2.end = p3;
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:l2];
    [geometricObjects addObject:p1];
    //[geometricObjects addObject:p2];
    //[geometricObjects addObject:p3];
    
    _lineAB = l1;
    _lineAC = l2;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHCircle* cAC = [[DHCircle alloc] initWithCenter:_lineAC.start andPointOnRadius:_lineAC.end];
    DHIntersectionPointLineCircle* ip = [[DHIntersectionPointLineCircle alloc] init];
    ip.c = cAC;
    ip.l = _lineAB;
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:_lineAC.end andPoint2:ip];
    DHRay* rayBisector = [[DHRay alloc] initWithStart:_lineAB.start andEnd:mp];
    [objects insertObject:rayBisector atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointB = _lineAB.end.position;
    CGPoint pointC = _lineAC.end.position;
    
    _lineAB.end.position = CGPointMake(600, 400);
    _lineAC.end.position = CGPointMake(450, 100);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _lineAB.end.position = pointB;
    _lineAC.end.position = pointC;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    BOOL circleOK = NO;
    BOOL intersectionPointOK = NO;
    BOOL midPointOK = NO;
    BOOL bisectOK = NO;
    
    DHBisectLine* b = [[DHBisectLine alloc] init];
    b.line1 = _lineAB;
    b.line2 = _lineAC;
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if (object == _lineAB || object == _lineAC) continue;
        
        if ([object class] == [DHCircle class])
        {
            DHCircle* c = object;
            if (EqualPoints(c.center,_lineAB.start)) circleOK = YES;
        }
        if ([object class] == [DHIntersectionPointLineCircle class])
        {
            DHPoint* p = object;
            if (PointOnLine(p,_lineAB) || PointOnLine(object,_lineAC)) intersectionPointOK = YES;
        }
        if (PointOnLine(object,b)) midPointOK = YES;
        if (EqualDirection(b,object))
        {
            DHLineObject * l = object;
            if (PointOnLine(_lineAB.start, l)) {
                bisectOK = YES;
                return YES;
            }
        }
    }
    self.progress = (circleOK + intersectionPointOK + midPointOK + bisectOK)/4.0 * 100;
    
    return NO;
}

- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    DHBisectLine* b = [[DHBisectLine alloc] init];
    b.line1 = _lineAB;
    b.line2 = _lineAC;
    
    for (id object in objects){
        
        if ([object class] == [DHCircle class])
        {
            DHCircle* c = object;
            if (EqualPoints(c.center,_lineAB.start)) return c.center.position;
        }
        if ([object class] == [DHIntersectionPointLineCircle class])
        {
            DHPoint* p = object;
            if (PointOnLine(p,_lineAB) || PointOnLine(object,_lineAC)) return p.position;
        }
        if (PointOnLine(object,b))
        {
            DHPoint* p = object;
            return p.position;
        }
        if (EqualDirection(b,object))
        {
            DHLineObject * l = object;
            if (PointOnLine(_lineAB.start, l)) return l.end.position;
        }
        
    }
    return CGPointMake(NAN, NAN);
}
@end
