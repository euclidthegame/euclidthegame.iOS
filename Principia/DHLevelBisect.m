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
    DHLineSegment* _lineAB;
    DHLineSegment* _lineAC;
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
    
    DHLineSegment* l1 = [[DHLineSegment alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    DHLineSegment* l2 = [[DHLineSegment alloc] init];
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
    BOOL pointOnLineOK = NO;
    DHPoint* pointOnLine = nil;
    BOOL secondPointOK = NO;
    BOOL midPointOK = NO;
    
    CGVector vAB = _lineAB.vector;
    CGVector vAC = _lineAC.vector;
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if (object == _lineAB || object == _lineAC) continue;
        
        if ([object class] == [DHPointOnLine class]) {
            DHPointOnLine* p = object;
            if (p.line == _lineAB || p.line == _lineAC) {
                pointOnLineOK = YES;
                pointOnLine = p;
            }
        }
        if ([object class] == [DHIntersectionPointLineCircle class]) {
            DHIntersectionPointLineCircle* ip = object;
            if (pointOnLineOK && pointOnLine && (ip.l == _lineAB || ip.l == _lineAC) &&
                ip.c.center == _lineAB.start && ip.c.pointOnRadius == pointOnLine) {
                secondPointOK = YES;
            }
        }
        if ([[object class]  isSubclassOfClass:[DHPoint class]]) {
            DHPoint* p = object;
            
            CGVector vAP = CGVectorBetweenPoints(_lineAB.start.position, p.position);
            if (CGVectorDotProduct(vAP, vAB) < 0) {
                vAP.dx = -vAP.dx;
                vAP.dy = -vAP.dy;
            }
            
            CGFloat targetAngle = CGVectorAngleBetween(vAB, vAC) * 0.5;
            CGFloat angleToAB = CGVectorAngleBetween(vAP, vAB);
            CGFloat angleToAC = CGVectorAngleBetween(vAP, vAC);
            
            //Compare angle to both initial lines and ensure = 0.5*
            
            if (CGFloatsEqualWithinEpsilon(angleToAB, targetAngle) &&
                CGFloatsEqualWithinEpsilon(angleToAC, targetAngle)) {
                midPointOK = YES;
            }
        }
        if ([[object class]  isSubclassOfClass:[DHLineObject class]]) {
            DHLineObject* l = object;
            
            CGVector vl = l.vector;
            if (CGVectorDotProduct(vl, vAB) < 0) {
                vl.dx = -vl.dx;
                vl.dy = -vl.dy;
            }
            
            CGFloat targetAngle = CGVectorAngleBetween(vAB, vAC) * 0.5;
            CGFloat angleToAB = CGVectorAngleBetween(vl, vAB);
            CGFloat angleToAC = CGVectorAngleBetween(vl, vAC);
            
            //Compare angle to both initial lines and ensure = 0.5*
            
            if (CGFloatsEqualWithinEpsilon(angleToAB, targetAngle) &&
                CGFloatsEqualWithinEpsilon(angleToAC, targetAngle)) {
                self.progress = 100;
                return YES;
            }
        }
    }
    self.progress = (pointOnLineOK + secondPointOK + midPointOK)/4.0 * 100;
    
    return NO;
}


@end
