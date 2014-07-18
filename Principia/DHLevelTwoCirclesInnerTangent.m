//
//  DHLevelTwoCirclesInnerTangent.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-11.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelTwoCirclesInnerTangent.h"

#import "DHGeometricObjects.h"

@interface DHLevelTwoCirclesInnerTangent () {
    DHCircle* _circleA;
    DHCircle* _circleB;
    DHPoint* _pRadiusA;
    DHPoint* _pRadiusB;
}

@end

@implementation DHLevelTwoCirclesInnerTangent

- (NSString*)subTitle
{
    return @"Inner tangent";
}

- (NSString*)levelDescription
{
    return (@"Construct a line (segment) tangent to both circles. Construct an inner tangent line.");
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
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:200 andY:300];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:400 andY:300];
    DHPoint* pRadiusA = [[DHPoint alloc] initWithPositionX:pA.position.x+0 andY:pA.position.y+80];
    DHPoint* pRadiusB = [[DHPoint alloc] initWithPositionX:pB.position.x+0 andY:pB.position.y-50];
    
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
    DHRay* r2 = [[DHRay alloc] initWithStart:_pRadiusA andEnd:_pRadiusB];
    
    DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] initWithLine:r1 andLine:r2];
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = ip1;
    mp.end = _circleA.center;
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_circleA.center];
    DHIntersectionPointCircleCircle* ip2 = [[DHIntersectionPointCircleCircle alloc] init];
    ip2.c1 = c;
    ip2.c2 = _circleA;
    
    DHLine* tangent = [[DHLine alloc] initWithStart:ip2 andEnd:ip1];
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
    
    _circleA.center.position = CGPointMake(pointA.x, pointA.y+3 );
    _circleB.center.position = CGPointMake(pointB.x, pointB.y-3 );
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _circleA.center.position = pointA;
    _circleB.center.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    DHLine* l1 = [[DHLine alloc] initWithStart:_circleB.center andEnd:_circleA.center];
    DHPointOnCircle* p1 = [[DHPointOnCircle alloc] init];
    p1.circle = _circleA;
    p1.angle = M_PI_2;
    DHPointOnCircle* p2 = [[DHPointOnCircle alloc] init];
    p2.circle = _circleB;
    p2.angle = -M_PI_2;
    DHLine* l2 = [[DHLine alloc] initWithStart:p1 andEnd:p2];
    
    DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] initWithLine:l1 andLine:l2];
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

    DHLine* tangent1 = [[DHLine alloc] initWithStart:ip1 andEnd:ip2];
    DHLine* tangent2 = [[DHLine alloc] initWithStart:ip1 andEnd:ip3];
    
    for (int index1 = 0; index1 < geometricObjects.count; ++index1) {
        id object1 = [geometricObjects objectAtIndex:index1];
        if ([[object1 class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
        
        DHLineObject* l1 = object1;
        CGVector l1Vector = l1.vector;
        CGVector tangent1Vector = tangent1.vector;
        CGVector tangent2Vector = tangent2.vector;
        
        // Reverse direction if in different directions to only compare angle to 0 instead of also 180 deg. case
        if (CGVectorDotProduct(l1Vector, tangent1Vector) < 0) {
            l1Vector.dx = -l1Vector.dx;
            l1Vector.dy = -l1Vector.dy;
        }
        CGFloat angleL1Tangent1 = CGVectorAngleBetween(l1Vector, tangent1Vector);
        CGFloat angleL1Tangent2 = CGVectorAngleBetween(l1Vector, tangent2Vector);
        
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


