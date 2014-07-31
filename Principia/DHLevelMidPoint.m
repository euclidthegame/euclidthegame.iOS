//
//  DHLevel3.m
//  Euclid
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
    return @"Construct the midpoint of line segment AB.";
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct the midpoint of line segment AB. \n\nThe midpoint divides the line segment AB into two parts of equal length.");
}

- (NSString *)additionalCompletionMessage
{
    return @"Well done ! You unlocked a new tool: Constructing a midpoint!";
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable);
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
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:300];
    DHLineSegment* l1 = [[DHLineSegment alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    
    _initialLine = l1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHMidPoint* mid = [[DHMidPoint alloc] init];
    mid.start = _initialLine.start;
    mid.end = _initialLine.end;
    [objects addObject:mid];
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
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _initialLine.start.position = pointA;
    _initialLine.end.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    BOOL pointOnMidLineOK = NO;
    BOOL secondPontOnMidLineOK = NO;
    BOOL midPointOK = NO;
    
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:_initialLine.start andPoint2:_initialLine.end];
    DHPerpendicularLine* midLine = [[DHPerpendicularLine alloc] initWithLine:_initialLine andPoint:mp];
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class] isSubclassOfClass:[DHPoint class]] == NO) continue;
        if (object == _initialLine.start || object == _initialLine.end) continue;
        
        DHPoint* p = object;
        CGPoint currentPoint = p.position;
        if (DistanceBetweenPoints(mp.position, currentPoint) < 0.0001) {
            midPointOK = YES;
        }
        if (DistanceFromPointToLine(p, midLine) < 0.0001) {
            if (!pointOnMidLineOK) {
                pointOnMidLineOK = YES;
            } else {
                secondPontOnMidLineOK = YES;
            }
        }
    }
    
    self.progress = (pointOnMidLineOK + secondPontOnMidLineOK + midPointOK)/3.0 * 100;
    if (midPointOK) {
        self.progress = 100;
        return YES;
    }
    
    return NO;
}

- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{

DHCircle* cAB = [[DHCircle alloc] initWithCenter:_initialLine.start andPointOnRadius:_initialLine.end];
DHCircle* cBA = [[DHCircle alloc] initWithCenter:_initialLine.end andPointOnRadius:_initialLine.start];
DHTrianglePoint* pTop = [[DHTrianglePoint alloc] initWithPoint1:_initialLine.start andPoint2:_initialLine.end];
DHTrianglePoint* pBottom = [[DHTrianglePoint alloc] initWithPoint1:_initialLine.end andPoint2:_initialLine.start];
DHLineSegment* segment = [[DHLineSegment alloc]initWithStart:pBottom andEnd:pTop];
DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:_initialLine.start andPoint2:_initialLine.end];

for (id object in objects){
    if (EqualCircles(object,cAB)) return cAB.center.position;
    if (EqualCircles(object,cBA)) return cBA.center.position;
    if (EqualPoints(object, pTop)) return pTop.position;
    if (EqualPoints(object,pBottom)) return pBottom.position;
    if (LineObjectCoversSegment(object,segment)) return MidPointFromPoints(segment.start.position,segment.end.position);
    if (EqualPoints(object,mp)) return mp.position;
}
    return CGPointMake(NAN, NAN);

}
@end
