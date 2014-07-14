//
//  DHLevel6.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-02.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelPerpendicular.h"
#import <CoreGraphics/CGBase.h>
#import "DHGeometricObjects.h"

@interface DHLevelPerpendicular () {
    DHPoint* _pointA;
    DHPoint* _pointHidden1;
    DHPoint* _pointHidden2;
    DHLine* _lineBC;
}

@end

@implementation DHLevelPerpendicular

- (NSString*)subTitle
{
    return @"Perpendicular";
}

- (NSString*)levelDescription
{
    return @"Create a line (segment) on A that is perpendicular to the given line";
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 3;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 3;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPointOnLine* p1 = [[DHPointOnLine alloc] init];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:200 andY:300];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:500 andY:300];
    
    DHLine* l1 = [[DHLine alloc] init];
    l1.start = p2;
    l1.end = p3;

    p1.line = l1;
    p1.tValue = 0.75;
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    
    _pointA = p1;
    _lineBC = l1;
    _pointHidden1 = p2;
    _pointHidden2 = p3;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHRay* r = [[DHRay alloc] init];
    r.start = _pointA;
    DHPoint* pend = [[DHPoint alloc] initWithPositionX:_pointA.position.x andY:_pointA.position.y-10];
    r.end = pend;
    
    [objects insertObject:r atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }

    // Move B and C and ensure solution holds    
    CGPoint pointB = _lineBC.start.position;
    CGPoint pointC = _lineBC.end.position;
    
    _lineBC.start.position = CGPointMake(100, 100);
    _lineBC.end.position = CGPointMake(400, 400);
    
    complete = [self isLevelCompleteHelper:geometricObjects];

    _lineBC.start.position = pointB;
    _lineBC.end.position = pointC;
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
        
        DHLineObject* l = object;
        if ((l.start == _pointA || l.end == _pointA) == NO) continue;
        
        CGVector bc = CGVectorNormalize(_lineBC.vector);
        
        CGFloat lDotBC = CGVectorDotProduct(CGVectorNormalize(l.vector), bc);
        if (fabs(lDotBC) < 0.000001) {
            return YES;
        }
    }
    
    return NO;
}

@end
