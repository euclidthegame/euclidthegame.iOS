//
//  DHCircleTangentFromPoint.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-11.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelCircleTangentFromPoint.h"

#import "DHGeometricObjects.h"

@interface DHLevelCircleTangentFromPoint () {
    DHPoint* _pointA;
    DHCircle* _circle;
}

@end

@implementation DHLevelCircleTangentFromPoint

- (NSString*)subTitle
{
    return @"Barely touching";
}

- (NSString*)levelDescription
{
    return (@"Construct two tangents to the given circle from the point A");
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
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:500 andY:400];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:200 andY:200];
    DHPoint* pRadius = [[DHPoint alloc] initWithPositionX:300 andY:200];
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:pB andPointOnRadius:pRadius];
    
    [geometricObjects addObject:c];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    
    _pointA = pA;
    _circle = c;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = _pointA;
    mp.end = _circle.center;
    
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_pointA];
    
    DHIntersectionPointCircleCircle* ip1 = [[DHIntersectionPointCircleCircle alloc] init];
    ip1.c1 = c1;
    ip1.c2 = _circle;
    ip1.onPositiveY = YES;

    DHIntersectionPointCircleCircle* ip2 = [[DHIntersectionPointCircleCircle alloc] init];
    ip2.c1 = c1;
    ip2.c2 = _circle;
    ip2.onPositiveY = NO;
    
    DHRay* r1 = [[DHRay alloc] initWithStart:_pointA andEnd:ip1];
    DHRay* r2 = [[DHRay alloc] initWithStart:_pointA andEnd:ip2];
    
    [objects insertObject:r1 atIndex:0];
    [objects insertObject:r2 atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _pointA.position;
    CGPoint pointB = _circle.center.position;
    
    _pointA.position = CGPointMake(pointA.x - 10, pointA.y - 10);
    _circle.center.position = CGPointMake(pointB.x + 10, pointB.y + 10);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _pointA.position = pointA;
    _circle.center.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:_pointA andPoint2:_circle.center];
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_pointA];
    DHIntersectionPointCircleCircle* ip1 = [[DHIntersectionPointCircleCircle alloc]
                                            initWithCircle1:c1 andCircle2:_circle onPositiveY:YES];
    DHIntersectionPointCircleCircle* ip2 =  [[DHIntersectionPointCircleCircle alloc]
                                             initWithCircle1:c1 andCircle2:_circle onPositiveY:NO];
    DHLine* l1 = [[DHLine alloc] initWithStart:_pointA andEnd:ip1];
    DHLine* l2 = [[DHLine alloc] initWithStart:_pointA andEnd:ip2];
    
    BOOL pointOnTangent1OK = NO;
    BOOL pointOnTangent2OK = NO;
    BOOL tangent1OK = NO;
    BOOL tangent2OK = NO;
    
    for (id object in geometricObjects) {
        if (object == _pointA || object == _circle) continue;
        
        if (PointOnLine(object, l1)) pointOnTangent1OK = YES;
        if (PointOnLine(object, l2)) pointOnTangent2OK = YES;
        if (PointOnLine(_pointA, object) && PointOnLine(ip1, object)) tangent1OK = YES;
        if (PointOnLine(_pointA, object) && PointOnLine(ip2, object)) tangent2OK = YES;
    }
    
    if (tangent1OK && tangent2OK) {
        self.progress = 100;
        return YES;
    }
    
    self.progress = (pointOnTangent1OK + tangent1OK + pointOnTangent2OK + tangent2OK)/4.0 * 100;
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects{
    
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = _pointA;
    mp.end = _circle.center;
    
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_pointA];
    
    DHIntersectionPointCircleCircle* ip1 = [[DHIntersectionPointCircleCircle alloc] init];
    ip1.c1 = c1;
    ip1.c2 = _circle;
    ip1.onPositiveY = YES;
    
    DHIntersectionPointCircleCircle* ip2 = [[DHIntersectionPointCircleCircle alloc] init];
    ip2.c1 = c1;
    ip2.c2 = _circle;
    ip2.onPositiveY = NO;
    
    DHRay* r1 = [[DHRay alloc] initWithStart:_pointA andEnd:ip1];
    DHRay* r2 = [[DHRay alloc] initWithStart:_pointA andEnd:ip2];
    
    
    for (id object in objects){
        if (PointOnLine(object, r1)) return Position(object);
        if (PointOnLine(object, r2)) return Position(object);
        if (EqualDirection(object, r1)) return Position(r1);
        if (EqualDirection(object, r2)) return Position(r2);
        if (EqualCircles(object, c1)) return Position(c1);
    }
    
    
    return CGPointMake(NAN, NAN);
}


@end


