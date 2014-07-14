//
//  DHLevelLineCopy.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-05.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelLineCopy.h"

#import "DHGeometricObjects.h"

@interface DHLevelLineCopy () {
    DHLineSegment* _lineAB;
    DHPoint* _pointC;
}

@end

@implementation DHLevelLineCopy

- (NSString*)subTitle
{
    return @"Copy the line";
}

- (NSString*)levelDescription
{
    return @"Construct a line segment with the same length and same direction as line segment AB but with starting point C";
}

- (NSString *)additionalCompletionMessage
{
    return (@"You unlocked a new tool: Translating lines! Note that this new tool won't work when all points "
            @"lay on the same line. Enhance your new tool in Level 8.");
}

- (NSUInteger)minimumNumberOfMoves
{
    return 3;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 6;
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineToolAvailable | DHRayToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable);
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:180 andY:400];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:230 andY:100];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:350 andY:450];
    
    DHLineSegment* l1 = [[DHLineSegment alloc] init];
    l1.start = p1;
    l1.end = p2;
    
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
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _lineAB.start.position = pointA;
    _lineAB.end.position = pointB;
    
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
        
        CGFloat lCP = CGVectorLength(vCP);
        CGFloat lAB = CGVectorLength(vAB);
        
        if (fabs(dotProd) > 1 - 0.001 && fabs(lCP - lAB) < 0.01) {
            return YES;
        }
    }
    
    return NO;
}


@end
