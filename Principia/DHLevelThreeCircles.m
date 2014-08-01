//
//  DHLevelThreeCircles.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-09.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelThreeCircles.h"

#import "DHGeometricObjects.h"

@interface DHLevelThreeCircles () {
    DHLineSegment* _lAB;
    DHCircle* _circle1;
}

@end

@implementation DHLevelThreeCircles

- (NSString*)subTitle
{
    return @"Stacking circles";
}

- (NSString*)levelDescription
{
    return (@"Construct two new circles of radius AB where each pair of the three circles is tangent.");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct two new circles of radius AB where each pair of the three circles is tangent. "
            @"One of the two circles must also touch point B.");
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
    return 5;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:300 andY:350];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:400 andY:350];
    
    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:pA andEnd:pB];
    DHCircle* c1 = [[DHCircle alloc] init];
    c1.center = pA;
    c1.pointOnRadius = pB;
    
    [geometricObjects addObject:lAB];
    [geometricObjects addObject:c1];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    
    _lAB = lAB;
    _circle1 = c1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHTranslatedPoint* pc2 = [[DHTranslatedPoint alloc] init];
    pc2.startOfTranslation = _lAB.end;
    pc2.translationStart = _lAB.start;
    pc2.translationEnd = _lAB.end;
    
    DHCircle* c2 = [[DHCircle alloc] initWithCenter:pc2 andPointOnRadius:_lAB.end];
    [objects insertObject:c2 atIndex:0];
    
    DHTrianglePoint* pt = [[DHTrianglePoint alloc] initWithPoint1:_lAB.start andPoint2:pc2];
    DHLineSegment* l = [[DHLineSegment alloc] initWithStart:_lAB.start andEnd:pt];
    DHIntersectionPointLineCircle* ip = [[DHIntersectionPointLineCircle alloc] init];
    ip.c = _circle1;
    ip.l = l;
    
    
    DHCircle* c3 = [[DHCircle alloc] initWithCenter:pt andPointOnRadius:ip];
    [objects insertObject:c3 atIndex:0];
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
    DHTranslatedPoint* pc2 = [[DHTranslatedPoint alloc] init];
    pc2.startOfTranslation = _lAB.end;
    pc2.translationStart = _lAB.start;
    pc2.translationEnd = _lAB.end;
    DHCircle* c2 = [[DHCircle alloc] initWithCenter:pc2 andPointOnRadius:_lAB.end];
    DHTrianglePoint* pt = [[DHTrianglePoint alloc] initWithPoint1:_lAB.start andPoint2:pc2];
    DHTrianglePoint* pt2 = [[DHTrianglePoint alloc] initWithPoint1:pc2 andPoint2:_lAB.start];

    DHLineSegment* l = [[DHLineSegment alloc] initWithStart:_lAB.start andEnd:pt];
    DHLineSegment* l2 = [[DHLineSegment alloc] initWithStart:_lAB.start andEnd:pt2];
    DHIntersectionPointLineCircle* ip = [[DHIntersectionPointLineCircle alloc]
                                         initWithLine:l andCircle:_circle1 andPreferEnd:NO];
    DHIntersectionPointLineCircle* ip2 = [[DHIntersectionPointLineCircle alloc]
                                         initWithLine:l2 andCircle:_circle1 andPreferEnd:NO];
    DHCircle* c3 = [[DHCircle alloc] initWithCenter:pt andPointOnRadius:ip];
    DHCircle* c3_2 = [[DHCircle alloc] initWithCenter:pt2 andPointOnRadius:ip2];
    
    BOOL secondCircleOK = NO;
    BOOL thirdCircleOK = NO;
    bool pointOnThirdCircleOK = NO;
    BOOL secondCircleCenterOK = NO;
    BOOL thirdCircleCenterOK = NO;
    
    for (id object in geometricObjects) {
        if (EqualPoints(object, pc2)) secondCircleCenterOK = YES;
        if (EqualCircles(object, c2)) secondCircleOK = YES;
        if (EqualPoints(object, pt) || EqualPoints(object, pt2)) thirdCircleCenterOK = YES;
        if (PointOnCircle(object, c3) || PointOnCircle(object, c3_2)) pointOnThirdCircleOK = YES;
        if (EqualCircles(object, c3) || EqualCircles(object, c3_2)) thirdCircleOK = YES;
    }
    
    if (secondCircleOK && thirdCircleOK) {
        self.progress = 100;
        return YES;
    }
    
    self.progress = (secondCircleCenterOK + secondCircleOK*4 +
                     thirdCircleCenterOK + pointOnThirdCircleOK + thirdCircleOK*3)/10.0*100;
    
    return NO;
}
-(CGPoint)testObjectsForProgressHints:(NSArray *)objects {
    
    DHTranslatedPoint* pc2 = [[DHTranslatedPoint alloc] init];
    pc2.startOfTranslation = _lAB.end;
    pc2.translationStart = _lAB.start;
    pc2.translationEnd = _lAB.end;
    
    DHCircle* c2 = [[DHCircle alloc] initWithCenter:pc2 andPointOnRadius:_lAB.end];
    
    DHTrianglePoint* pt = [[DHTrianglePoint alloc] initWithPoint1:_lAB.start andPoint2:pc2];
    
    DHTrianglePoint* pt2 = [[DHTrianglePoint alloc] initWithPoint1:pc2 andPoint2:_lAB.start];
    DHLineSegment* l = [[DHLineSegment alloc] initWithStart:_lAB.start andEnd:pt];
    DHIntersectionPointLineCircle* ip = [[DHIntersectionPointLineCircle alloc] init];
    ip.c = _circle1;
    ip.l = l;
    
    
    DHCircle* c3 = [[DHCircle alloc] initWithCenter:pt andPointOnRadius:ip];
    
    for (id object in objects) {
        if (EqualPoints(object, pc2)) return pc2.position;
        if (EqualPoints(object, pt)) return pt.position;
        if (EqualPoints(object, pt2)) return pt2.position;
        if (PointOnCircle(object, c2)) return Position(object);
        if (PointOnCircle(object, c3)) return Position(object);
        if (EqualCircles(object, c2)) return c2.center.position;
        if (EqualCircles(object, c3)) return c3.center.position;
    }
    
    return CGPointMake(NAN, NAN);
}

@end

