//
//  DHLevelTriIncircle.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-08.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelTriIncircle.h"

#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@interface DHLevelTriIncircle () {
    DHLineSegment* _lAB;
    DHLineSegment* _lAC;
    DHLineSegment* _lBC;
    BOOL hint1_OK;
    BOOL hint2_OK;
}

@end

@implementation DHLevelTriIncircle

- (NSString*)levelDescription
{
    return (@"Construct the incircle of a triangle.");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct the incircle of a triangle. \n\nAn incircle is a circle fully contained in a triangle "
            @"that is tangent to all three sides.");
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
    return 8;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    hint1_OK = NO;
    hint2_OK = NO;
    
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:200 andY:500];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:400 andY:480];
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:385 andY:330];
    
    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:pA andEnd:pB];
    DHLineSegment* lAC = [[DHLineSegment alloc] initWithStart:pA andEnd:pC];
    DHLineSegment* lBC = [[DHLineSegment alloc] initWithStart:pB andEnd:pC];
    
    [geometricObjects addObject:lAB];
    [geometricObjects addObject:lAC];
    [geometricObjects addObject:lBC];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    [geometricObjects addObject:pC];
    
    _lAB = lAB;
    _lAC = lAC;
    _lBC = lBC;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHBisectLine* bl1 = [[DHBisectLine alloc] initWithLine:_lAB andLine:_lAC];
    DHBisectLine* bl2 = [[DHBisectLine alloc] initWithLine:_lAC andLine:_lBC];
    DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] initWithLine:bl1 andLine:bl2];
    DHPerpendicularLine* lp = [[DHPerpendicularLine alloc] initWithLine:_lBC andPoint:ip1];
    DHIntersectionPointLineLine* ip2 = [[DHIntersectionPointLineLine alloc] initWithLine:_lBC andLine:lp];
    DHCircle* c = [[DHCircle alloc] initWithCenter:ip1 andPointOnRadius:ip2];
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
    DHBisectLine* bl1 = [[DHBisectLine alloc] initWithLine:_lAB andLine:_lAC];
    DHBisectLine* bl2 = [[DHBisectLine alloc] initWithLine:_lAC andLine:_lBC];
    DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] initWithLine:bl1 andLine:bl2];
    DHPerpendicularLine* lp = [[DHPerpendicularLine alloc] initWithLine:_lBC andPoint:ip1];
    DHIntersectionPointLineLine* ip2 = [[DHIntersectionPointLineLine alloc] initWithLine:_lBC andLine:lp];
    DHCircle* c = [[DHCircle alloc] initWithCenter:ip1 andPointOnRadius:ip2];
    
    BOOL centerPointOK = NO;
    BOOL pointOnRadiusOK = NO;
    
    for (id object in geometricObjects) {
        if (EqualPoints(object, ip1)) centerPointOK = YES;
        if (PointOnCircle(object, c)) pointOnRadiusOK = YES;
        
        if (EqualCircles(object,c)) {
            self.progress = 100;
            return YES;
        }
    }

    self.progress = (centerPointOK + pointOnRadiusOK)/3.0*100;
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects{
    
    
    
    DHBisectLine* bl1 = [[DHBisectLine alloc] init];
    bl1.line1 = _lAB;
    bl1.line2 = _lAC;
    DHBisectLine* bl2 = [[DHBisectLine alloc] init];
    bl2.line1 = _lAC;
    bl2.line2 = _lBC;
    
    DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] init];
    ip1.l1 = bl1;
    ip1.l2 = bl2;
    
    DHPerpendicularLine* lp = [[DHPerpendicularLine alloc] init];
    lp.line = _lBC;
    lp.point = ip1;
    
    DHIntersectionPointLineLine* ip2 = [[DHIntersectionPointLineLine alloc] init];
    ip2.l1 = _lBC;
    ip2.l2 = lp;
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:ip1 andPointOnRadius:ip2];
    for (id object in objects){
        
        if (EqualPoints(object, ip1)) return ip1.position;
        if (PointOnCircle(object, c)) return Position(object);
        if (EqualCircles(object,c)) return c.center.position;
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
    
    if (hint2_OK) {
        hint1_OK = NO;
        hint2_OK = NO;
    }
    
    DHBisectLine* bl1 = [[DHBisectLine alloc] initWithLine:_lAB andLine:_lAC];
    DHBisectLine* bl2 = [[DHBisectLine alloc] initWithLine:_lAC andLine:_lBC];
    bl1.temporary = YES;
    bl2.temporary = YES;
    
    DHIntersectionPointLineLine* ip1 = [[DHIntersectionPointLineLine alloc] initWithLine:bl1 andLine:bl2];
    DHPerpendicularLine* lp = [[DHPerpendicularLine alloc] initWithLine:_lBC andPoint:ip1];
    DHPerpendicularLine* lp2 = [[DHPerpendicularLine alloc] initWithLine:_lAC andPoint:ip1];
    DHPerpendicularLine* lp3 = [[DHPerpendicularLine alloc] initWithLine:_lAB andPoint:ip1];
    DHIntersectionPointLineLine* ip2 = [[DHIntersectionPointLineLine alloc] initWithLine:_lAC andLine:lp2];
    DHIntersectionPointLineLine* ip3 = [[DHIntersectionPointLineLine alloc] initWithLine:_lAB andLine:lp3];
    DHIntersectionPointLineLine* ip4 = [[DHIntersectionPointLineLine alloc] initWithLine:_lBC andLine:lp];
    
    DHLineSegment* perp1 = [[DHLineSegment alloc]initWithStart:ip1 andEnd:ip2];
    DHLineSegment* perp2 = [[DHLineSegment alloc]initWithStart:ip1 andEnd:ip3];
    DHLineSegment* perp3 = [[DHLineSegment alloc]initWithStart:ip1 andEnd:ip4];

    DHLineSegment* b1 = [[DHLineSegment alloc]initWithStart:_lAB.start andEnd:ip1];
    DHLineSegment* b2 = [[DHLineSegment alloc]initWithStart:_lAB.end andEnd:ip1];
    DHLineSegment* b3 = [[DHLineSegment alloc]initWithStart:_lAC.end andEnd:ip1];
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:ip1 andPointOnRadius:ip2];
    
    c.temporary = perp1.temporary = perp2.temporary = perp3.temporary = YES;
    b1.highlighted = b2.highlighted = b3.highlighted = YES;
    
    DHGeometryView* incircle = [[DHGeometryView alloc]initWithObjects:@[c,ip1] andSuperView:geometryView];
    DHGeometryView* perpView = [[DHGeometryView alloc]initWithObjects:@[perp1,perp2,perp3] andSuperView:geometryView];
    DHGeometryView* bView = [[DHGeometryView alloc]initWithObjects:@[b1,b2,b3, _lAB.start, _lAB.end, _lAC.end]
                                                      andSuperView:geometryView];
    DHGeometryView* bisectView = [[DHGeometryView alloc] initWithObjects:@[bl1] andSuperView:geometryView];
    
    [self afterDelay:1.0 :^{
        if (!self.showingHint) return;
        
        UIView* hintView = [[UIView alloc]initWithFrame:geometryView.frame];
        [geometryView addSubview:hintView];
        [hintView addSubview:bisectView];
        [hintView addSubview:bView];
        [hintView addSubview:perpView];
        [hintView addSubview:incircle];
        
        Message* message1 = [[Message alloc] initAtPoint:CGPointMake(100,200) addTo:hintView];
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            [message1 position: CGPointMake(150,500)];
        }
        if (self.iPhoneVersion) {
            [message1 position: CGPointMake(0,550)];
        }
        
        [self afterDelay:0.5 :^{
            [self showEndHintMessageInView:hintView];
        }];
    
        if (!hint1_OK) {
            [self afterDelay:0.0 performBlock:^{
                [message1 text:@"The incircle is tangent to all three sides."];
                [self fadeIn:message1 withDuration:1.0];
                [self fadeIn:incircle withDuration:2.0];
            }];
            [self afterDelay:4.0 performBlock:^{
                [message1 appendLine:@"Such a tangent is perpendicular to a line from the tangent point to the center."
                        withDuration:1.0];
                [self fadeIn:perpView withDuration:2.0];
            }];
            [self afterDelay:9.0 performBlock:^{
                [message1 appendLine:@"Those 3 line segments have length equal to the radius of the circle."
                        withDuration:1.0];
            }];
            [self afterDelay:14.0 performBlock:^{
                [message1 appendLine:@"Hence, the following lines are bisecting the angles of the triangle."
                        withDuration:1.0];
                [self fadeIn:bView withDuration:2.0];
                hint1_OK = YES;
            }];
        }
        else if (!hint2_OK){
            
            [self afterDelay:0.0 performBlock:^{
                [message1 text:@"Hence, if we draw a bisector of one the angles"];
                
                [self fadeIn:message1 withDuration:1.0];
                [self fadeIn:bisectView withDuration:2.0];
            }];
            [self afterDelay:4.0 performBlock:^{
                [message1 appendLine:@"We know that the line must pass through the center of the incircle."
                        withDuration:1.0];
                hint2_OK = YES;
            }];
        }
    }];

    
}
@end
