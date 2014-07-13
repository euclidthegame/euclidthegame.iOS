//
//  DHLevelCopyAngle.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelCopyAngle.h"

#import "DHGeometricObjects.h"

@interface DHLevelCopyAngle () {
    DHLineSegment* _lineAB;
    DHLineSegment* _lineAC;
    DHPoint* _pointD;
    DHPoint* _pointHidden;
    DHRay* _rayD;
}

@end

@implementation DHLevelCopyAngle

- (NSString*)subTitle
{
    return @"Another angle";
}

- (NSString*)levelDescription
{
    return (@"Construct an angle at D to the given line equal to the given angle at A");
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
    return 4;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 4;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:100 andY:150];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:210 andY:100];
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:200 andY:150];
    DHPoint* pD = [[DHPoint alloc] initWithPositionX:150 andY:250];
    DHPoint* pHidden = [[DHPoint alloc] initWithPositionX:250 andY:400];
    
    DHLineSegment* lAB = [[DHLineSegment alloc] init];
    lAB.start = pA;
    lAB.end = pB;
    
    DHLineSegment* lAC = [[DHLineSegment alloc] init];
    lAC.start = pA;
    lAC.end = pC;
    
    DHRay* lFromD = [[DHRay alloc] init];
    lFromD.start = pD;
    lFromD.end = pHidden;
    
    [geometricObjects addObject:lAB];
    [geometricObjects addObject:lAC];
    [geometricObjects addObject:lFromD];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    [geometricObjects addObject:pC];
    [geometricObjects addObject:pD];

    _lineAB = lAB;
    _lineAC = lAC;
    _pointD = pD;
    _pointHidden = pHidden;
    _rayD = lFromD;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    CGVector vAB = _lineAB.vector;
    CGVector vAC = _lineAC.vector;
    
    CGFloat angle = CGVectorAngleBetween(vAB, vAC);
    CGVector vDE = CGVectorRotateByAngle(CGVectorNormalize(_rayD.vector), -angle);
    
    DHPoint* p = [[DHPoint alloc] initWithPositionX:_pointD.position.x + 100*vDE.dx
                                               andY:_pointD.position.y + 100*vDE.dy];
    DHLineSegment* r = [[DHLineSegment alloc] initWithStart:_pointD andEnd:p];
    
    [objects insertObject:r atIndex:0];
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
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
        
        DHLineObject* l = object;
        if ((l.start == _pointD || l.end == _pointD) == NO) continue;
    
        CGFloat targetAngle = CGVectorAngleBetween(_lineAB.vector, _lineAC.vector);
        CGFloat angleToDLine = CGVectorAngleBetween(l.vector, _rayD.vector);
        
        if (fabs(fabs(targetAngle) - fabs(angleToDLine)) < 0.0001) {
            return YES;
        }
    }
    
    return NO;
}


@end
