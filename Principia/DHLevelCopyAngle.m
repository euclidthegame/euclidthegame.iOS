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
    DHRay* _rayA1;
    DHRay* _rayA2;
    DHPoint* _pointB;
    DHPoint* _pointHidden;
    DHRay* _rayB;
}

@end

@implementation DHLevelCopyAngle

- (NSString*)subTitle
{
    return @"Another angle";
}

- (NSString*)levelDescription
{
    return (@"Construct an angle at B to the given line equal to the given angle at A");
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
    return 4;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:80 andY:190];
    DHPoint* pA1 = [[DHPoint alloc] initWithPositionX:210 andY:120];
    DHPoint* pA2 = [[DHPoint alloc] initWithPositionX:200 andY:190];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:170 andY:250];
    DHPoint* pB1 = [[DHPoint alloc] initWithPositionX:250 andY:400];
    
    DHRay* lA1 = [[DHRay alloc] initWithStart:pA andEnd:pA1];
    DHRay* lA2 = [[DHRay alloc] initWithStart:pA andEnd:pA2];
    
    DHRay* lFromB = [[DHRay alloc] initWithStart:pB andEnd:pB1];
    
    [geometricObjects addObject:lA1];
    [geometricObjects addObject:lA2];
    [geometricObjects addObject:lFromB];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];

    _rayA1 = lA1;
    _rayA2 = lA2;
    _pointB = pB;
    _pointHidden = pB1;
    _rayB = lFromB;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    CGVector vAB = _rayA1.vector;
    CGVector vAC = _rayA2.vector;
    
    CGFloat angle = CGVectorAngleBetween(vAB, vAC);
    CGVector vDE = CGVectorRotateByAngle(CGVectorNormalize(_rayB.vector), -angle);
    
    DHPoint* p = [[DHPoint alloc] initWithPositionX:_pointB.position.x + 100*vDE.dx
                                               andY:_pointB.position.y + 100*vDE.dy];
    DHLineSegment* r = [[DHLineSegment alloc] initWithStart:_pointB andEnd:p];
    
    [objects insertObject:r atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _rayA1.start.position;
    CGPoint pointB = _rayA1.end.position;
    
    _rayA1.start.position = CGPointMake(pointA.x + 10, pointA.y + 10);
    _rayA1.end.position = CGPointMake(pointB.x - 15, pointB.y - 15);
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _rayA1.start.position = pointA;
    _rayA1.end.position = pointB;
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
        
        DHLineObject* l = object;
        if ((l.start == _pointB || l.end == _pointB) == NO) continue;
    
        CGFloat targetAngle = CGVectorAngleBetween(_rayA1.vector, _rayA2.vector);
        CGFloat angleToDLine = CGVectorAngleBetween(l.vector, _rayB.vector);
        
        if (fabs(fabs(targetAngle) - fabs(angleToDLine)) < 0.0001) {
            return YES;
        }
    }
    
    return NO;
}


@end
