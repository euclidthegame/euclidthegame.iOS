//
//  DHLevelTwoCirclesOuterTangent.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-11.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelTwoCirclesOuterTangent.h"

#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@interface DHLevelTwoCirclesOuterTangent () {
    DHPointOnLine* _pA;
    DHPointOnLine* _pB;
    DHCircle* _circleA;
    DHCircle* _circleB;
    DHPoint* _pRadiusA;
    DHPoint* _pRadiusB;
}

@end

@implementation DHLevelTwoCirclesOuterTangent

- (NSString*)levelDescription
{
    return (@"Construct an outer tangent of both circles.");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct an outer tangent of both circles. \n\n"
            @"An outer tangent is a line or line segment that is tangent to both circles, "
            @"but that doesn't intersect the segment joining the two circles' centers.");
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
    return 6;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 8;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    // Hidden objects used to restricted allowed movement of initial objects to avoid overlapping configuration
    DHPoint* pAStart = [[DHPoint alloc] initWithPositionX:170 andY:400];
    DHPoint* pAEnd = [[DHPoint alloc] initWithPositionX:230 andY:400];
    DHLineSegment* lA = [[DHLineSegment alloc] initWithStart:pAStart andEnd:pAEnd];

    DHPoint* pBStart = [[DHPoint alloc] initWithPositionX:380 andY:350];
    DHPoint* pBEnd = [[DHPoint alloc] initWithPositionX:450 andY:300];
    DHLineSegment* lB = [[DHLineSegment alloc] initWithStart:pBStart andEnd:pBEnd];
    

    DHPointOnLine* pA = [[DHPointOnLine alloc] initWithLine:lA andTValue:0.5];
    DHPointOnLine* pB = [[DHPointOnLine alloc] initWithLine:lB andTValue:0];
    pA.hideBorder = YES;
    pB.hideBorder = YES;
    
    DHPoint* pRadiusA = [[DHPoint alloc] initWithPositionX:pA.position.x+40 andY:pA.position.y];
    DHPoint* pRadiusB = [[DHPoint alloc] initWithPositionX:pB.position.x-80 andY:pB.position.y];
    
    DHCircle* cA = [[DHCircle alloc] initWithCenter:pA andPointOnRadius:pRadiusA];
    DHCircle* cB = [[DHCircle alloc] initWithCenter:pB andPointOnRadius:pRadiusB];
    
    [geometricObjects addObject:cA];
    [geometricObjects addObject:cB];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    
    _pA = pA;
    _pB = pB;
    _circleA = cA;
    _circleB = cB;
    _pRadiusA = pRadiusA;
    _pRadiusB = pRadiusB;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHRay* r1 = [[DHRay alloc] initWithStart:_circleB.center andEnd:_circleA.center];
    DHPerpendicularLine* lpA = [[DHPerpendicularLine alloc] init];
    lpA.line = r1;
    lpA.point = _circleA.center;
    DHPerpendicularLine* lpB = [[DHPerpendicularLine alloc] init];
    lpB.line = r1;
    lpB.point = _circleB.center;

    DHIntersectionPointLineCircle* pOnA = [[DHIntersectionPointLineCircle alloc] init];
    pOnA.c = _circleA;
    pOnA.l = lpA;
    DHIntersectionPointLineCircle* pOnB = [[DHIntersectionPointLineCircle alloc] init];
    pOnB.c = _circleB;
    pOnB.l = lpB;
    
    DHRay* r2 = [[DHRay alloc] initWithStart:pOnB andEnd:pOnA];

    DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] initWithLine:r1 andLine:r2];
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = ip1;
    mp.end = _circleA.center;
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_circleA.center];
    DHIntersectionPointCircleCircle* ip2 = [[DHIntersectionPointCircleCircle alloc] init];
    ip2.c1 = c;
    ip2.c2 = _circleA;
    

    
    DHRay* tangent = [[DHRay alloc] initWithStart:ip1 andEnd:ip2];
    [objects insertObject:tangent atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGFloat tValueA = _pA.tValue;
    CGFloat tValueB = _pB.tValue;
    
    _pA.tValue = tValueA + 0.1;
    _pB.tValue = tValueB + 0.1;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _pA.tValue = tValueA;
    _pB.tValue = tValueB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    DHPoint* pOnA = [[DHPoint alloc] initWithPositionX:_circleA.center.position.x
                                                  andY:(_circleA.center.position.y + _circleA.radius)];
    DHPoint* pOnB = [[DHPoint alloc] initWithPositionX:_circleB.center.position.x
                                                  andY:(_circleB.center.position.y + _circleB.radius)];
    DHRay* r1 = [[DHRay alloc] initWithStart:_circleB.center andEnd:_circleA.center];
    DHRay* r2 = [[DHRay alloc] initWithStart:pOnB andEnd:pOnA];
    
    DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] initWithLine:r1 andLine:r2];
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:ip1 andPoint2:_circleA.center];
    DHCircle* c = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_circleA.center];
    DHIntersectionPointCircleCircle* ip2 = [[DHIntersectionPointCircleCircle alloc]
                                            initWithCircle1:c andCircle2:_circleA onPositiveY:NO];
    DHIntersectionPointCircleCircle* ip3 = [[DHIntersectionPointCircleCircle alloc]
                                            initWithCircle1:c andCircle2:_circleA onPositiveY:YES];
    
    DHLineSegment* tangent1 = [[DHLineSegment alloc] initWithStart:ip1 andEnd:ip2];
    DHLine* tangent1Line = [[DHLine alloc] initWithStart:ip1 andEnd:ip2];
    DHLineSegment* tangent2 = [[DHLineSegment alloc] initWithStart:ip1 andEnd:ip3];
    DHLine* tangent2Line = [[DHLine alloc] initWithStart:ip1 andEnd:ip3];
    
    BOOL ip1OK = NO, pointOnTangentOK = NO, tangentOK = NO;
    
    for (id object in geometricObjects) {
        if (EqualPoints(object, ip1)) {
            ip1OK = YES;
        } else {
            if (PointOnLine(object, tangent1Line)) pointOnTangentOK = YES;
            if (PointOnLine(object, tangent2Line)) pointOnTangentOK = YES;
        }
        if (LineObjectCoversSegment(object, tangent1)) tangentOK = YES;
        if (LineObjectCoversSegment(object, tangent2)) tangentOK = YES;
    }
    
    if (tangentOK) {
        self.progress = 100;
        return YES;
    }
    
    self.progress = (ip1OK + pointOnTangentOK)/4.0 * 100;
    
    return NO;
}

