//
//  DHLevelPentagon.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-11.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelPentagon.h"

#import "DHGeometricObjects.h"

@interface DHLevelPentagon () {
    DHCircle* _circle;
}
@end

@implementation DHLevelPentagon

- (NSString*)levelDescription
{
    return (@"Construct a regular pentagon in the given circle with B as a vertex");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct a regular pentagon inscribed in the given circle with B as one of its vertices.");
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
    DHPoint* pA = _circle.center;
    DHPoint* pB = _circle.pointOnRadius;
    DHLine* lVert = [[DHLine alloc] initWithStart:pB andEnd:pA];
    DHPerpendicularLine* lHori = [[DHPerpendicularLine alloc] initWithLine:lVert andPoint:pA];
    DHIntersectionPointLineCircle* ip1 = [[DHIntersectionPointLineCircle alloc]
                                          initWithLine:lVert andCircle:_circle andPreferEnd:YES];
    DHIntersectionPointLineCircle* ip2 = [[DHIntersectionPointLineCircle alloc]
                                          initWithLine:lHori andCircle:_circle andPreferEnd:YES];
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:pA andPoint2:ip1];
    DHCircle* cMP = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:ip2];
    DHIntersectionPointLineCircle* ip3 = [[DHIntersectionPointLineCircle alloc]
                                          initWithLine:lVert andCircle:cMP andPreferEnd:YES];
    DHTranslatedPoint* pt = [[DHTranslatedPoint alloc] init];
    pt.startOfTranslation = ip3;
    pt.translationStart = pB;
    pt.translationEnd = pA;
    DHCircle* cIP3 = [[DHCircle alloc] initWithCenter:ip3 andPointOnRadius:pt];
    DHIntersectionPointCircleCircle* pD = [[DHIntersectionPointCircleCircle alloc]
                                           initWithCircle1:cIP3 andCircle2:_circle onPositiveY:YES];
    DHIntersectionPointCircleCircle* pE = [[DHIntersectionPointCircleCircle alloc]
                                           initWithCircle1:cIP3 andCircle2:_circle onPositiveY:NO];
    DHCircle* cD = [[DHCircle alloc] initWithCenter:pD andPointOnRadius:pE];
    DHCircle* cE = [[DHCircle alloc] initWithCenter:pE andPointOnRadius:pD];
    DHIntersectionPointCircleCircle* pC = [[DHIntersectionPointCircleCircle alloc]
                                           initWithCircle1:cD andCircle2:_circle onPositiveY:YES];
    DHIntersectionPointCircleCircle* pF = [[DHIntersectionPointCircleCircle alloc]
                                           initWithCircle1:_circle andCircle2:cE onPositiveY:YES];
    
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
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _circle.center.position = pointA;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
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
    
    BOOL bcOK = NO;
    BOOL cdOK = NO;
    BOOL deOK = NO;
    BOOL efOK = NO;
    BOOL fbOK = NO;
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        
        if ([[object class]  isSubclassOfClass:[DHLineObject class]]) {
            DHLineObject* l = object;
            if (l.start == center || l.end == center) continue;
            CGFloat distLB = DistanceFromPointToLine(pB, l);
            CGFloat distLC = DistanceFromPointToLine(pC, l);
            CGFloat distLD = DistanceFromPointToLine(pD, l);
            CGFloat distLE = DistanceFromPointToLine(pE, l);
            CGFloat distLF = DistanceFromPointToLine(pF, l);
            
            // Check if the line matches any of the needed points
            if (distLB < 0.01 && distLC < 0.01) bcOK = YES;
            if (distLC < 0.01 && distLD < 0.01) cdOK = YES;
            if (distLD < 0.01 && distLE < 0.01) deOK = YES;
            if (distLE < 0.01 && distLF < 0.01) efOK = YES;
            if (distLF < 0.01 && distLB< 0.01) fbOK = YES;
        }
    }
    
    self.progress = (bcOK + cdOK + deOK + efOK + fbOK)/5.0 * 100;
    if (bcOK && cdOK && deOK && efOK && fbOK) {
        self.progress = 100;
        return YES;
    }
    
    return NO;
}

