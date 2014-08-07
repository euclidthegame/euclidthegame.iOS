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
    DHCircle* _circle;
}

@end

@implementation DHLevelMakeTangent

- (NSString*)subTitle
{
    return @"Tangentially related";
}

- (NSString*)levelDescription
{
    return (@"Construct a line (segment) tangent to the given circle");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct a line (segment) tangent to the circle. \n\n"
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
    return 3;
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
 
    _circle = circle;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    
    DHLineSegment* r = [[DHLineSegment alloc] initWithStart:_circle.center andEnd:_circle.pointOnRadius];
    DHPerpendicularLine* pl = [[DHPerpendicularLine alloc] initWithLine:r andPoint:r.end];
    
    [objects insertObject:pl atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    DHPoint* pCenter = _circle.center;
    DHPoint* pRadius = _circle.pointOnRadius;
    
    // Move A and B and ensure solution holds
    CGPoint pointA = pCenter.position;
    CGPoint pointB = pRadius.position;
    
    pCenter.position = CGPointMake(pointA.x - 1, pointA.y - 1);
    pRadius.position = CGPointMake(pointB.x + 1, pointB.y + 1);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    pCenter.position = pointA;
    pRadius.position = pointB;
    
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    BOOL tangentOK = NO;
    
    for (id object in geometricObjects) {
        if (LineObjectTangentToCircle(object, _circle)) {
            tangentOK = YES;
            break;
        }
    }
    
    if (tangentOK) {
        self.progress = 100;
        return YES;
    }
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects{
    
    /*DHLineSegment* sAB = [[DHLineSegment alloc] initWithStart:_pointA andEnd:_pointB];
    DHPerpendicularLine *perp = [[DHPerpendicularLine alloc]initWithLine:sAB andPoint:_pointB];
    
    for (id object in objects){
        if(EqualDirection(object,sAB)) return MidPointFromLine(sAB);
        if(EqualDirection(perp, object)) return _pointB.position;
    
    }*/
    
    return CGPointMake(NAN, NAN);
}

@end
