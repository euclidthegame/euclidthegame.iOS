//
//  DHLevelLineCopyOnLine.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelLineCopyOnLine.h"

#import "DHGeometricObjects.h"

@interface DHLevelLineCopyOnLine () {
    DHLineSegment* _lineAB;
    DHLineSegment* _lineCD;
}

@end

@implementation DHLevelLineCopyOnLine

- (NSString*)subTitle
{
    return @"Staying online";
}

- (NSString*)levelDescription
{
    return (@"Construct a new point E on the line segment CD such that CE has the same length as AB");
}

- (NSUInteger)minimumNumberOfMoves
{
    return 1;
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
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:100 andY:300];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:200 andY:400];
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:150 andY:200];
    DHPoint* pD = [[DHPoint alloc] initWithPositionX:400 andY:200];
    
    DHLineSegment* lAB = [[DHLineSegment alloc] init];
    lAB.start = pA;
    lAB.end = pB;
    
    DHLineSegment* lCD = [[DHLineSegment alloc] init];
    lCD.start = pC;
    lCD.end = pD;
    
    [geometricObjects addObject:lAB];
    [geometricObjects addObject:lCD];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    [geometricObjects addObject:pC];
    [geometricObjects addObject:pD];
    
    _lineAB = lAB;
    _lineCD = lCD;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = _lineCD.start;
    tp.translationStart = _lineAB.start;
    tp.translationEnd = _lineAB.end;
    DHCircle* c = [[DHCircle alloc] initWithCenter:_lineCD.start andPointOnRadius:tp];
    DHIntersectionPointLineCircle* ip = [[DHIntersectionPointLineCircle alloc] init];
    ip.c = c;
    ip.l = _lineCD;
    
    [objects addObject:ip];
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
    
    _lineAB.start.position = CGPointMake(110, 300);
    _lineAB.end.position = CGPointMake(205, 450);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _lineAB.start.position = pointA;
    _lineAB.end.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = _lineCD.start;
    tp.translationStart = _lineAB.start;
    tp.translationEnd = _lineAB.end;
    DHCircle* circle = [[DHCircle alloc] initWithCenter:_lineCD.start andPointOnRadius:tp];
    CGFloat distAB = DistanceBetweenPoints(_lineAB.start.position, _lineAB.end.position);
    
    BOOL circleWithABRadiusAtCOK = NO;
    
    for (id object in geometricObjects){
        if (PointOnLine(object,_lineCD)){
            DHPoint* p = object;
            CGFloat distCP = DistanceBetweenPoints(p.position, _lineCD.start.position);
            if (EqualScalarValues(distAB, distCP)) {
                self.progress = 100;
                return YES;
            }
        }
        if (EqualCircles(object,circle)) {
            circleWithABRadiusAtCOK = YES;
        }
    }
    
    self.progress = circleWithABRadiusAtCOK/2.0*100;
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = _lineCD.start;
    tp.translationStart = _lineAB.start;
    tp.translationEnd = _lineAB.end;
    DHCircle* circle = [[DHCircle alloc] initWithCenter:_lineCD.start andPointOnRadius:tp];
    
    for (id object in objects){
        if (PointOnLine(object,_lineCD)){
            DHPoint* p = object;
            if (LineSegmentsWithEqualLength([[DHLineSegment alloc]initWithStart:_lineCD.start andEnd:p],_lineAB))
                return p.position;
        }
        if (EqualCircles(object,circle)) return circle.center.position;
        
    }
    
    return CGPointMake(NAN, NAN);
}


@end
