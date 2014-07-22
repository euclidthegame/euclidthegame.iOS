//
//  DHLevelParallellLines.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-04.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelParallellLines.h"

#import "DHGeometricObjects.h"

@interface DHLevelParallellLines () {
    DHPoint* _pointB;
    DHLine* _lineA;
}

@end

@implementation DHLevelParallellLines

- (NSString*)subTitle
{
    return @"Parallell";
}

- (NSString*)levelDescription
{
    return @"Construct a line through point B parallell to the given line through A";
}

- (NSString *)additionalCompletionMessage
{
    return @"You have unlocked a new tool: Constructing parallel lines!";
}

- (NSUInteger)minimumNumberOfMoves
{
    return 2;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 4;
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable | DHPerpendicularToolAvailable);
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:300];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:400 andY:200];
    
    DHLine* l1 = [[DHLine alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    //[geometricObjects addObject:p2];
    [geometricObjects addObject:p3];
    
    _pointB = p3;
    _lineA = l1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHParallelLine* l = [[DHParallelLine alloc] init];
    l.line = _lineA;
    l.point = _pointB;
    
    [objects insertObject:l atIndex:0];
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
    
    _lineA.start.position = CGPointMake(280, 310);
    _lineA.end.position = CGPointMake(480, 320);
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
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
        
        DHLineObject* l = object;
        CGVector bc = CGVectorNormalize(_lineA.vector);
        
        CGFloat lDotBC = CGVectorDotProduct(CGVectorNormalize(l.vector), bc);
        if (!(fabs(lDotBC) > 1 - 0.001)) continue;
        
        CGFloat dist = DistanceFromPointToLine(_pointB, l);
        if (dist < 0.01) {
            self.progress = 100;
            return YES;
        }
    }
    
    return NO;
}


@end