-(CGPoint) testObjectsForProgressHints:(NSArray *)objects{
    
    DHPoint* pOnA = [[DHPoint alloc] initWithPositionX:_circleA.center.position.x
                                                  andY:(_circleA.center.position.y + _circleA.radius)];
    DHPoint* pOnB = [[DHPoint alloc] initWithPositionX:_circleB.center.position.x
                                                  andY:(_circleB.center.position.y + _circleB.radius)];
    DHRay* r1 = [[DHRay alloc] initWithStart:_circleB.center andEnd:_circleA.center];
    DHRay* r2 = [[DHRay alloc] initWithStart:pOnB andEnd:pOnA];
    
    DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] initWithLine:r1 andLine:r2];
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = ip1;
    mp.end = _circleA.center;
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_circleA.center];
    DHIntersectionPointCircleCircle* ip2 = [[DHIntersectionPointCircleCircle alloc] init];
    ip2.c1 = c;
    ip2.c2 = _circleA;
    ip2.onPositiveY = NO;
    
    DHIntersectionPointCircleCircle* ip3 = [[DHIntersectionPointCircleCircle alloc] init];
    ip3.c1 = c;
    ip3.c2 = _circleA;
    ip3.onPositiveY = YES;
    
    DHRay* tangent1 = [[DHRay alloc] initWithStart:ip1 andEnd:ip2];
    DHRay* tangent2 = [[DHRay alloc] initWithStart:ip1 andEnd:ip3];
    
    for (id object in objects){
        if (PointOnLine(object, tangent1)) return Position(object);
        if (PointOnLine(object, tangent2)) return Position(object);
        if (EqualDirection(object, tangent1)) return Position(tangent1);
        if (EqualDirection(object, tangent2)) return Position(tangent2);
        if (EqualCircles(object, c)) return Position(c);
    }
    
    
    return CGPointMake(NAN, NAN);
}

