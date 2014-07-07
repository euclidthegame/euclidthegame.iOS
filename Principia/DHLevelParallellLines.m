//
//  DHLevelParallellLines.m
//  Principia
//
//  Created by David Hallgren on 2014-07-04.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelParallellLines.h"

#import "DHGeometricObjects.h"

@interface DHLevelParallellLines () {
    DHPoint* _pointC;
    DHLine* _lineAB;
}

@end

@implementation DHLevelParallellLines

- (NSString*)subTitle
{
    return @"Parallell";
}

- (NSString*)levelDescription
{
    return @"Construct line through point B parallell to the given line through A";
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineToolAvailable | DHRayToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable | DHPerpendicularToolAvailable);
}

- (void)setUpLevel:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:300];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:400 andY:200];
    
    DHLine* l1 = [[DHLine alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    [geometricObjects addObject:p3];
    [geometricObjects addObject:l1];
    
    _pointC = p3;
    _lineAB = l1;
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
    
    _lineAB.start.position = CGPointMake(280, 300);
    _lineAB.end.position = CGPointMake(480, 400);
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _lineAB.start.position = pointA;
    _lineAB.end.position = pointB;
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
        
        DHLineObject* l = object;
        if ((l.start == _pointC || l.end == _pointC) == NO) continue;
        
        CGVector bc = CGVectorNormalize(_lineAB.vector);
        
        CGFloat lDotBC = CGVectorDotProduct(CGVectorNormalize(l.vector), bc);
        if (fabs(lDotBC) > 1 - 0.000001) {
            return YES;
        }
    }
    
    return NO;
}


@end
