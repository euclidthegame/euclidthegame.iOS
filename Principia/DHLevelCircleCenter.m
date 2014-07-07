//
//  DHLevelCircleCenter.m
//  Principia
//
//  Created by David Hallgren on 2014-07-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelCircleCenter.h"

#import "DHGeometricObjects.h"

@interface DHLevelCircleCenter () {
    DHPoint* _pointC;
    DHPoint* _pointR;
}

@end

@implementation DHLevelCircleCenter

- (NSString*)subTitle
{
    return @"Circle center";
}

- (NSString*)levelDescription
{
    return (@"Construct a point in the center of the given circle");
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineToolAvailable | DHRayToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable | DHTranslateToolAvailable |
            DHCompassToolAvailable);
}

- (void)setUpLevel:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:200 andY:200];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:300 andY:200];
    
    DHCircle* circle = [[DHCircle alloc] init];
    circle.center = pA;
    circle.pointOnRadius = pB;
    
    [geometricObjects addObject:circle];
    
    _pointC = pA;
    _pointR = pB;
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _pointC.position;
    CGPoint pointB = _pointR.position;
    
    _pointC.position = CGPointMake(pointA.x - 1, pointA.y - 1);
    _pointR.position = CGPointMake(pointB.x + 1, pointB.y + 1);
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _pointC.position = pointA;
    _pointR.position = pointB;
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class]  isSubclassOfClass:[DHPoint class]] == NO) continue;
        
        DHPoint* p = object;
        CGFloat distance = DistanceBetweenPoints(p.position, _pointC.position);
        if (distance < 0.001) {
            return YES;
        }
    }
    
    return NO;
}


@end
