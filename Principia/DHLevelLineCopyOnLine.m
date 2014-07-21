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
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class]  isSubclassOfClass:[DHPoint class]] == NO) continue;

        DHPoint* p = object;
        
        CGVector vCP = CGVectorBetweenPoints(_lineCD.start.position, p.position);
        CGVector vAB = _lineAB.vector;
        CGVector vCD = _lineCD.vector;
        CGFloat dotProd = CGVectorDotProduct(CGVectorNormalize(vCP), CGVectorNormalize(vCD));
        
        CGFloat lCP = CGVectorLength(vCP);
        CGFloat lAB = CGVectorLength(vAB);
        
        if (fabs(dotProd) > 1 - 0.000001 && CGFloatsEqualWithinEpsilon(lCP, lAB)) {
            return YES;
        }
    }
    
    return NO;
}


@end
