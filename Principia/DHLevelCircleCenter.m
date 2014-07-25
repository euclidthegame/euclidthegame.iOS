//
//  DHLevelCircleCenter.m
//  Euclid
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

- (NSUInteger)minimumNumberOfMoves
{
    return 3;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 5;
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable | DHTranslateToolAvailable |
            DHCompassToolAvailable);
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
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

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    [objects addObject:_pointC];
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
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _pointC.position = pointA;
    _pointR.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    for (id object in geometricObjects){
        if(EqualPoints(object, _pointC)) {
            self.progress = 100;
            return YES;
        }
    }
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects{
    
    for (id object in objects){
    
        if(EqualPoints(object, _pointC)) return _pointC.position;
    }

    
return CGPointMake(NAN, NAN);
}

@end
