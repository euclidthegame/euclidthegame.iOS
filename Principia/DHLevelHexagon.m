//
//  DHLevelHexagon.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-11.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelHexagon.h"

#import "DHGeometricObjects.h"

@interface DHLevelHexagon () {
    DHLineSegment* _lineAB;
}

@end

@implementation DHLevelHexagon

- (NSString*)subTitle
{
    return @"Super hexagon";
}

- (NSString*)levelDescription
{
    return (@"Construct a regular hexagon given one side AB");
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineToolAvailable | DHRayToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable | DHTranslateToolAvailable |
            DHCompassToolAvailable);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 6;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:300 andY:400];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:450 andY:400];
    
    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:pA andEnd:pB];
    
    [geometricObjects addObject:lAB];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];

    _lineAB = lAB;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHTrianglePoint* center = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.start
                                                            andPoint2:_lineAB.end];
    DHPoint* pA = _lineAB.start;
    DHPoint* pB = _lineAB.end;
    DHPoint* pC = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pB];
    DHPoint* pD = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pC];
    DHPoint* pE = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pD];
    DHPoint* pF = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pE];
    
    DHLineSegment* lBC = [[DHLineSegment alloc] initWithStart:pB andEnd:pC];
    DHLineSegment* lCD = [[DHLineSegment alloc] initWithStart:pC andEnd:pD];
    DHLineSegment* lDE = [[DHLineSegment alloc] initWithStart:pD andEnd:pE];
    DHLineSegment* lEF = [[DHLineSegment alloc] initWithStart:pE andEnd:pF];
    DHLineSegment* lFA = [[DHLineSegment alloc] initWithStart:pF andEnd:pA];
    
    [objects insertObject:lBC atIndex:0];
    [objects insertObject:lCD atIndex:0];
    [objects insertObject:lDE atIndex:0];
    [objects insertObject:lEF atIndex:0];
    [objects insertObject:lFA atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];

    DHPoint* pA = _lineAB.start;
    DHPoint* pB = _lineAB.end;
    
    if (!complete) {
        // Switch AB and see if other direction works
        _lineAB.start = pB;
        _lineAB.end = pA;
        complete = [self isLevelCompleteHelper:geometricObjects];
    }
    
    if (complete) {
        // Move A and B and ensure solution holds
        CGPoint pointA = pA.position;
        CGPoint pointB = pB.position;
        
        pA.position = CGPointMake(pointA.x - 10, pointA.y - 10);
        pB.position = CGPointMake(pointB.x + 10, pointB.y + 10);
        
        complete = [self isLevelCompleteHelper:geometricObjects];
        
        pA.position = pointA;
        pB.position = pointB;
    }
    
    // Switch back AB if change to original setup
    _lineAB.start = pA;
    _lineAB.end = pB;
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    if (geometricObjects.count < 6) {
        return NO;
    }
    
    DHTrianglePoint* center = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.start
                                                            andPoint2:_lineAB.end];
    DHPoint* pA = _lineAB.start;
    DHPoint* pB = _lineAB.end;
    DHPoint* pC = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pB];
    DHPoint* pD = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pC];
    DHPoint* pE = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pD];
    DHPoint* pF = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pE];
    
    for (int index1 = 0; index1 < geometricObjects.count-4; ++index1) {
        id object1 = [geometricObjects objectAtIndex:index1];
        if ([[object1 class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
        DHLineObject* l1 = object1;
        if (l1.start == center || l1.end == center) continue;
        CGFloat distL1A = DistanceFromPointToLine(pA, l1);
        CGFloat distL1B = DistanceFromPointToLine(pB, l1);
        CGFloat distL1C = DistanceFromPointToLine(pC, l1);
        CGFloat distL1D = DistanceFromPointToLine(pD, l1);
        CGFloat distL1E = DistanceFromPointToLine(pE, l1);
        CGFloat distL1F = DistanceFromPointToLine(pF, l1);
        
        // Ensure the line passes through at least one the necessary lines
        BOOL line1OK = ((distL1B < 0.01 && distL1C < 0.01) ^ (distL1C < 0.01 && distL1D < 0.01) ^
                     (distL1D < 0.01 && distL1E < 0.01) ^ (distL1E < 0.01 && distL1F < 0.01) ^
                     (distL1F < 0.01 && distL1A < 0.01));
        if (!line1OK) continue;
        
        for (int index2 = index1+1; index2 < geometricObjects.count-3; ++index2) {
            id object2 = [geometricObjects objectAtIndex:index2];
            if ([[object2 class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
            DHLineObject* l2 = object2;
            if (l2.start == center || l2.end == center) continue;
            CGFloat distL2A = DistanceFromPointToLine(pA, l2);
            CGFloat distL2B = DistanceFromPointToLine(pB, l2);
            CGFloat distL2C = DistanceFromPointToLine(pC, l2);
            CGFloat distL2D = DistanceFromPointToLine(pD, l2);
            CGFloat distL2E = DistanceFromPointToLine(pE, l2);
            CGFloat distL2F = DistanceFromPointToLine(pF, l2);

            // Ensure the line passes through at least one the necessary lines
            BOOL line2OK = ((distL2B < 0.01 && distL2C < 0.01) ^ (distL2C < 0.01 && distL2D < 0.01) ^
                            (distL2D < 0.01 && distL2E < 0.01) ^ (distL2E < 0.01 && distL2F < 0.01) ^
                            (distL2F < 0.01 && distL2A < 0.01));
            if (!line2OK) continue;
            
            for (int index3 = index2+1; index3 < geometricObjects.count-2; ++index3) {
                id object3 = [geometricObjects objectAtIndex:index3];
                if ([[object3 class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
                DHLineObject* l3 = object3;
                if (l3.start == center || l3.end == center) continue;
                CGFloat distL3A = DistanceFromPointToLine(pA, l3);
                CGFloat distL3B = DistanceFromPointToLine(pB, l3);
                CGFloat distL3C = DistanceFromPointToLine(pC, l3);
                CGFloat distL3D = DistanceFromPointToLine(pD, l3);
                CGFloat distL3E = DistanceFromPointToLine(pE, l3);
                CGFloat distL3F = DistanceFromPointToLine(pF, l3);

                // Ensure the line passes through at least one the necessary lines
                BOOL line3OK = ((distL3B < 0.01 && distL3C < 0.01) ^ (distL3C < 0.01 && distL3D < 0.01) ^
                                (distL3D < 0.01 && distL3E < 0.01) ^ (distL3E < 0.01 && distL3F < 0.01) ^
                                (distL3F < 0.01 && distL3A < 0.01));
                if (!line3OK) continue;
                
                for (int index4 = index3+1; index4 < geometricObjects.count-1; ++index4) {
                    id object4 = [geometricObjects objectAtIndex:index4];
                    if ([[object4 class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
                    DHLineObject* l4 = object4;
                    if (l4.start == center || l4.end == center) continue;
                    CGFloat distL4A = DistanceFromPointToLine(pA, l4);
                    CGFloat distL4B = DistanceFromPointToLine(pB, l4);
                    CGFloat distL4C = DistanceFromPointToLine(pC, l4);
                    CGFloat distL4D = DistanceFromPointToLine(pD, l4);
                    CGFloat distL4E = DistanceFromPointToLine(pE, l4);
                    CGFloat distL4F = DistanceFromPointToLine(pF, l4);

                    // Ensure the line passes through at least one the necessary lines
                    BOOL line4OK = ((distL4B < 0.01 && distL4C < 0.01) ^ (distL4C < 0.01 && distL4D < 0.01) ^
                                    (distL4D < 0.01 && distL4E < 0.01) ^ (distL4E < 0.01 && distL4F < 0.01) ^
                                    (distL4F < 0.01 && distL4A < 0.01));
                    if (!line4OK) continue;
                    
                    for (int index5 = index4+1; index5 < geometricObjects.count; ++index5) {
                        id object5 = [geometricObjects objectAtIndex:index5];
                        if ([[object5 class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
                        DHLineObject* l5 = object5;
                        if (l5.start == center || l5.end == center) continue;
                        CGFloat distL5A = DistanceFromPointToLine(pA, l5);
                        CGFloat distL5B = DistanceFromPointToLine(pB, l5);
                        CGFloat distL5C = DistanceFromPointToLine(pC, l5);
                        CGFloat distL5D = DistanceFromPointToLine(pD, l5);
                        CGFloat distL5E = DistanceFromPointToLine(pE, l5);
                        CGFloat distL5F = DistanceFromPointToLine(pF, l5);
                        
                        // Ensure only one line passes through B and C
                        BOOL bcOK = ((distL1B < 0.01 && distL1C < 0.01) ^ (distL2B < 0.01 && distL2C < 0.01) ^
                                     (distL3B < 0.01 && distL3C < 0.01) ^ (distL4B < 0.01 && distL4C < 0.01) ^
                                     (distL5B < 0.01 && distL5C < 0.01));
                        if (!bcOK) continue;

                        // Ensure only one line passes through C and D
                        BOOL cdOK = ((distL1C < 0.01 && distL1D < 0.01) ^ (distL2C < 0.01 && distL2D < 0.01) ^
                                     (distL3C < 0.01 && distL3D < 0.01) ^ (distL4C < 0.01 && distL4D < 0.01) ^
                                     (distL5C < 0.01 && distL5D < 0.01));
                        if (!cdOK) continue;

                        // Ensure only one line passes through D and E
                        BOOL deOK = ((distL1D < 0.01 && distL1E < 0.01) ^ (distL2D < 0.01 && distL2E < 0.01) ^
                                     (distL3D < 0.01 && distL3E < 0.01) ^ (distL4D < 0.01 && distL4E < 0.01) ^
                                     (distL5D < 0.01 && distL5E < 0.01));
                        if (!deOK) continue;

                        // Ensure only one line passes through E and F
                        BOOL efOK = ((distL1E < 0.01 && distL1F < 0.01) ^ (distL2E < 0.01 && distL2F < 0.01) ^
                                     (distL3E < 0.01 && distL3F < 0.01) ^ (distL4E < 0.01 && distL4F < 0.01) ^
                                     (distL5E < 0.01 && distL5F < 0.01));
                        if (!efOK) continue;

                        // Ensure only one line passes through F and A
                        BOOL faOK = ((distL1F < 0.01 && distL1A < 0.01) ^ (distL2F < 0.01 && distL2A < 0.01) ^
                                     (distL3F < 0.01 && distL3A < 0.01) ^ (distL4F < 0.01 && distL4A < 0.01) ^
                                     (distL5F < 0.01 && distL5A < 0.01));
                        if (!faOK) continue;

                        if (bcOK && cdOK && deOK && efOK && faOK) {
                            return YES;
                        }
                        
                    }
                }
            }
        }
    }
    
    return NO;
}


@end


