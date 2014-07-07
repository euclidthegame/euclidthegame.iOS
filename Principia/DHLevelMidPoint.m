//
//  DHLevel3.m
//  Principia
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelMidPoint.h"
#import <CoreGraphics/CGBase.h>
#import "DHGeometricObjects.h"

@interface DHLevelMidPoint () {
    DHLineSegment* _initialLine;
}

@end

@implementation DHLevelMidPoint

- (NSString*)subTitle
{
    return @"Half 'n Half";
}

- (NSString*)levelDescription
{
    return @"Create a point exactly dividing the line AB into two parts of equal length";
}

- (NSString *)additionalCompletionMessage
{
    return @"You unlocked a new tool: Constructing a midpoint!";
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineToolAvailable | DHRayToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable);
}

- (void)setUpLevel:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:300];
    DHLineSegment* l1 = [[DHLineSegment alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    [geometricObjects addObject:l1];
    
    _initialLine = l1;
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _initialLine.start.position;
    CGPoint pointB = _initialLine.end.position;
    
    _initialLine.start.position = CGPointMake(100, 100);
    _initialLine.end.position = CGPointMake(400, 400);
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _initialLine.start.position = pointA;
    _initialLine.end.position = pointB;
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class] isSubclassOfClass:[DHPoint class]] == NO) continue;
        if (object == _initialLine.start || object == _initialLine.end) continue;
        
        DHPoint* p = object;
        CGPoint currentPoint = p.position;
        CGPoint midPoint = MidPointFromPoints(_initialLine.start.position, _initialLine.end.position);
        if (CGFloatsEqualWithinEpsilon(currentPoint.x, midPoint.x) &&
            CGFloatsEqualWithinEpsilon(currentPoint.y, midPoint.y)) {
            return YES;
        }
    }
    
    return NO;
}


@end
