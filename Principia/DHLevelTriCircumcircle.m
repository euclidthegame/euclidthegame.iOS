//
//  DHLevelTriCircumcircle.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-09.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelTriCircumcircle.h"

#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@interface DHLevelTriCircumcircle () {
    DHLineSegment* _lAB;
    DHLineSegment* _lAC;
    DHLineSegment* _lBC;
    BOOL hint1_OK;
    BOOL hint2_OK;
}

@end

@implementation DHLevelTriCircumcircle

- (NSString*)levelDescription
{
    return (@"Construct the circumcircle of a triangle.");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct the circumcircle of a triangle. \n\nA circumcircle is a circle that passes through all three "
            @"points of a triangle.");
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
    hint1_OK = NO;
    hint2_OK = NO;
    
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:168 andY:498];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:403 andY:480];
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:335 andY:330];
    
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
    DHPerpendicularLine* pl1 = [[DHPerpendicularLine alloc] initWithLine:_lAB andPoint:_lAB.start];
    DHPerpendicularLine* pl2 = [[DHPerpendicularLine alloc] initWithLine:_lBC andPoint:_lBC.end];
    DHIntersectionPointLineLine* ip = [[DHIntersectionPointLineLine alloc] initWithLine:pl1 andLine:pl2];
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:ip andPoint2:_lAB.end];
    DHCircle* c = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_lAB.start];
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
    DHPerpendicularLine* pl1 = [[DHPerpendicularLine alloc] initWithLine:_lAB andPoint:_lAB.start];
    DHPerpendicularLine* pl2 = [[DHPerpendicularLine alloc] initWithLine:_lBC andPoint:_lBC.end];
    DHIntersectionPointLineLine* ip = [[DHIntersectionPointLineLine alloc] initWithLine:pl1 andLine:pl2];
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:ip andPoint2:_lAB.end];
    DHCircle* c = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_lAB.start];

    BOOL centerPointOK = NO;
    
    for (id object in geometricObjects) {
        if (EqualPoints(object, mp)) centerPointOK = YES;
        if (EqualCircles(object,c)) {
            self.progress = 100;
            return YES;
        }
    }

    self.progress = (centerPointOK)/2.0*100;

    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects{
    DHPerpendicularLine* pl1 = [[DHPerpendicularLine alloc] init];
    pl1.line = _lAB;
    pl1.point = _lAB.start;
    DHPerpendicularLine* pl2 = [[DHPerpendicularLine alloc] init];
    pl2.line = _lBC;
    pl2.point = _lBC.end;
    
    DHIntersectionPointLineLine* ip = [[DHIntersectionPointLineLine alloc] init];
    ip.l1 = pl1;
    ip.l2 = pl2;
    
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = ip;
    mp.end = _lAB.end;
    
    DHCircle* c = [[DHCircle alloc] init];
    c.center = mp;
    c.pointOnRadius = _lAB.start;
    for (id object in objects){
        
        if (EqualPoints(object, mp)) return mp.position;
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
    
    DHMidPoint* midBC = [[DHMidPoint alloc] initWithPoint1:_lBC.start andPoint2:_lBC.end];
    DHGeometryView* midView = [[DHGeometryView alloc] initWithObjects:@[midBC] andSuperView:geometryView];
    
    DHPerpendicularLine* perpBC = [[DHPerpendicularLine alloc]initWithLine:_lBC andPoint:midBC];
    perpBC.temporary = YES;
    
    DHPointOnLine* point = [[DHPointOnLine alloc] initWithLine:perpBC andTValue:100];
    
    DHCircle* circle = [[DHCircle alloc] initWithCenter:point andPointOnRadius:_lBC.end];
    circle.temporary = YES;
    
    DHGeometryView* perpView = [[DHGeometryView alloc] initWithObjects:@[perpBC] andSuperView:geometryView];
    
    DHGeometryView* circleView = [[DHGeometryView alloc] initWithObjects:@[point,circle] andSuperView:geometryView];
    
    [self afterDelay:1.0 :^{
        if (!self.showingHint) return;
        
        UIView* hintView = [[UIView alloc]initWithFrame:geometryView.frame];
        [geometryView addSubview:hintView];
        [hintView addSubview:circleView];
        [hintView addSubview:perpView];
        [hintView addSubview:midView];
        
        Message* message1 = [[Message alloc] initAtPoint:CGPointMake(50,200) addTo:hintView];
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            [message1 position: CGPointMake(150,500)];
        }
        if (self.iPhoneVersion) {
            [message1 position: CGPointMake(5,50)];
        }
        
        [self afterDelay:0.5 :^{
            [self showEndHintMessageInView:hintView];
        }];
        
        if (!hint1_OK) {
            [self afterDelay:0.0 performBlock:^{
                [message1 text:@"The circumcircle passes through all three vertices of the triangle."];
                [self fadeIn:message1 withDuration:1.0];
            }];
            
            [self afterDelay:4.0 performBlock:^{
                [message1 appendLine:@"So the center of the circumcircle is equidistant from the points A, B and C."
                        withDuration:1.0];
            }];
            
            [self afterDelay:8.0 performBlock:^{
                [message1 appendLine:@"The midpoint of line segment BC is equidistant from the points B and C."
                        withDuration:1.0];
                [self fadeIn:midView withDuration:2.0];
            }];
            
            [self afterDelay:12.0 performBlock:^{
                [message1 appendLine:@"Can you construct a line that is equidistant from the points B and C?"
                        withDuration:1.0];
                [self fadeIn:perpView withDuration:2.0];
                hint1_OK = YES;
            }];
        }
        else if (!hint2_OK) {
            [self afterDelay:0.0 performBlock:^{
                [message1 text:@"The line with this property is called the perpendicular bisector of line segment BC."];
                [self fadeIn:message1 withDuration:1.0];
            }];
            
            [self afterDelay:4.0 performBlock:^{
                [message1 appendLine:@"The line is perpendicular to BC and passes through the midpoint."
                        withDuration:1.0];
                [self fadeIn:perpView withDuration:2.0];
                [self fadeIn:midView withDuration:2.0];
            }];
            
            [self afterDelay:8.0 performBlock:^{
                [message1 appendLine:@"The center of the circumcircle is equidistant from point B and C."
                        withDuration:1.0];
            }];
            
            [self afterDelay:10.0 performBlock:^{
                [self fadeIn:circleView withDuration:2.0];
            }];
            
            [self afterDelay:12.0 performBlock:^{
                [message1 appendLine:@"Hence, it must lie somewhere on this line!"
                        withDuration:1.0];
                [self movePointOnLine:point toTValue:-280 withDuration:5.0 inView:circleView];
            }];
            
            [self afterDelay:17.0 performBlock:^{
                [self movePointOnLine:point toTValue:-100 withDuration:2.0 inView:circleView];
                hint2_OK = YES;
            }];
        }
    }];
    
}
@end
