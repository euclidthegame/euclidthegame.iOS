//
//  DHLevelPentagon.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-11.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelPentagon.h"

#import "DHGeometricObjects.h"

@interface DHLevelPentagon () {
    DHCircle* _circle;
}

@end

@implementation DHLevelPentagon

- (NSString*)subTitle
{
    return @"The Pentagon";
}

- (NSString*)levelDescription
{
    return (@"Construct a regular pentagon inscribed in the given circle with B as one of its points.");
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
    return 10;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 10;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:300 andY:300];
    DHPoint* pRadiusA = [[DHPoint alloc] initWithPositionX:pA.position.x+0 andY:pA.position.y-150];
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:pA andPointOnRadius:pRadiusA];
    
    [geometricObjects addObject:c];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pRadiusA];
    
    _circle = c;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    CGVector vAB = CGVectorBetweenPoints(_circle.pointOnRadius.position, _circle.center.position);
    CGFloat side = 2*CGVectorLength(vAB)*sin(M_PI/5);
    CGVector vBC = CGVectorRotateByAngle(vAB, M_PI*3/5*0.5);
    vBC = CGVectorMultiplyByScalar(CGVectorNormalize(vBC),side);
    CGPoint pCPos = CGPointFromPointByAddingVector(_circle.pointOnRadius.position, vBC);
    CGVector vCD = CGVectorRotateByAngle(vBC, -M_PI*2/5);
    CGPoint pDPos = CGPointFromPointByAddingVector(pCPos, vCD);
    CGVector vDE = CGVectorRotateByAngle(vCD, -M_PI*2/5);
    CGPoint pEPos = CGPointFromPointByAddingVector(pDPos, vDE);
    CGVector vEF = CGVectorRotateByAngle(vDE, -M_PI*2/5);
    CGPoint pFPos = CGPointFromPointByAddingVector(pEPos, vEF);
    
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:pCPos.x andY:pCPos.y];
    DHPoint* pD = [[DHPoint alloc] initWithPositionX:pDPos.x andY:pDPos.y];
    DHPoint* pE = [[DHPoint alloc] initWithPositionX:pEPos.x andY:pEPos.y];
    DHPoint* pF = [[DHPoint alloc] initWithPositionX:pFPos.x andY:pFPos.y];

    DHLineSegment* lBC = [[DHLineSegment alloc] initWithStart:_circle.pointOnRadius andEnd:pC];
    DHLineSegment* lCD = [[DHLineSegment alloc] initWithStart:pC andEnd:pD];
    DHLineSegment* lDE = [[DHLineSegment alloc] initWithStart:pD andEnd:pE];
    DHLineSegment* lEF = [[DHLineSegment alloc] initWithStart:pE andEnd:pF];
    DHLineSegment* lFB = [[DHLineSegment alloc] initWithStart:pF andEnd:_circle.pointOnRadius];
    
    [objects insertObject:lBC atIndex:0];
    [objects insertObject:lCD atIndex:0];
    [objects insertObject:lDE atIndex:0];
    [objects insertObject:lEF atIndex:0];
    [objects insertObject:lFB atIndex:0];
    [objects addObject:pC];
    [objects addObject:pD];
    [objects addObject:pE];
    [objects addObject:pF];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _circle.center.position;
    
    _circle.center.position = CGPointMake(pointA.x+3, pointA.y+3 );
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _circle.center.position = pointA;
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    if (geometricObjects.count < 6) {
        return NO;
    }
    
    CGVector vAB = CGVectorBetweenPoints(_circle.pointOnRadius.position, _circle.center.position);
    CGFloat side = 2*CGVectorLength(vAB)*sin(M_PI/5);
    CGVector vBC = CGVectorRotateByAngle(vAB, M_PI*3/5*0.5);
    vBC = CGVectorMultiplyByScalar(CGVectorNormalize(vBC),side);
    CGPoint pCPos = CGPointFromPointByAddingVector(_circle.pointOnRadius.position, vBC);
    CGVector vCD = CGVectorRotateByAngle(vBC, -M_PI*2/5);
    CGPoint pDPos = CGPointFromPointByAddingVector(pCPos, vCD);
    CGVector vDE = CGVectorRotateByAngle(vCD, -M_PI*2/5);
    CGPoint pEPos = CGPointFromPointByAddingVector(pDPos, vDE);
    CGVector vEF = CGVectorRotateByAngle(vDE, -M_PI*2/5);
    CGPoint pFPos = CGPointFromPointByAddingVector(pEPos, vEF);
    
    DHPoint* center = _circle.center;
    DHPoint* pB = _circle.pointOnRadius;
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:pCPos.x andY:pCPos.y];
    DHPoint* pD = [[DHPoint alloc] initWithPositionX:pDPos.x andY:pDPos.y];
    DHPoint* pE = [[DHPoint alloc] initWithPositionX:pEPos.x andY:pEPos.y];
    DHPoint* pF = [[DHPoint alloc] initWithPositionX:pFPos.x andY:pFPos.y];
    
    for (int index1 = 0; index1 < geometricObjects.count-4; ++index1) {
        id object1 = [geometricObjects objectAtIndex:index1];
        if ([[object1 class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
        DHLineObject* l1 = object1;
        if (l1.start == center || l1.end == center) continue;
        CGFloat distL1B = DistanceFromPointToLine(pB, l1);
        CGFloat distL1C = DistanceFromPointToLine(pC, l1);
        CGFloat distL1D = DistanceFromPointToLine(pD, l1);
        CGFloat distL1E = DistanceFromPointToLine(pE, l1);
        CGFloat distL1F = DistanceFromPointToLine(pF, l1);
        
        // Ensure the line passes through at least one the necessary lines
        BOOL line1OK = ((distL1B < 0.01 && distL1C < 0.01) ^ (distL1C < 0.01 && distL1D < 0.01) ^
                        (distL1D < 0.01 && distL1E < 0.01) ^ (distL1E < 0.01 && distL1F < 0.01) ^
                        (distL1F < 0.01 && distL1B < 0.01));
        if (!line1OK) continue;
        
        for (int index2 = index1+1; index2 < geometricObjects.count-3; ++index2) {
            id object2 = [geometricObjects objectAtIndex:index2];
            if ([[object2 class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
            DHLineObject* l2 = object2;
            if (l2.start == center || l2.end == center) continue;
            CGFloat distL2B = DistanceFromPointToLine(pB, l2);
            CGFloat distL2C = DistanceFromPointToLine(pC, l2);
            CGFloat distL2D = DistanceFromPointToLine(pD, l2);
            CGFloat distL2E = DistanceFromPointToLine(pE, l2);
            CGFloat distL2F = DistanceFromPointToLine(pF, l2);
            
            // Ensure the line passes through at least one the necessary lines
            BOOL line2OK = ((distL2B < 0.01 && distL2C < 0.01) ^ (distL2C < 0.01 && distL2D < 0.01) ^
                            (distL2D < 0.01 && distL2E < 0.01) ^ (distL2E < 0.01 && distL2F < 0.01) ^
                            (distL2F < 0.01 && distL2B < 0.01));
            if (!line2OK) continue;
            
            for (int index3 = index2+1; index3 < geometricObjects.count-2; ++index3) {
                id object3 = [geometricObjects objectAtIndex:index3];
                if ([[object3 class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
                DHLineObject* l3 = object3;
                if (l3.start == center || l3.end == center) continue;
                CGFloat distL3B = DistanceFromPointToLine(pB, l3);
                CGFloat distL3C = DistanceFromPointToLine(pC, l3);
                CGFloat distL3D = DistanceFromPointToLine(pD, l3);
                CGFloat distL3E = DistanceFromPointToLine(pE, l3);
                CGFloat distL3F = DistanceFromPointToLine(pF, l3);
                
                // Ensure the line passes through at least one the necessary lines
                BOOL line3OK = ((distL3B < 0.01 && distL3C < 0.01) ^ (distL3C < 0.01 && distL3D < 0.01) ^
                                (distL3D < 0.01 && distL3E < 0.01) ^ (distL3E < 0.01 && distL3F < 0.01) ^
                                (distL3F < 0.01 && distL3B < 0.01));
                if (!line3OK) continue;
                
                for (int index4 = index3+1; index4 < geometricObjects.count-1; ++index4) {
                    id object4 = [geometricObjects objectAtIndex:index4];
                    if ([[object4 class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
                    DHLineObject* l4 = object4;
                    if (l4.start == center || l4.end == center) continue;
                    CGFloat distL4B = DistanceFromPointToLine(pB, l4);
                    CGFloat distL4C = DistanceFromPointToLine(pC, l4);
                    CGFloat distL4D = DistanceFromPointToLine(pD, l4);
                    CGFloat distL4E = DistanceFromPointToLine(pE, l4);
                    CGFloat distL4F = DistanceFromPointToLine(pF, l4);
                    
                    // Ensure the line passes through at least one the necessary lines
                    BOOL line4OK = ((distL4B < 0.01 && distL4C < 0.01) ^ (distL4C < 0.01 && distL4D < 0.01) ^
                                    (distL4D < 0.01 && distL4E < 0.01) ^ (distL4E < 0.01 && distL4F < 0.01) ^
                                    (distL4F < 0.01 && distL4B < 0.01));
                    if (!line4OK) continue;
                    
                    for (int index5 = index4+1; index5 < geometricObjects.count; ++index5) {
                        id object5 = [geometricObjects objectAtIndex:index5];
                        if ([[object5 class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
                        DHLineObject* l5 = object5;
                        if (l5.start == center || l5.end == center) continue;
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
                        
                        // Ensure only one line passes through F and B
                        BOOL faOK = ((distL1F < 0.01 && distL1B < 0.01) ^ (distL2F < 0.01 && distL2B < 0.01) ^
                                     (distL3F < 0.01 && distL3B < 0.01) ^ (distL4F < 0.01 && distL4B < 0.01) ^
                                     (distL5F < 0.01 && distL5B < 0.01));
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


