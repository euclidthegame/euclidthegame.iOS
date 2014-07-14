//
//  DHLevelMakeTangent.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelMakeTangent.h"

#import "DHGeometricObjects.h"

@interface DHLevelMakeTangent () {
    DHPoint* _pointA;
    DHPoint* _pointB;
}

@end

@implementation DHLevelMakeTangent

- (NSString*)subTitle
{
    return @"Tangentially related";
}

- (NSString*)levelDescription
{
    return (@"Construct a line (segment) at B tangent to the circle. "
            @"A tangent line to a circle is a line that only touches the circle at one point.");
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
    return 2;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 3;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:200 andY:200];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:300 andY:220];
    
    DHCircle* circle = [[DHCircle alloc] init];
    circle.center = pA;
    circle.pointOnRadius = pB;
    
    [geometricObjects addObject:circle];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
 
    _pointA = pA;
    _pointB = pB;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHLineSegment* r = [[DHLineSegment alloc] initWithStart:_pointA andEnd:_pointB];
    DHPerpendicularLine* pl = [[DHPerpendicularLine alloc] init];
    pl.line = r;
    pl.point = _pointB;
    
    [objects insertObject:pl atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _pointA.position;
    CGPoint pointB = _pointB.position;
    
    _pointA.position = CGPointMake(pointA.x - 1, pointA.y - 1);
    _pointB.position = CGPointMake(pointB.x + 1, pointB.y + 1);
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _pointA.position = pointA;
    _pointB.position = pointB;
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
        
        DHLineObject* l = object;
        if ((l.start == _pointB || l.end == _pointB) == NO) continue;
        
        CGVector vAB = CGVectorNormalize(CGVectorBetweenPoints(_pointA.position, _pointB.position));
        
        CGFloat lDotBC = CGVectorDotProduct(CGVectorNormalize(l.vector), vAB);
        if (fabs(lDotBC) < 0.00001) {
            return YES;
        }
    }
    
    return NO;
}


@end