- (void)showHint
{
    DHGeometryView* geometryView = self.levelViewController.geometryView;
    
    if (self.showingHint) {
        [self hideHint];
        return;
    }
    
    self.showingHint = YES;
    
    [self slideOutToolbar];
    
    [self afterDelay:1.0 :^{
        if (!self.showingHint) return;
        
        DHRay* r1 = [[DHRay alloc] initWithStart:_circleB.center andEnd:_circleA.center];
        DHPerpendicularLine* lpA = [[DHPerpendicularLine alloc] init];
        lpA.line = r1;
        lpA.point = _circleA.center;
        DHPerpendicularLine* lpB = [[DHPerpendicularLine alloc] init];
        lpB.line = r1;
        lpB.point = _circleB.center;
        
        DHIntersectionPointLineCircle* pOnA = [[DHIntersectionPointLineCircle alloc] init];
        pOnA.c = _circleA;
        pOnA.l = lpA;
        DHIntersectionPointLineCircle* pOnB = [[DHIntersectionPointLineCircle alloc] init];
        pOnB.c = _circleB;
        pOnB.l = lpB;
        
        DHRay* r2 = [[DHRay alloc] initWithStart:pOnB andEnd:pOnA];
        
        DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] initWithLine:r1 andLine:r2];
        DHMidPoint* mp = [[DHMidPoint alloc] init];
        mp.start = ip1;
        mp.end = _circleA.center;
        
        DHCircle* c = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_circleA.center];
        DHIntersectionPointCircleCircle* ip2 = [[DHIntersectionPointCircleCircle alloc] init];
        ip2.c1 = c;
        ip2.c2 = _circleA;
        
        DHRay* tangent = [[DHRay alloc] initWithStart:ip1 andEnd:ip2];
        DHIntersectionPointLineCircle* pointC = [[DHIntersectionPointLineCircle alloc]initWithLine:tangent andCircle:_circleA andPreferEnd:YES];
        DHIntersectionPointLineCircle* pointD = [[DHIntersectionPointLineCircle alloc]initWithLine:tangent andCircle:_circleB andPreferEnd:YES];
        DHLineSegment* AC = [[DHLineSegment alloc] initWithStart:pointC andEnd:_circleA.center];
        DHLineSegment* BD = [[DHLineSegment alloc] initWithStart:pointD andEnd:_circleB.center];
        DHLineSegment* AB = [[DHLineSegment alloc] initWithStart:_pA andEnd:_pB];
        
        
        
        DHLineSegment* tangentSegment = [[DHLineSegment alloc]initWithStart:pointC andEnd:pointD];
        DHTranslatedPoint* tP = [[DHTranslatedPoint alloc] initStart:pointC end:pointD newStart:_circleA.center];
        tP.label = @"C";
        
        DHCircle* circle = [[DHCircle alloc]initWithCenter:_pB andPointOnRadius:tP];
        
        
        DHLineSegment* tSegment = [[DHLineSegment alloc]initWithStart:_circleA.center andEnd:tP];
        
        circle.highlighted = YES;
        
        DHGeometryView* tangentView = [[DHGeometryView alloc]initWithObjects:@[tangentSegment,pointC,pointD] andSuperView:geometryView];
        
        
        DHGeometryView* perpView = [[DHGeometryView alloc]initWithObjects:@[AC,BD] andSuperView:geometryView];
        DHGeometryView* translatedView = [[DHGeometryView alloc]initWithObjects:@[tSegment,tP] andSuperView:geometryView];
        DHGeometryView* triangleView = [[DHGeometryView alloc]initWithObjects:@[AB] andSuperView:geometryView];
        DHGeometryView* circleView = [[DHGeometryView alloc]initWithObjects:@[circle] andSuperView:geometryView];
        
        UIView* hintView = [[UIView alloc]initWithFrame:geometryView.frame];
        hintView.backgroundColor = [UIColor whiteColor];

        [self afterDelay:2.0 :^{
            [self showEndHintMessageInView:hintView];
        }];
        
        DHGeometryView* oldObjects = [[DHGeometryView alloc] initWithObjects:geometryView.geometricObjects supView:geometryView addTo:hintView];
        oldObjects.hideBorder = NO;
        [oldObjects.layer setValue:[NSNumber numberWithFloat:1.0] forKeyPath:@"opacity"];
        
        [geometryView addSubview:hintView];
        [hintView addSubview:perpView];
        [hintView addSubview:circleView];
        
        [hintView addSubview:translatedView];
        
        [hintView addSubview:triangleView];
        [hintView addSubview:oldObjects];
        [hintView addSubview:tangentView];
        
        Message* message1 = [[Message alloc] initAtPoint:CGPointMake(50,500) addTo:hintView];
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            [message1 position: CGPointMake(150,500)];
        }
        
        [self afterDelay:0.0 performBlock:^{
            [message1 text:@"The line we are looking for must be tangent to both circles."];
            [self fadeIn:message1 withDuration:1.0];
            [self fadeIn:tangentView withDuration:2.0];
        }];
        [self afterDelay:5.0 performBlock:^{
            [message1 appendLine:@"We know that the tangent is perpendicular to radial lines from the tangent points."
                    withDuration:1.0];
            [self fadeIn:perpView withDuration:2.0];
        }];
        [self afterDelay:10.0 performBlock:^{
            [message1 appendLine:@"What if we translate the tangent to point A?"
                    withDuration:1.0];
            [self fadeIn:translatedView withDuration:2.0];
        }];
        [self afterDelay:15.0 performBlock:^{
            [message1 appendLine:@"We then get a right trangle ABC."
                    withDuration:1.0];
            [self fadeIn:triangleView withDuration:2.0];
            
        }];
        [self afterDelay:20.0 performBlock:^{
            [message1 appendLine:@"Which means that the translated line segment is tangent to the following circle."
                    withDuration:1.0];
            [self fadeIn:circleView withDuration:2.0];
        }];
        [self afterDelay:25.0 performBlock:^{
            [message1 appendLine:@"Can you construct that circle and reverse the process?"
                    withDuration:1.0];
        }];
    }];

}

@end


