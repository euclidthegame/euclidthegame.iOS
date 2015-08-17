//
//  DHLevelThreeCircles.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-09.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelThreeCircles.h"

#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@interface DHLevelThreeCircles () {
    DHLineSegment* _lAB;
    DHCircle* _circle1;
}

@end

@implementation DHLevelThreeCircles

- (NSString*)levelDescription
{
    return (@"Construct two circles of radius AB, mutually tangent and to the given circle");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct two new circles of radius AB where each pair of the three circles is tangent. "
            @"One of the two circles must also touch point B.");
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
    return 5;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:300 andY:350];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:400 andY:350];
    
    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:pA andEnd:pB];
    DHCircle* c1 = [[DHCircle alloc] init];
    c1.center = pA;
    c1.pointOnRadius = pB;
    
    [geometricObjects addObject:lAB];
    [geometricObjects addObject:c1];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    
    _lAB = lAB;
    _circle1 = c1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHTranslatedPoint* pc2 = [[DHTranslatedPoint alloc] init];
    pc2.startOfTranslation = _lAB.end;
    pc2.translationStart = _lAB.start;
    pc2.translationEnd = _lAB.end;
    
    DHCircle* c2 = [[DHCircle alloc] initWithCenter:pc2 andPointOnRadius:_lAB.end];
    [objects insertObject:c2 atIndex:0];
    
    DHTrianglePoint* pt = [[DHTrianglePoint alloc] initWithPoint1:_lAB.start andPoint2:pc2];
    DHLineSegment* l = [[DHLineSegment alloc] initWithStart:_lAB.start andEnd:pt];
    DHIntersectionPointLineCircle* ip = [[DHIntersectionPointLineCircle alloc] init];
    ip.c = _circle1;
    ip.l = l;
    
    
    DHCircle* c3 = [[DHCircle alloc] initWithCenter:pt andPointOnRadius:ip];
    [objects insertObject:c3 atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _lAB.start.position;
    CGPoint pointB = _lAB.end.position;
    
    _lAB.start.position = CGPointMake(pointA.x - 10, pointA.y - 10);
    _lAB.end.position = CGPointMake(pointB.x + 10, pointB.y + 10);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _lAB.start.position = pointA;
    _lAB.end.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    DHTranslatedPoint* pc2 = [[DHTranslatedPoint alloc] init];
    pc2.startOfTranslation = _lAB.end;
    pc2.translationStart = _lAB.start;
    pc2.translationEnd = _lAB.end;
    DHCircle* c2 = [[DHCircle alloc] initWithCenter:pc2 andPointOnRadius:_lAB.end];
    DHTrianglePoint* pt = [[DHTrianglePoint alloc] initWithPoint1:_lAB.start andPoint2:pc2];
    DHTrianglePoint* pt2 = [[DHTrianglePoint alloc] initWithPoint1:pc2 andPoint2:_lAB.start];

    DHLineSegment* l = [[DHLineSegment alloc] initWithStart:_lAB.start andEnd:pt];
    DHLineSegment* l2 = [[DHLineSegment alloc] initWithStart:_lAB.start andEnd:pt2];
    DHIntersectionPointLineCircle* ip = [[DHIntersectionPointLineCircle alloc]
                                         initWithLine:l andCircle:_circle1 andPreferEnd:NO];
    DHIntersectionPointLineCircle* ip2 = [[DHIntersectionPointLineCircle alloc]
                                         initWithLine:l2 andCircle:_circle1 andPreferEnd:NO];
    DHCircle* c3 = [[DHCircle alloc] initWithCenter:pt andPointOnRadius:ip];
    DHCircle* c3_2 = [[DHCircle alloc] initWithCenter:pt2 andPointOnRadius:ip2];
    
    BOOL secondCircleOK = NO;
    BOOL thirdCircleOK = NO;
    bool pointOnThirdCircleOK = NO;
    BOOL secondCircleCenterOK = NO;
    BOOL thirdCircleCenterOK = NO;
    
    for (id object in geometricObjects) {
        if (EqualPoints(object, pc2)) secondCircleCenterOK = YES;
        if (EqualCircles(object, c2)) secondCircleOK = YES;
        if (EqualPoints(object, pt) || EqualPoints(object, pt2)) thirdCircleCenterOK = YES;
        if (PointOnCircle(object, c3) || PointOnCircle(object, c3_2)) pointOnThirdCircleOK = YES;
        if (EqualCircles(object, c3) || EqualCircles(object, c3_2)) thirdCircleOK = YES;
    }
    
    if (secondCircleOK && thirdCircleOK) {
        self.progress = 100;
        return YES;
    }
    
    self.progress = (secondCircleCenterOK + secondCircleOK*4 +
                     thirdCircleCenterOK + pointOnThirdCircleOK + thirdCircleOK*3)/10.0*100;
    
    return NO;
}
-(CGPoint)testObjectsForProgressHints:(NSArray *)objects {
    
    DHTranslatedPoint* pc2 = [[DHTranslatedPoint alloc] init];
    pc2.startOfTranslation = _lAB.end;
    pc2.translationStart = _lAB.start;
    pc2.translationEnd = _lAB.end;
    
    DHCircle* c2 = [[DHCircle alloc] initWithCenter:pc2 andPointOnRadius:_lAB.end];
    
    DHTrianglePoint* pt = [[DHTrianglePoint alloc] initWithPoint1:_lAB.start andPoint2:pc2];
    
    DHTrianglePoint* pt2 = [[DHTrianglePoint alloc] initWithPoint1:pc2 andPoint2:_lAB.start];
    DHLineSegment* l = [[DHLineSegment alloc] initWithStart:_lAB.start andEnd:pt];
    DHIntersectionPointLineCircle* ip = [[DHIntersectionPointLineCircle alloc] init];
    ip.c = _circle1;
    ip.l = l;
    
    
    DHCircle* c3 = [[DHCircle alloc] initWithCenter:pt andPointOnRadius:ip];
    
    for (id object in objects) {
        if (EqualPoints(object, pc2)) return pc2.position;
        if (EqualPoints(object, pt)) return pt.position;
        if (EqualPoints(object, pt2)) return pt2.position;
        if (PointOnCircle(object, c2)) return Position(object);
        if (PointOnCircle(object, c3)) return Position(object);
        if (EqualCircles(object, c2)) return c2.center.position;
        if (EqualCircles(object, c3)) return c3.center.position;
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
    
    DHGeometryView* hintView = [[DHGeometryView alloc] initWithFrame:geometryView.frame];
    hintView.backgroundColor = [UIColor whiteColor];
    hintView.layer.opacity = 0;
    hintView.hideBottomBorder = YES;
    [geometryView addSubview:hintView];
    [self fadeInViews:@[hintView] withDuration:1.0];
    
    [self afterDelay:1.0 :^{
        if (!self.showingHint) return;
        hintView.frame = geometryView.frame;
        
        CGFloat centerX = [geometryView.geoViewTransform viewToGeo:geometryView.center].x;
        DHPoint* p1 = [[DHPoint alloc] initWithPositionX:centerX-100 andY:200];
        DHPoint* p2 = [[DHPoint alloc] initWithPositionX:centerX andY:200];
        DHPoint* p3 = [[DHPoint alloc] initWithPositionX:centerX+100 andY:200];
        DHPoint* p4 = [[DHPoint alloc] initWithPositionX:centerX andY:400];
        DHCircle* c1 = [[DHCircle alloc] initWithCenter:p1 andPointOnRadius:p2];
        DHCircle* c2 = [[DHCircle alloc] initWithCenter:p3 andPointOnRadius:p2];
        DHLineSegment* radius1 = [[DHLineSegment alloc] initWithStart:p1 andEnd:p2];
        DHLineSegment* radius2 = [[DHLineSegment alloc] initWithStart:p3 andEnd:p2];
        DHLineSegment* tangent = [[DHLineSegment alloc] initWithStart:p2 andEnd:p4];
        p2.temporary = c2.temporary = radius1.temporary = radius2.temporary = tangent.temporary = YES;

        DHAngleIndicator* angle = [[DHAngleIndicator alloc] initWithLine1:radius1 line2:radius2 andRadius:20];
        angle.label = @"?";
        angle.anglePosition = 1;
        
        DHGeometryView* circleView = [[DHGeometryView alloc] initWithObjects:@[c1, c2]
                                                                   supView:geometryView addTo:hintView];
        DHGeometryView* p2View = [[DHGeometryView alloc] initWithObjects:@[p2]
                                                                      supView:geometryView addTo:hintView];
        DHGeometryView* tangentView = [[DHGeometryView alloc] initWithObjects:@[tangent, p2]
                                                                   supView:geometryView addTo:hintView];
        DHGeometryView* radiusView = [[DHGeometryView alloc] initWithObjects:@[radius1, radius2, p1, p3, p2]
                                                                      supView:geometryView addTo:hintView];
        DHGeometryView* angleView = [[DHGeometryView alloc] initWithObjects:@[angle]
                                                                     supView:geometryView addTo:hintView];
        
        Message* message1 = [[Message alloc] initAtPoint:CGPointMake(80,460) addTo:hintView];
        
        [self afterDelay:0.0:^{
            [message1 text:@"If two circles are tangent they only touch on exactly one point."];
            [self fadeInViews:@[message1, circleView, p2View] withDuration:2.5];
        }];
        
        [self afterDelay:4.0 :^{
            [message1 appendLine:@"From this point a tangent line will also be tangent to both circles."
                    withDuration:2.0];
            [self fadeInViews:@[tangentView] withDuration:2.5];
        }];
        
        [self afterDelay:8.0 :^{
            [message1 appendLine:@"We already know the angle between the tangent line and a radial line."
                    withDuration:2.0];
            [self fadeInViews:@[radiusView] withDuration:2.5];
        }];

        [self afterDelay:12.0 :^{
            [message1 appendLine:@"What must the angle between the two radial lines then be?"
                    withDuration:2.0];
            [self fadeInViews:@[angleView] withDuration:2.5];
        }];
        
        [self afterDelay:2.0 :^{
            [self showEndHintMessageInView:hintView];
        }];
        
    }];
}

@end

