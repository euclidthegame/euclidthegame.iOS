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
    DHPoint* _pointA;
    DHLine* _givenLine;
}

@end

@implementation DHLevelParallellLines

- (NSString*)subTitle
{
    return @"Parallell";
}

- (NSString*)levelDescription
{
    return @"Construct a line through point A parallell to the given line.";
}

- (NSString*)levelDescriptionExtra
{
    return @"Construct a line through point A parallell to the given line. \n\nParallel lines are lines which do not meet one another in either direction.";
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
    //[geometricObjects addObject:p1];
    //[geometricObjects addObject:p2];
    [geometricObjects addObject:p3];
    
    _pointA = p3;
    _givenLine = l1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHParallelLine* l = [[DHParallelLine alloc] init];
    l.line = _givenLine;
    l.point = _pointA;
    
    [objects insertObject:l atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _givenLine.start.position;
    CGPoint pointB = _givenLine.end.position;
    
    _givenLine.start.position = CGPointMake(280, 310);
    _givenLine.end.position = CGPointMake(480, 320);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _givenLine.start.position = pointA;
    _givenLine.end.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    BOOL perpendicularLineOK = NO;
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
        
        DHLineObject* l = object;
        
        if (l.tMin < 0 && l.tMax > 1 && LinesPerpendicular(l, _givenLine)) {
            perpendicularLineOK = YES;
        }
        
        CGVector bc = CGVectorNormalize(_givenLine.vector);
        
        CGFloat lDotBC = CGVectorDotProduct(CGVectorNormalize(l.vector), bc);
        if (!(fabs(lDotBC) > 1 - 0.001)) continue;
        
        CGFloat dist = DistanceFromPointToLine(_pointA, l);
        if (dist < 0.01) {
            self.progress = 100;
            return YES;
        }
    }
    
    self.progress = (perpendicularLineOK)/2.0 * 100;
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    DHPerpendicularLine* perp1 = [[DHPerpendicularLine alloc] initWithLine:_givenLine andPoint:_pointA];
    DHPerpendicularLine* perp2 = [[DHPerpendicularLine alloc] initWithLine:perp1 andPoint:_pointA];
    
    for (id object in objects){
        if (EqualDirection(object,perp1))  return _pointA.position;
        if (EqualDirection(object,perp2))  return _pointA.position;
    }
    return CGPointMake(NAN, NAN);
}

@end