-(CGPoint) testObjectsForProgressHints:(NSArray *)objects{
    
    DHPoint* pA = _circle.center;
    DHPoint* pB = _circle.pointOnRadius;
    DHLine* lVert = [[DHLine alloc] initWithStart:pB andEnd:pA];
    DHPerpendicularLine* lHori = [[DHPerpendicularLine alloc] initWithLine:lVert andPoint:pA];
    DHIntersectionPointLineCircle* ip1 = [[DHIntersectionPointLineCircle alloc]
                                          initWithLine:lVert andCircle:_circle andPreferEnd:YES];
    DHIntersectionPointLineCircle* ip2 = [[DHIntersectionPointLineCircle alloc]
                                          initWithLine:lHori andCircle:_circle andPreferEnd:YES];
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:pA andPoint2:ip1];
    DHCircle* cMP = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:ip2];
    DHIntersectionPointLineCircle* ip3 = [[DHIntersectionPointLineCircle alloc]
                                          initWithLine:lVert andCircle:cMP andPreferEnd:YES];
    DHTranslatedPoint* pt = [[DHTranslatedPoint alloc] init];
    pt.startOfTranslation = ip3;
    pt.translationStart = pB;
    pt.translationEnd = pA;
    DHCircle* cIP3 = [[DHCircle alloc] initWithCenter:ip3 andPointOnRadius:pt];
    DHIntersectionPointCircleCircle* pD = [[DHIntersectionPointCircleCircle alloc]
                                           initWithCircle1:cIP3 andCircle2:_circle onPositiveY:YES];
    DHIntersectionPointCircleCircle* pE = [[DHIntersectionPointCircleCircle alloc]
                                           initWithCircle1:cIP3 andCircle2:_circle onPositiveY:NO];
    DHCircle* cD = [[DHCircle alloc] initWithCenter:pD andPointOnRadius:pE];
    DHCircle* cE = [[DHCircle alloc] initWithCenter:pE andPointOnRadius:pD];
    DHIntersectionPointCircleCircle* pC = [[DHIntersectionPointCircleCircle alloc]
                                           initWithCircle1:cD andCircle2:_circle onPositiveY:YES];
    DHIntersectionPointCircleCircle* pF = [[DHIntersectionPointCircleCircle alloc]
                                           initWithCircle1:_circle andCircle2:cE onPositiveY:YES];
    
    DHLineSegment* lBC = [[DHLineSegment alloc] initWithStart:_circle.pointOnRadius andEnd:pC];
    DHLineSegment* lCD = [[DHLineSegment alloc] initWithStart:pC andEnd:pD];
    DHLineSegment* lDE = [[DHLineSegment alloc] initWithStart:pD andEnd:pE];
    DHLineSegment* lEF = [[DHLineSegment alloc] initWithStart:pE andEnd:pF];
    DHLineSegment* lFB = [[DHLineSegment alloc] initWithStart:pF andEnd:_circle.pointOnRadius];
    
    for (id object in objects){
        if (EqualPoints(object,pC)) return Position(object);
        if (EqualPoints(object,pD)) return Position(object);
        if (EqualPoints(object,pE)) return Position(object);
        if (EqualPoints(object,pF)) return Position(object);
        if (PointOnCircle(pC,object)) return Position(object);
        if (PointOnCircle(pD,object)) return Position(object);
        if (PointOnCircle(pE,object)) return Position(object);
        if (PointOnCircle(pF,object)) return Position(object);
        if (LineObjectCoversSegment(object, lBC)) return Position(object);
        if (LineObjectCoversSegment(object, lCD)) return Position(object);
        if (LineObjectCoversSegment(object, lDE)) return Position(object);
        if (LineObjectCoversSegment(object, lEF)) return Position(object);
        if (LineObjectCoversSegment(object, lFB)) return Position(object);
    }
    
    return CGPointMake(NAN, NAN);
}

@end


