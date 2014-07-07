//
//  DHLevelNonEquiTri.m
//  Principia
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
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineToolAvailable | DHRayToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable | DHTranslateToolAvailable |
            DHCompassToolAvailable);
}

- (void)setUpLevel:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:250 andY:200];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:400 andY:200];
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:100 andY:170];
    DHPoint* pD = [[DHPoint alloc] initWithPositionX:150 andY:100];
    DHPoint* pE = [[DHPoint alloc] initWithPositionX:120 andY:230];
    DHPoint* pF = [[DHPoint alloc] initWithPositionX:180 andY:300];
    
    DHLineSegment* lAB = [[DHLineSegment alloc] init];
    lAB.start = pA;
    lAB.end = pB;
    
    DHLineSegment* lCD = [[DHLineSegment alloc] init];
    lCD.start = pC;
    lCD.end = pD;

    DHLineSegment* lEF = [[DHLineSegment alloc] init];
    lEF.start = pE;
    lEF.end = pF;
    
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    [geometricObjects addObject:pC];
    [geometricObjects addObject:pD];
    [geometricObjects addObject:pE];
    [geometricObjects addObject:pF];
    [geometricObjects addObject:lAB];
    [geometricObjects addObject:lCD];
    [geometricObjects addObject:lEF];
    
    _lineAB = lAB;
    _lineCD = lCD;
    _lineEF = lEF;
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
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _lineAB.start.position = pointA;
    _lineAB.end.position = pointB;
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    for (int index2 = 1; index2 < geometricObjects.count-1; ++index2) {
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
