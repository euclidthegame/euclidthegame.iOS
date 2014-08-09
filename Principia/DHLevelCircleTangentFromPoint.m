//
//  DHCircleTangentFromPoint.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-11.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelCircleTangentFromPoint.h"

#import "DHGeometricObjects.h"

@interface DHLevelCircleTangentFromPoint () {
    DHPoint* _pointA;
    DHCircle* _circle;
    BOOL hint1_OK;
    BOOL hint2_OK;
}

@end

@implementation DHLevelCircleTangentFromPoint

- (NSString*)subTitle
{
    return @"Barely touching";
}

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

- (void)hint:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view and:(NSLayoutConstraint*)heightToolBar and:(UIButton*)hintButton{
    
    
    if ([self.hintButton.titleLabel.text isEqualToString:@"Hide hint"] ) {
        [self hideHint];
        return;
    }
    
    if (hint2_OK) {
        [self showTemporaryMessage:@"No more hints available." atPoint:CGPointMake(self.geometryView.center.x,50) withColor:[UIColor darkGrayColor] andTime:3.0];
        [hintButton setTitle:@"Show hint" forState:UIControlStateNormal];
        hint1_OK = NO;
        hint2_OK = NO;
        return;
    }
    
    [hintButton setTitle:@"Hide hint" forState:UIControlStateNormal];
    for (int a=0; a<90; a++) {
        [self performBlock:^{
            heightToolBar.constant= 70 - a;
        } afterDelay:a* (1/90.0) ];
    }
    
    Message* message1 = [[Message alloc] initWithMessage:@"Suppose we have a circle with diameter AB." andPoint:CGPointMake(50,500)];
    Message* message2 = [[Message alloc] initWithMessage:@"And let C be a point on the circle." andPoint:CGPointMake(50,520)];
    Message* message3 = [[Message alloc] initWithMessage:@"The triangle ABC is inscribed in the circle." andPoint:CGPointMake(50,540)];
    Message* message4 = [[Message alloc] initWithMessage:@"A very usefull fact is that this inscribed triangle is right." andPoint:CGPointMake(50,560)];
    Message* message5 = [[Message alloc] initWithMessage:@"For any point C on the circle." andPoint:CGPointMake(50,580)];
    
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        [message1 position: CGPointMake(150,500)];
        [message2 position: CGPointMake(150,520)];
        [message3 position: CGPointMake(150,540)];
        [message4 position: CGPointMake(150,560)];
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
    
    DHGeometryView* tangentView = [[DHGeometryView alloc] initWithObjects:@[r1,r2] andSuperView:geometryView];
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
    
    DHGeometryView* circleView = [[DHGeometryView alloc]initWithObjects:@[circle,s3,_pointA,pointB]andSuperView:geometryView];
    DHGeometryView* pointView = [[DHGeometryView alloc] initWithObjects:@[pointC] andSuperView:geometryView];
    DHGeometryView* triangleView = [[DHGeometryView alloc] initWithObjects:@[s4,s5] andSuperView:geometryView];
    
    
    UIView* hintView = [[UIView alloc]initWithFrame:geometryView.frame];
    [geometryView addSubview:hintView];
    
    [hintView addSubview:circleView];
    [hintView addSubview:triangleView];
    [hintView addSubview:pointView];
    [hintView addSubview:tangentView];
    [hintView addSubview:segentView];
    [hintView addSubview:segmentView];
    [hintView addSubview:message1];
    [hintView addSubview:message2];
    [hintView addSubview:message3];
    [hintView addSubview:message4];
    [hintView addSubview:message5];

    

    
    
    if (!hint1_OK) {
        [self afterDelay:0.0 performBlock:^{
            [self fadeOut:geometryView withDuration:1.0];
            
        }];
        [self afterDelay:1.0 performBlock:^{
            hintView.backgroundColor = [UIColor whiteColor];
            
            [self fadeIn:geometryView withDuration:1.0];
        }];
        [self afterDelay:2.0 performBlock:^{
            [self fadeIn:message1 withDuration:1.0];
            [self fadeIn:circleView withDuration:2.0];
        }];
        [self afterDelay:6.0 performBlock:^{
            [self fadeIn:message2 withDuration:1.0];
            [self fadeIn:pointView withDuration:2.0];
        }];
        [self afterDelay:10.0 performBlock:^{
            [self fadeIn:message3 withDuration:1.0];
            [self fadeIn:triangleView withDuration:2.0];
        }];
        [self afterDelay:14.0 performBlock:^{
            [self fadeIn:message4 withDuration:1.0];
        }];
        [self afterDelay:18.0 performBlock:^{
            [self fadeIn:message5 withDuration:1.0];
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
                [self fadeIn:tangentView withDuration:2.0];
            }];
            [self afterDelay:4.0 performBlock:^{
                [message2 text:@"Note that the following segments are perpendicular to the tangents."];
                [self fadeIn:message2 withDuration:1.0];
                [self fadeIn:segentView withDuration:2.0];
            }];
            [self afterDelay:8.0 performBlock:^{
                [message3 text:@"Which means that the following triangles are right."];
                [self fadeIn:message3 withDuration:1.0];
                [self fadeIn:segmentView withDuration:2.0];
            }];
            [self afterDelay:12.0 performBlock:^{
                [message4 text:@"Just like an inscirbed triangle with one side being the diameter."];
                [self fadeIn:message4 withDuration:1.0];
                hint2_OK = YES;
            }];
    }
}
-(void)hideHint {
    for (int a=0; a<90; a++) {
        [self performBlock:^{
            self.heightToolbar.constant= -20 + a;
        } afterDelay:a* (1/90.0) ];
    }
    if (!hint1_OK){        [self.hintButton setTitle:@"Show hint" forState:UIControlStateNormal];}
    else {[self.hintButton setTitle:@"Show next hint" forState:UIControlStateNormal];}
    [self.geometryView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    return;
}
        
@end


