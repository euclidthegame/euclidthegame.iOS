//
//  DHLevelCircleSegmentCutoff.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-09.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelCircleSegmentCutoff.h"

#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@interface DHLevelCircleSegmentCutoff () {
    DHLineSegment* _lAB;
    DHLine* _givenLine;
    DHPoint* _pC;
}

@end

@implementation DHLevelCircleSegmentCutoff

- (NSString*)levelDescription
{
    return (@"Construct a circle at C, cutting off a segment of length AB on the given line");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Given a line, a line segment AB, and a point C. Construct a circle with center C such that the part of the given line inside the circle has the same length as segment AB.");
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
    return 7;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:100 andY:150];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:250 andY:100];
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:300 andY:400];

    DHPoint* pD = [[DHPoint alloc] initWithPositionX:300 andY:300];
    DHPoint* pE = [[DHPoint alloc] initWithPositionX:400 andY:300];

    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:pA andEnd:pB];
    DHLine* lDE = [[DHLine alloc] initWithStart:pD andEnd:pE];
    
    [geometricObjects addObject:lAB];
    [geometricObjects addObject:lDE];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    [geometricObjects addObject:pC];
    
    _lAB = lAB;
    _givenLine = lDE;
    _pC = pC;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:_lAB.start andPoint2:_lAB.end];
    DHPerpendicularLine* lp = [[DHPerpendicularLine alloc] init];
    lp.line = _givenLine;
    lp.point = _pC;
    DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] initWithLine:lp andLine:_givenLine];
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = ip1;
    tp.translationStart = mp;
    tp.translationEnd = _lAB.end;
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:ip1 andPointOnRadius:tp];
    DHIntersectionPointLineCircle* ip2 = [[DHIntersectionPointLineCircle alloc] init];
    ip2.c = c1;
    ip2.l = _givenLine;
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:_pC andPointOnRadius:ip2];
    [objects insertObject:c atIndex:0];
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
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class]  isSubclassOfClass:[DHCircle class]] == NO) continue;
        
        DHCircle* circle = object;
        if (circle.center != _pC) {
            continue;
        }
        
        DHIntersectionResult r1 = IntersectionTestLineCircle(_givenLine, circle, NO);
        DHIntersectionResult r2 = IntersectionTestLineCircle(_givenLine, circle, YES);
        
        if (r1.intersect && r2.intersect) {
            CGPoint ip1 = r1.intersectionPoint;
            CGPoint ip2 = r2.intersectionPoint;
            CGFloat dist = DistanceBetweenPoints(ip1, ip2);
            CGFloat distAB = _lAB.length;
            
            if (EqualScalarValues(dist, distAB)) {
                self.progress = 100;
                return YES;
            }
            
        }
    }
    
    return NO;
}
-(CGPoint)testObjectsForProgressHints:(NSArray *)objects {
    
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:_lAB.start andPoint2:_lAB.end];
    DHPerpendicularLine* lp = [[DHPerpendicularLine alloc] init];
    lp.line = _givenLine;
    lp.point = _pC;
    DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] initWithLine:lp andLine:_givenLine];
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = ip1;
    tp.translationStart = mp;
    tp.translationEnd = _lAB.end;
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:ip1 andPointOnRadius:tp];
    DHIntersectionPointLineCircle* ip2 = [[DHIntersectionPointLineCircle alloc] init];
    ip2.c = c1;
    ip2.l = _givenLine;

    DHCircle* c = [[DHCircle alloc] initWithCenter:_pC andPointOnRadius:ip2];
    
    for (id object in objects) {
        if (EqualPoints(object, ip1)) return ip1.position;
        if (PointOnCircle(object, c)) return Position(object);
        if (EqualCircles(object, c1)) return c1.center.position;
        if (EqualCircles(object, c)) return c.center.position;

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
    
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:_lAB.start andPoint2:_lAB.end];
    DHPerpendicularLine* lp = [[DHPerpendicularLine alloc] init];
    lp.line = _givenLine;
    lp.point = _pC;
    DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] initWithLine:lp andLine:_givenLine];
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = ip1;
    tp.translationStart = mp;
    tp.translationEnd = _lAB.end;

    DHCircle* c1 = [[DHCircle alloc] initWithCenter:ip1 andPointOnRadius:tp];
    DHIntersectionPointLineCircle* ip2 = [[DHIntersectionPointLineCircle alloc] init];
    ip2.c = c1;
    ip2.l = _givenLine;
    ip2.label = @"D";
    
    DHIntersectionPointLineCircle* ip3 = [[DHIntersectionPointLineCircle alloc] init];
    ip3.c = c1;
    ip3.l = _givenLine;
    ip3.label = @"E";
    ip3.preferEnd = YES;
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:_pC andPointOnRadius:ip2];
    
    DHPoint* p1 = [[DHPoint alloc]initWithPosition:_lAB.start.position];
    DHPoint* p2 = [[DHPoint alloc]initWithPosition:_lAB.end.position];
    DHLineSegment* lAB = [[DHLineSegment alloc]initWithStart:p1 andEnd:p2];
    
    DHGeometryView* circleView = [[DHGeometryView alloc]initWithObjects:@[c,ip3,ip2] andSuperView:geometryView];
    DHGeometryView* segmentView = [[DHGeometryView alloc]initWithObjects:@[lAB,p1,p2] andSuperView:geometryView];
    DHGeometryView* perpView = [[DHGeometryView alloc]initWithObjects:@[lp, _pC, ip1] andSuperView:geometryView];
    
    lAB.temporary = lp.temporary = c.temporary = YES;
    
    [self afterDelay:1.0 :^{
        if (!self.showingHint) return;
        
        UIView* hintView = [[UIView alloc]initWithFrame:geometryView.frame];
        [geometryView addSubview:hintView];
        [hintView addSubview:circleView];
        [hintView addSubview:segmentView];
        [hintView addSubview:perpView];
        
        Message* message1 = [[Message alloc] initAtPoint:CGPointMake(270,100) addTo:hintView];
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            [message1 position: CGPointMake(150,500)];
        }
        if (self.iPhoneVersion) {
            [message1 position: CGPointMake(5,550)];
        }
        
        [self afterDelay:0.5 :^{
            [self showEndHintMessageInView:hintView];
        }];
        
        [self afterDelay:0.0 performBlock:^{
            [message1 text:@"We are looking for a circle such that:"];
            [self fadeIn:message1 withDuration:1.0];
            [self fadeIn:circleView withDuration:2.0];
        }];
        [self afterDelay:3.0 performBlock:^{
            [message1 appendLine:@"  AB = DE" withDuration:1.0 forceNewLine:YES];
        }];
        [self afterDelay:4.0 performBlock:^{
            [self fadeIn:segmentView withDuration:0.0];
            [self movePointFrom:p1 to:ip2 withDuration:3.0 inView:segmentView];
            [self movePointFrom:p2 to:ip3 withDuration:3.0 inView:segmentView];
            
        }];
        [self afterDelay:8.0 performBlock:^{
            [message1 appendLine:@"Remember the interesting fact that we learned in Level 14."
                    withDuration:1.0 forceNewLine:YES];
        }];
        [self afterDelay:12.0 performBlock:^{
            [message1 appendLine:@"The perpendicular bisector of DE will pass through the center."
                    withDuration:1.0];
            [self fadeIn:perpView withDuration:2.0];
        }];
    }];
}
@end
