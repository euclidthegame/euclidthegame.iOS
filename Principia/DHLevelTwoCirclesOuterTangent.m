//
//  DHLevelTwoCirclesOuterTangent.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-11.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelTwoCirclesOuterTangent.h"

#import "DHGeometricObjects.h"

@interface DHLevelTwoCirclesOuterTangent () {
    DHCircle* _circleA;
    DHCircle* _circleB;
    DHPoint* _pRadiusA;
    DHPoint* _pRadiusB;
}

@end

@implementation DHLevelTwoCirclesOuterTangent

- (NSString*)subTitle
{
    return @"Outer tangent";
}

- (NSString*)levelDescription
{
    return (@"Construct a line (segment) tangent to both circles. Construct a outer tangent line.");
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
    return 6;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 8;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:200 andY:400];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:380 andY:350];
    DHPoint* pRadiusA = [[DHPoint alloc] initWithPositionX:pA.position.x+40 andY:pA.position.y];
    DHPoint* pRadiusB = [[DHPoint alloc] initWithPositionX:pB.position.x+80 andY:pB.position.y];
    
    DHCircle* cA = [[DHCircle alloc] initWithCenter:pA andPointOnRadius:pRadiusA];
    DHCircle* cB = [[DHCircle alloc] initWithCenter:pB andPointOnRadius:pRadiusB];
    
    [geometricObjects addObject:cA];
    [geometricObjects addObject:cB];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    
    _circleA = cA;
    _circleB = cB;
    _pRadiusA = pRadiusA;
    _pRadiusB = pRadiusB;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHRay* r1 = [[DHRay alloc] initWithStart:_circleB.center andEnd:_circleA.center];
    DHRay* r2 = [[DHRay alloc] initWithStart:_pRadiusB andEnd:_pRadiusA];

    DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] initWithLine:r1 andLine:r2];
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = ip1;
    mp.end = _circleA.center;
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_circleA.center];
    DHIntersectionPointCircleCircle* ip2 = [[DHIntersectionPointCircleCircle alloc] init];
    ip2.c1 = c;
    ip2.c2 = _circleA;
    
    DHRay* tangent = [[DHRay alloc] initWithStart:ip1 andEnd:ip2];
    [objects insertObject:tangent atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _circleA.center.position;
    CGPoint pointB = _circleB.center.position;
    
    _circleA.center.position = CGPointMake(pointA.x - 2, pointA.y );
    _circleB.center.position = CGPointMake(pointB.x + 2, pointB.y );
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _circleA.center.position = pointA;
    _circleB.center.position = pointB;
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    DHRay* r1 = [[DHRay alloc] initWithStart:_circleB.center andEnd:_circleA.center];
    DHRay* r2 = [[DHRay alloc] initWithStart:_pRadiusB andEnd:_pRadiusA];
    
    DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] initWithLine:r1 andLine:r2];
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = ip1;
    mp.end = _circleA.center;
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_circleA.center];
    DHIntersectionPointCircleCircle* ip2 = [[DHIntersectionPointCircleCircle alloc] init];
    ip2.c1 = c;
    ip2.c2 = _circleA;
    ip2.onPositiveY = NO;

    DHIntersectionPointCircleCircle* ip3 = [[DHIntersectionPointCircleCircle alloc] init];
    ip3.c1 = c;
    ip3.c2 = _circleA;
    ip3.onPositiveY = YES;
    
    DHRay* tangent1 = [[DHRay alloc] initWithStart:ip1 andEnd:ip2];
    DHRay* tangent2 = [[DHRay alloc] initWithStart:ip1 andEnd:ip3];
    
    for (int index1 = 0; index1 < geometricObjects.count; ++index1) {
        id object1 = [geometricObjects objectAtIndex:index1];
        if ([[object1 class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
        
        DHLineObject* l1 = object1;
        CGFloat angleL1Tangent1 = CGVectorAngleBetween(l1.vector, tangent1.vector);
        CGFloat angleL1Tangent2 = CGVectorAngleBetween(l1.vector, tangent2.vector);
        
        if (angleL1Tangent1 < 0.01) {
            CGFloat distL1Ip2 = DistanceFromPointToLine(ip2, l1);
            if (distL1Ip2 < 0.01) {
                return YES;
            }
        }
        if (angleL1Tangent2 < 0.01) {
            CGFloat distL1Ip3 = DistanceFromPointToLine(ip3, l1);
            if (distL1Ip3 < 0.01) {
                return YES;
            }
        }
    }
    
    return NO;
}


@end


