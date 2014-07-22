//
//  DHLevelLineCopy2.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-05.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelLineCopy2.h"

#import "DHGeometricObjects.h"

@interface DHLevelLineCopy2 () {
    DHLineSegment* _lineAB;
    DHPoint* _pointC;
}

@end

@implementation DHLevelLineCopy2

- (NSString*)subTitle
{
    return @"Straight translation";
}

- (NSString*)levelDescription
{
    return (@"Construct a line segment with the same length and same direction as the line segment AB "
            @"but with starting point C");
}

- (NSString *)additionalCompletionMessage
{
    return (@"You enhanced your tool: Translating lines!");
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable |
            DHTranslateToolAvailable_Weak);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 2;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 4;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:180 andY:200];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:330 andY:150];
    
    DHLineSegment* l1 = [[DHLineSegment alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    DHPointOnLine* p3 = [[DHPointOnLine alloc] init];
    p3.line = l1;
    p3.tValue = 1.4;
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    [geometricObjects addObject:p3];
    
    _pointC = p3;
    _lineAB = l1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHTranslatedPoint* p = [[DHTranslatedPoint alloc] init];
    p.startOfTranslation = _pointC;
    p.translationStart = _lineAB.start;
    p.translationEnd = _lineAB.end;
    
    DHLineSegment* l = [[DHLineSegment alloc] initWithStart:_pointC andEnd:p];
    
    [objects insertObject:l atIndex:0];
    [objects addObject:p];
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
    
    _lineAB.start.position = CGPointMake(200, 300);
    _lineAB.end.position = CGPointMake(220, 150);
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
        if (object == _pointC) continue;
        
        DHPoint* p = object;
        
        CGVector vCP = CGVectorBetweenPoints(_pointC.position, p.position);
        CGVector vAB = _lineAB.vector;
        CGFloat dotProd = CGVectorDotProduct(CGVectorNormalize(vCP), CGVectorNormalize(vAB));
        
        if (!(dotProd > 1 - 0.001)) continue;
        
        CGFloat lCP = CGVectorLength(vCP);
        CGFloat lAB = CGVectorLength(vAB);
        CGFloat lengthDiff = fabs(lCP - lAB);
        if (lengthDiff < 0.01) {
            self.progress = 100;
            return YES;
        }
    }
    
    return NO;
}


@end