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
    return 3;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 5;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pAStart = [[DHPoint alloc] initWithPositionX:50 andY:190];
    DHPoint* pA1 = [[DHPoint alloc] initWithPositionX:210 andY:120];
    DHPoint* pA2 = [[DHPoint alloc] initWithPositionX:200 andY:190];
    DHMidPoint* pAEndTemp1 = [[DHMidPoint alloc] initWithPoint1:pA1 andPoint2:pA2];
    CGVector pARange = CGVectorMultiplyByScalar(CGVectorBetweenPoints(pAStart.position, pAEndTemp1.position),0.8);
    CGPoint pAEndPoint = CGPointFromPointByAddingVector(pAStart.position, pARange);
    DHPoint* pAEnd = [[DHPoint alloc] initWithPositionX:pAEndPoint.x andY:pAEndPoint.y];
    
    DHLineSegment* pALine = [[DHLineSegment alloc] initWithStart:pAStart andEnd:pAEnd];
    DHPointOnLine* pA = [[DHPointOnLine alloc] init];
    pA.tValue = 0.2;
    pA.line = pALine;
    
    DHPoint* pB1 = [[DHPoint alloc] initWithPositionX:250 andY:400];
    DHPoint* pB2 = [[DHPoint alloc] initWithPositionX:250 andY:300];
    DHCircle* cB = [[DHCircle alloc] initWithCenter:pB1 andPointOnRadius:pB2];
    DHPointOnCircle* pB = [[DHPointOnCircle alloc] init];
    pB.circle = cB;
    pB.angle = (2*0.65)*M_PI;
    
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
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:_rayA2.start andPointOnRadius:_rayA2.end];
    DHIntersectionPointLineCircle* ip1 = [[DHIntersectionPointLineCircle alloc] init];
    ip1.c = c1;
    ip1.l = _rayA1;
    
    DHTranslatedPoint* tp1 = [[DHTranslatedPoint alloc] init];
    tp1.startOfTranslation = _pointB;
    tp1.translationStart = _rayA1.start;
    tp1.translationEnd = _rayA2.end;

    DHCircle* c2 = [[DHCircle alloc] initWithCenter:_pointB andPointOnRadius:tp1];

    DHIntersectionPointLineCircle* ip2 = [[DHIntersectionPointLineCircle alloc] init];
    ip2.c = c2;
    ip2.l = _rayB;
    
    DHTranslatedPoint* tp2 = [[DHTranslatedPoint alloc] init];
    tp2.startOfTranslation = ip2;
    tp2.translationStart = _rayA2.end;
    tp2.translationEnd = ip1;

    DHCircle* c3 = [[DHCircle alloc] initWithCenter:ip2 andPointOnRadius:tp2];
    
    DHIntersectionPointCircleCircle* ip3 = [[DHIntersectionPointCircleCircle alloc] init];
    ip3.c1 = c2;
    ip3.c2 = c3;
    ip3.onPositiveY = YES;
    
    DHLineSegment* r = [[DHLineSegment alloc] initWithStart:_pointB andEnd:ip3];
    
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
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _rayA1.start.position = pointA;
    _rayA1.end.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    BOOL pointAtTargetAngleOK = NO;
    CGFloat targetAngle = AngleBetweenLineObjects(_rayA1, _rayA2);

    DHLineObject* lTemp = [[DHLine alloc] init];
    lTemp.start = _pointB;
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class]  isSubclassOfClass:[DHLineObject class]]) {
            DHLineObject* l = object;
            if (!PointOnLine(_pointB, l)) continue;
            CGFloat angleToBLine = AngleBetweenLineObjects(l, _rayB);
            if (EqualScalarValues(angleToBLine, targetAngle)) {
                self.progress = 100;
                return YES;
            }
        }
        if ([[object class]  isSubclassOfClass:[DHPoint class]] && [object class] != [DHPoint class]) {
            DHPoint* point = object;
            lTemp.end = point;
            CGFloat angleToBLine = AngleBetweenLineObjects(lTemp, _rayB);
            if (EqualScalarValues(angleToBLine, targetAngle)) {
                pointAtTargetAngleOK = YES;
            }
        }
    }
    
    self.progress = pointAtTargetAngleOK/2.0*100;
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    
    for (id object in objects){
        if ([[object class]  isSubclassOfClass:[DHLineObject class]]) {
            DHLineObject* l = object;
            if (! PointOnLine(_pointB,l)) continue;
            if (EqualScalarValues(GetAngle(_rayA1, _rayA2), GetAngle(_rayB,l))) return MidPointFromLine(l);
        }
        
        if ([[object class]  isSubclassOfClass:[DHPoint class]] && [object class] != [DHPoint class]) {
            DHPoint* point = object;
            DHLineSegment* segment = [[DHLineSegment alloc]initWithStart:_pointB andEnd:point];
            if (EqualScalarValues(GetAngle(_rayA1, _rayA2), GetAngle(_rayB,segment))) return point.position;
        }
        
    }
    return CGPointMake(NAN, NAN);
}


@end
