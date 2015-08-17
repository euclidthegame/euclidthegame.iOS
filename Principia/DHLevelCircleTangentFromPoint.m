//
//  DHCircleTangentFromPoint.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-11.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelCircleTangentFromPoint.h"

#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@interface DHLevelCircleTangentFromPoint () {
    DHPoint* _pointA;
    DHCircle* _circle;
    BOOL hint1_OK;
    BOOL hint2_OK;
}

@end

@implementation DHLevelCircleTangentFromPoint

- (NSString*)levelDescription
{
    return (@"Construct two tangents to the given circle from the point A.");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct two tangents to the given circle from the point A.\n\n"
            @"A tangent to a circle is a line that only touches the circle at one point.");
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
    return 6;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    hint1_OK = NO;
    hint2_OK = NO;
    
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:500 andY:400];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:200 andY:200];
    DHPoint* pRadius = [[DHPoint alloc] initWithPositionX:300 andY:200];
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:pB andPointOnRadius:pRadius];
    
    [geometricObjects addObject:c];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    
    _pointA = pA;
    _circle = c;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = _pointA;
    mp.end = _circle.center;
    
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_pointA];
    
    DHIntersectionPointCircleCircle* ip1 = [[DHIntersectionPointCircleCircle alloc] init];
    ip1.c1 = c1;
    ip1.c2 = _circle;
    ip1.onPositiveY = YES;

    DHIntersectionPointCircleCircle* ip2 = [[DHIntersectionPointCircleCircle alloc] init];
    ip2.c1 = c1;
    ip2.c2 = _circle;
    ip2.onPositiveY = NO;
    
    DHRay* r1 = [[DHRay alloc] initWithStart:_pointA andEnd:ip1];
    DHRay* r2 = [[DHRay alloc] initWithStart:_pointA andEnd:ip2];
    
    [objects insertObject:r1 atIndex:0];
    [objects insertObject:r2 atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _pointA.position;
    CGPoint pointB = _circle.center.position;
    
    _pointA.position = CGPointMake(pointA.x - 10, pointA.y - 10);
    _circle.center.position = CGPointMake(pointB.x + 10, pointB.y + 10);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _pointA.position = pointA;
    _circle.center.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:_pointA andPoint2:_circle.center];
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_pointA];
    DHIntersectionPointCircleCircle* ip1 = [[DHIntersectionPointCircleCircle alloc]
                                            initWithCircle1:c1 andCircle2:_circle onPositiveY:YES];
    DHIntersectionPointCircleCircle* ip2 =  [[DHIntersectionPointCircleCircle alloc]
                                             initWithCircle1:c1 andCircle2:_circle onPositiveY:NO];
    DHLine* l1 = [[DHLine alloc] initWithStart:_pointA andEnd:ip1];
    DHLine* l2 = [[DHLine alloc] initWithStart:_pointA andEnd:ip2];
    
    BOOL pointOnTangent1OK = NO;
    BOOL pointOnTangent2OK = NO;
    BOOL tangent1OK = NO;
    BOOL tangent2OK = NO;
    
    for (id object in geometricObjects) {
        if (object == _pointA || object == _circle) continue;
        
        if (PointOnLine(object, l1)) pointOnTangent1OK = YES;
        if (PointOnLine(object, l2)) pointOnTangent2OK = YES;
        if (PointOnLine(_pointA, object) && PointOnLine(ip1, object)) tangent1OK = YES;
        if (PointOnLine(_pointA, object) && PointOnLine(ip2, object)) tangent2OK = YES;
    }
    
    if (tangent1OK && tangent2OK) {
        self.progress = 100;
        return YES;
    }
    
    self.progress = (pointOnTangent1OK + tangent1OK + pointOnTangent2OK + tangent2OK)/4.0 * 100;
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects{
    
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = _pointA;
    mp.end = _circle.center;
    
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_pointA];
    
    DHIntersectionPointCircleCircle* ip1 = [[DHIntersectionPointCircleCircle alloc] init];
    ip1.c1 = c1;
    ip1.c2 = _circle;
    ip1.onPositiveY = YES;
    
    DHIntersectionPointCircleCircle* ip2 = [[DHIntersectionPointCircleCircle alloc] init];
    ip2.c1 = c1;
    ip2.c2 = _circle;
    ip2.onPositiveY = NO;
    
    DHRay* r1 = [[DHRay alloc] initWithStart:_pointA andEnd:ip1];
    DHRay* r2 = [[DHRay alloc] initWithStart:_pointA andEnd:ip2];
    
    
    for (id object in objects){
        if (PointOnLine(object, r1)) return Position(object);
        if (PointOnLine(object, r2)) return Position(object);
        if (EqualDirection(object, r1)) return Position(r1);
        if (EqualDirection(object, r2)) return Position(r2);
        if (EqualCircles(object, c1)) return Position(c1);
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
    
    DHMidPoint* mp = [[DHMidPoint alloc] init];
    mp.start = _pointA;
    mp.end = _circle.center;
    
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:mp andPointOnRadius:_pointA];
    
    DHIntersectionPointCircleCircle* ip1 = [[DHIntersectionPointCircleCircle alloc] init];
    ip1.c1 = c1;
    ip1.c2 = _circle;
    ip1.onPositiveY = YES;
    ip1.label = @"C";
    
    
    DHIntersectionPointCircleCircle* ip2 = [[DHIntersectionPointCircleCircle alloc] init];
    ip2.c1 = c1;
    ip2.c2 = _circle;
    ip2.onPositiveY = NO;
    ip2.label = @"D";
    
    DHRay* r1 = [[DHRay alloc] initWithStart:_pointA andEnd:ip1];
    DHRay* r2 = [[DHRay alloc] initWithStart:_pointA andEnd:ip2];

    
    DHLineSegment* s1 = [[DHLineSegment alloc]initWithStart:ip1 andEnd:_circle.center];
    DHLineSegment* s2 = [[DHLineSegment alloc]initWithStart:ip2 andEnd:_circle.center];
    DHLineSegment* s3 = [[DHLineSegment alloc] initWithStart:_pointA andEnd:_circle.center];
    
    DHGeometryView* tangentView = [[DHGeometryView alloc] initWithObjects:@[r1,r2, _pointA] andSuperView:geometryView];
    DHGeometryView* segentView = [[DHGeometryView alloc]initWithObjects:@[s1,s2,ip1,ip2] andSuperView:geometryView];
    DHGeometryView* segmentView = [[DHGeometryView alloc]initWithObjects:@[s3] andSuperView:geometryView];
    
    DHMidPoint* midpoint = [[DHMidPoint alloc]initWithPoint1:_circle.center andPoint2:_pointA];
    DHCircle* circle = [[DHCircle alloc]initWithCenter:midpoint andPointOnRadius:_pointA];
    DHPoint* pointB = [[DHPoint alloc]initWithPosition:_circle.center.position];
    _pointA.label = @"A";
    pointB.label = @"B";
    
    DHPointOnCircle* pointC = [[DHPointOnCircle alloc]initWithCircle:circle andAngle:-2.0];
    
    pointC.label = @"C";
    
    DHLineSegment* s4 = [[DHLineSegment alloc]initWithStart:pointB andEnd:pointC];
    DHLineSegment* s5 = [[DHLineSegment alloc]initWithStart:_pointA andEnd:pointC];
    
    DHAngleIndicator* angle1 = [[DHAngleIndicator alloc] initWithLine1:s4 line2:s5 andRadius:20];
    angle1.squareRightAngles = YES;
    angle1.anglePosition = 1;
    angle1.alwaysInner = YES;
    
    DHGeometryView* circleView = [[DHGeometryView alloc]initWithObjects:@[circle,s3,_pointA,pointB]andSuperView:geometryView];
    DHGeometryView* pointView = [[DHGeometryView alloc] initWithObjects:@[pointC] andSuperView:geometryView];
    DHGeometryView* triangleView = [[DHGeometryView alloc] initWithObjects:@[s4,s5, angle1] andSuperView:geometryView];
    
    DHCircle* c2 = [[DHCircle alloc] initWithCenter:_circle.center andPointOnRadius:_circle.pointOnRadius];
    c2.temporary = YES;
    DHGeometryView* circleView2 = [[DHGeometryView alloc] initWithObjects:@[c2] andSuperView:geometryView];
    
    
    [self afterDelay:1.0 :^{
        if (!self.showingHint) return;
        
        DHGeometryView* hintView = [[DHGeometryView alloc]initWithFrame:geometryView.frame];
        hintView.hideBottomBorder = YES;
        [geometryView addSubview:hintView];
        
        [hintView addSubview:circleView];
        [hintView addSubview:circleView2];
        [hintView addSubview:triangleView];
        [hintView addSubview:pointView];
        [hintView addSubview:tangentView];
        [hintView addSubview:segentView];
        [hintView addSubview:segmentView];
        
        Message* message1 = [[Message alloc] initAtPoint:CGPointMake(50,500) addTo:hintView];
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            [message1 position: CGPointMake(150,450)];
        }
        
        [self afterDelay:2.0 :^{
            [self showEndHintMessageInView:hintView];
        }];
        
        if (!hint1_OK) {
            [self afterDelay:0.0 performBlock:^{
                [self fadeOut:geometryView withDuration:1.0];
                
            }];
            [self afterDelay:1.0 performBlock:^{
                hintView.backgroundColor = [UIColor whiteColor];
                
                [self fadeIn:geometryView withDuration:1.0];
            }];
            [self afterDelay:2.0 performBlock:^{
                [message1 text:@"Suppose we have a circle with diameter AB."];
                [self fadeIn:message1 withDuration:1.0];
                [self fadeIn:circleView withDuration:2.0];
            }];
            [self afterDelay:6.0 performBlock:^{
                [message1 appendLine:@"And let C be a point on the circle."
                        withDuration:1.0];
                [self fadeIn:pointView withDuration:2.0];
            }];
            [self afterDelay:10.0 performBlock:^{
                [message1 appendLine:@"The triangle ABC is inscribed in the circle."
                        withDuration:1.0];
                [self fadeIn:triangleView withDuration:2.0];
            }];
            [self afterDelay:14.0 performBlock:^{
                [message1 appendLine:@"A very useful fact is that this inscribed triangle is right."
                        withDuration:1.0];
            }];
            [self afterDelay:18.0 performBlock:^{
                [message1 appendLine:@"For any point C on the circle."
                        withDuration:1.0];
                [triangleView.geometricObjects addObject:pointC];
                [pointView.geometricObjects removeObject:pointC];
                
                [pointView setNeedsDisplay];
                [self movePointOnCircle:pointC toAngle:2*M_PI - 3 withDuration:5.0 inView:triangleView];
                
                hint1_OK = YES;
            }];
        }
        else if (!hint2_OK){
            
            [self afterDelay:0.0 performBlock:^{
                [message1 text:@"We need to construct two tangents of the circle passing through point A."];
                [self fadeIn:message1 withDuration:1.0];
                [self fadeIn:circleView2 withDuration:2.0];
                [self fadeIn:tangentView withDuration:2.0];
            }];
            [self afterDelay:4.0 performBlock:^{
                [message1 appendLine:@"Note that the following segments are perpendicular to the tangents."
                        withDuration:1.0];
                [self fadeIn:segentView withDuration:2.0];
            }];
            [self afterDelay:8.0 performBlock:^{
                [message1 appendLine:@"Which means that the following triangles are right."
                        withDuration:1.0];
                [self fadeIn:segmentView withDuration:2.0];
            }];
            [self afterDelay:12.0 performBlock:^{
                [message1 appendLine:@"Just like an inscribed triangle with one side being the diameter."
                        withDuration:1.0];
                
                hint2_OK = YES;
            }];
        }
    }];

}


@end


