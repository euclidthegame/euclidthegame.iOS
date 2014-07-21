//
//  DHLevel2.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelEquiTri.h"

@interface DHLevelEquiTri() {
    DHLineSegment* _lineAB;
}
@end

@implementation DHLevelEquiTri

- (NSString*)subTitle
{
    return @"Making triangles";
}

- (NSString*)levelDescription
{
    return (@"Create 3 lines forming an equilateral triangle (a triangle whose sides all are of equal length) "
            @"such that the segment AB is one of its sides");
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable);
}

- (NSString *)additionalCompletionMessage
{
    return @"You unlocked a new tool: Constructing equilateral triangles!";
}

- (NSUInteger)minimumNumberOfMoves
{
    return 4;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 4;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:400];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:400];
    DHLineSegment* l1 = [[DHLineSegment alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    
    _lineAB = l1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:_lineAB.start andPointOnRadius:_lineAB.end];
    DHCircle* c2 = [[DHCircle alloc] initWithCenter:_lineAB.end andPointOnRadius:_lineAB.start];
    DHIntersectionPointCircleCircle* ip = [[DHIntersectionPointCircleCircle alloc] init];
    ip.c1 = c1;
    ip.c2 = c2;
    ip.onPositiveY = YES;
    [objects addObject:ip];
    
    DHLineSegment* sAC = [[DHLineSegment alloc]initWithStart:_lineAB.start andEnd:ip];
    [objects insertObject:sAC atIndex:0];

    DHLineSegment* sBC = [[DHLineSegment alloc]initWithStart:_lineAB.end andEnd:ip];
    [objects insertObject:sBC atIndex:0];    
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _lineAB.start.position;
    CGPoint pointB = _lineAB.end.position;
    
    _lineAB.start.position = CGPointMake(100, 100);
    _lineAB.end.position = CGPointMake(400, 400);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _lineAB.start.position = pointA;
    _lineAB.end.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    // Solution criteria
    BOOL pC1_OK = NO;
    BOOL pC2_OK = NO;
    BOOL sAC1_OK = NO;
    BOOL sBC1_OK = NO;
    BOOL sAC2_OK = NO;
    BOOL sBC2_OK = NO;
    
    DHTrianglePoint* pCAlt1 = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.start andPoint2:_lineAB.end];
    DHTrianglePoint* pCAlt2 = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.end andPoint2:_lineAB.start];
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        
        if (object != _lineAB && [[object class] isSubclassOfClass:[DHLineObject class]]) {
            DHLineObject* line = object;
            CGFloat distA = DistanceFromPointToLine(_lineAB.start, line);
            CGFloat distB = DistanceFromPointToLine(_lineAB.end, line);
            CGFloat distCAlt1 = DistanceFromPointToLine(pCAlt1, line);
            CGFloat distCAlt2 = DistanceFromPointToLine(pCAlt2, line);
            
            if (distA < 0.01 && distCAlt1 < 0.01) sAC1_OK = YES;
            if (distA < 0.01 && distCAlt2 < 0.01) sAC2_OK = YES;
            if (distB < 0.01 && distCAlt1 < 0.01) sBC1_OK = YES;
            if (distB < 0.01 && distCAlt2 < 0.01) sBC2_OK = YES;
        }
        if ([[object class] isSubclassOfClass:[DHPoint class]] && [object class] != [DHPoint class]) {
            DHPoint* point = object;
            CGFloat distCAlt1 = DistanceBetweenPoints(pCAlt1.position, point.position);
            CGFloat distCAlt2 = DistanceBetweenPoints(pCAlt2.position, point.position);
            if (distCAlt1 < 0.01) pC1_OK = YES;
            if (distCAlt2 < 0.01) pC2_OK = YES;
        }
    }
    
    self.progress = ((pC1_OK || pC2_OK) + (sAC1_OK || sAC2_OK || sBC1_OK || sBC2_OK) +
                     ((sAC1_OK && sBC1_OK) || (sAC2_OK && sBC2_OK)))/3.0 * 100;
    
    if ((pC1_OK && sAC1_OK && sBC1_OK) || (pC2_OK && sAC2_OK && sBC2_OK)) {
        return YES;
    }
    
    return NO;
}

- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    // Objects to test
    DHCircle* cAB = [[DHCircle alloc] initWithCenter:_lineAB.start andPointOnRadius:_lineAB.end];
    DHCircle* cBA = [[DHCircle alloc] initWithCenter:_lineAB.end andPointOnRadius:_lineAB.start];
    DHTrianglePoint* pTop = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.start andPoint2:_lineAB.end];
    DHTrianglePoint* pBottom = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.end andPoint2:_lineAB.start];
    DHLineSegment* sAC = [[DHLineSegment alloc]initWithStart:_lineAB.start andEnd:pTop];
    DHLineSegment* sAD = [[DHLineSegment alloc]initWithStart:_lineAB.start andEnd:pBottom];
    DHLineSegment* sBC = [[DHLineSegment alloc]initWithStart:_lineAB.end andEnd:pTop];
    DHLineSegment* sBD = [[DHLineSegment alloc]initWithStart:_lineAB.end andEnd:pBottom];
    
    
    for (id object in objects){
        if (EqualCircles(cAB, object)) {
            return cAB.center.position;
        }
        if (EqualCircles(cBA, object)) {
            return cBA.center.position;
        }
        if (EqualPoints(pTop, object)) {
            return pTop.position;
        }
        if (EqualPoints(pBottom, object)) {
            return pBottom.position;
        }
        if (EqualSegments(sAC, object)) {
            return MidPointFromPoints(sAC.start.position,sAC.end.position);
        }
        if (EqualSegments(sAD, object)) {
            return MidPointFromPoints(sAD.start.position,sAD.end.position);
        }
        if (EqualSegments(sBD, object)) {
            return MidPointFromPoints(sBD.start.position,sBD.end.position);
        }
        if (EqualSegments(sBC, object)) {
            return MidPointFromPoints(sBC.start.position,sBC.end.position);
        }
    }

    return CGPointMake(NAN, NAN);
}


@end
