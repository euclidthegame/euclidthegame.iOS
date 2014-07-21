//
//  DHLevelNonEquiTri.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelNonEquiTri.h"

#import "DHGeometricObjects.h"

@interface DHLevelNonEquiTri () {
    DHLineSegment* _lineAB;
    DHLineSegment* _lineCD;
    DHLineSegment* _lineEF;
}

@end

@implementation DHLevelNonEquiTri

- (NSString*)subTitle
{
    return @"Side orders";
}

- (NSString*)levelDescription
{
    return (@"Construct a triangle whose sides have the same length as the given segments using segment AB as base");
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
    return 4;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 12;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:250 andY:200];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:400 andY:200];
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:100 andY:170];
    DHPoint* pD = [[DHPoint alloc] initWithPositionX:140 andY:110];
    DHPoint* pE = [[DHPoint alloc] initWithPositionX:120 andY:230];
    DHPoint* pF = [[DHPoint alloc] initWithPositionX:180 andY:300];
    
    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:pA andEnd:pB];
    DHLineSegment* lCD = [[DHLineSegment alloc] initWithStart:pC andEnd:pD];
    DHLineSegment* lEF = [[DHLineSegment alloc] initWithStart:pE andEnd:pF];
    
    [geometricObjects addObjectsFromArray:@[lAB, lCD, lEF, pA, pB, pC, pD, pE, pF]];
    
    _lineAB = lAB;
    _lineCD = lCD;
    _lineEF = lEF;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHTranslatedPoint* tp1 = [[DHTranslatedPoint alloc] init];
    tp1.startOfTranslation = _lineAB.start;
    tp1.translationStart = _lineCD.start;
    tp1.translationEnd = _lineCD.end;

    DHTranslatedPoint* tp2 = [[DHTranslatedPoint alloc] init];
    tp2.startOfTranslation = _lineAB.end;
    tp2.translationStart = _lineEF.start;
    tp2.translationEnd = _lineEF.end;
    
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:_lineAB.start andPointOnRadius:tp1];
    DHCircle* c2 = [[DHCircle alloc] initWithCenter:_lineAB.end andPointOnRadius:tp2];
    
    DHIntersectionPointCircleCircle* p = [[DHIntersectionPointCircleCircle alloc] init];
    p.c1 = c1;
    p.c2 = c2;
    p.onPositiveY = YES;
    
    DHLineSegment* l1 = [[DHLineSegment alloc] initWithStart:_lineAB.start andEnd:p];
    DHLineSegment* l2 = [[DHLineSegment alloc] initWithStart:_lineAB.end andEnd:p];
    
    [objects insertObject:l1 atIndex:0];
    [objects insertObject:l2 atIndex:0];
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
    
    _lineAB.start.position = CGPointMake(pointA.x + 10, pointA.y + 10);
    _lineAB.end.position = CGPointMake(pointB.x - 15, pointB.y - 15);
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
    for (int index2 = 0; index2 < geometricObjects.count-1; ++index2) {
        id object2 = [geometricObjects objectAtIndex:index2];
        if ([[object2 class] isSubclassOfClass:[DHLineSegment class]] == NO) continue;
        if (object2 == _lineAB || object2 == _lineCD || object2 == _lineEF) continue;
        
        for (int index3 = index2+1; index3 < geometricObjects.count; ++index3) {
            id object3 = [geometricObjects objectAtIndex:index3];
            if ([[object3 class] isSubclassOfClass:[DHLineSegment class]] == NO) continue;
            if (object3 == _lineAB || object3 == _lineCD || object3 == _lineEF) continue;
            
            DHLineSegment* l1 = _lineAB;
            DHLineSegment* l2 = object2;
            DHLineSegment* l3 = object3;
            
            CGFloat length2 = l2.length;
            CGFloat length3 = l3.length;
            
            CGFloat lengthCD = _lineCD.length;
            CGFloat lengthEF = _lineEF.length;

            BOOL correctLengthCD = CGFloatsEqualWithinEpsilon(length2, lengthCD) || CGFloatsEqualWithinEpsilon(length3, lengthCD);
            BOOL correctLengthEF = CGFloatsEqualWithinEpsilon(length2, lengthEF) || CGFloatsEqualWithinEpsilon(length3, lengthEF);
            
            // Ensure all lines are connected and of same length
            BOOL connected = AreLinesConnected(l1,l2) && AreLinesConnected(l2,l3) && AreLinesConnected(l3,l1);
            
            if (connected && correctLengthCD && correctLengthEF) {
                return YES;
            }
        }
    }
    
    return NO;
}


@end
