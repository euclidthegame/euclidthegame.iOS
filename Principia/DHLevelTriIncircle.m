//
//  DHLevelTriIncircle.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-08.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelTriIncircle.h"

#import "DHGeometricObjects.h"

@interface DHLevelTriIncircle () {
    DHLineSegment* _lAB;
    DHLineSegment* _lAC;
    DHLineSegment* _lBC;
}

@end

@implementation DHLevelTriIncircle

- (NSString*)subTitle
{
    return @"Drawing within the lines";
}

- (NSString*)levelDescription
{
    return (@"Construct the incircle of a triangle. An incircle is a circle fully contained in a triangle "
            @"that is tangent to all three sides.");
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
    return 8;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:200 andY:500];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:400 andY:480];
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:385 andY:330];
    
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
    DHBisectLine* bl1 = [[DHBisectLine alloc] init];
    bl1.line1 = _lAB;
    bl1.line2 = _lAC;
    DHBisectLine* bl2 = [[DHBisectLine alloc] init];
    bl2.line1 = _lAC;
    bl2.line2 = _lBC;
    
    DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] init];
    ip1.l1 = bl1;
    ip1.l2 = bl2;
    
    DHPerpendicularLine* lp = [[DHPerpendicularLine alloc] init];
    lp.line = _lBC;
    lp.point = ip1;
    
    DHIntersectionPointLineLine* ip2 = [[DHIntersectionPointLineLine alloc] init];
    ip2.l1 = _lBC;
    ip2.l2 = lp;
        
    DHCircle* c = [[DHCircle alloc] initWithCenter:ip1 andPointOnRadius:ip2];
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
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class]  isSubclassOfClass:[DHCircle class]] == NO) continue;
        
        DHCircle* circle = object;
        CGFloat radius = circle.radius;
        
        CGFloat sideAB = _lAB.length;
        CGFloat sideAC = _lAC.length;
        CGFloat sideBC = _lBC.length;
        CGFloat triPerimiter = sideAB + sideAC + sideBC;
        CGFloat halfPerim = triPerimiter*0.5;
        CGFloat triArea = sqrt(halfPerim*(halfPerim-sideAB)*(halfPerim-sideAC)*(halfPerim-sideBC));
        CGFloat incircleRadius = 2 * triArea / triPerimiter;
        
        BOOL radiusOK = fabs(radius - incircleRadius) < 0.05;

        CGFloat distAB = DistanceFromPointToLine(circle.center, _lAB);
        CGFloat distAC = DistanceFromPointToLine(circle.center, _lAC);
        
        BOOL locationOK = (fabs(distAB-incircleRadius) < 0.1 && fabs(distAC-incircleRadius) < 0.1);
        
        if (radiusOK && locationOK) {
            self.progress = 100;
            return YES;
        }
    }
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects{
    
    
    
    DHBisectLine* bl1 = [[DHBisectLine alloc] init];
    bl1.line1 = _lAB;
    bl1.line2 = _lAC;
    DHBisectLine* bl2 = [[DHBisectLine alloc] init];
    bl2.line1 = _lAC;
    bl2.line2 = _lBC;
    
    DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] init];
    ip1.l1 = bl1;
    ip1.l2 = bl2;
    
    DHPerpendicularLine* lp = [[DHPerpendicularLine alloc] init];
    lp.line = _lBC;
    lp.point = ip1;
    
    DHIntersectionPointLineLine* ip2 = [[DHIntersectionPointLineLine alloc] init];
    ip2.l1 = _lBC;
    ip2.l2 = lp;
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:ip1 andPointOnRadius:ip2];
    for (id object in objects){
        
        if (EqualPoints(object, ip1)) return ip1.position;
        if (PointOnCircle(object, c)) return Position(object);
        if (EqualCircles(object,c)) return c.center.position;
    }
    return CGPointMake(NAN, NAN);
}

@end
