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
    return @"Create a line segment that bisects (divides in half) the angle between segments AB and AC";
}

- (NSString *)additionalCompletionMessage
{
    return @"You unlocked a new tool: Constructing a bisector!";
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineToolAvailable | DHRayToolAvailable |
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
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:400 andY:200];
    
    DHLineSegment* l1 = [[DHLineSegment alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    DHLineSegment* l2 = [[DHLineSegment alloc] init];
    l2.start = p1;
    l2.end = p3;
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:l2];
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    [geometricObjects addObject:p3];
    
    _lineAB = l1;
    _lineAC = l2;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHBisectLine* bline = [[DHBisectLine alloc] init];
    bline.line1 = _lineAB;
    bline.line2 = _lineAC;
    
    CGVector bpointVec = bline.vector;
    CGPoint bpointPos = CGPointMake(_lineAB.start.position.x + bpointVec.dx*100, _lineAB.start.position.y + bpointVec.dy*100);
    DHPoint* bpoint = [[DHPoint alloc] initWithPositionX:bpointPos.x andY:bpointPos.y];
    DHLineSegment* bseg = [[DHLineSegment alloc] initWithStart:_lineAB.start andEnd:bpoint];
    
    [objects insertObject:bseg atIndex:0];
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
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _lineAB.end.position = pointB;
    _lineAC.end.position = pointC;
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
        if (object == _lineAB || object == _lineAC) continue;
        
        DHLineObject* l = object;
        
        CGVector ab = _lineAB.vector;
        CGVector ac = _lineAC.vector;

        CGFloat targetAngle = CGVectorAngleBetween(ab, ac) * 0.5;
        CGFloat angleToAB = CGVectorAngleBetween(l.vector, ab);
        CGFloat angleToAC = CGVectorAngleBetween(l.vector, ac);
        
        //Compare angle to both initial lines and ensure = 0.5*
        
        if (CGFloatsEqualWithinEpsilon(angleToAB, targetAngle) &&
            CGFloatsEqualWithinEpsilon(angleToAC, targetAngle)) {
            return YES;
        }
    }
    
    return NO;
}


@end
