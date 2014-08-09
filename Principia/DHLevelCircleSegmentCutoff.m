//
//  DHLevelCircleSegmentCutoff.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-09.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelCircleSegmentCutoff.h"

#import "DHGeometricObjects.h"

@interface DHLevelCircleSegmentCutoff () {
    DHLineSegment* _lAB;
    DHLine* _givenLine;
    DHPoint* _pC;
    BOOL hint1_OK;
    BOOL hint2_OK;
}

@end

@implementation DHLevelCircleSegmentCutoff

- (NSString*)subTitle
{
    return @"Cut it out";
}

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
    hint1_OK = NO;
    hint2_OK = NO;
    
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

-(void)hint:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view and:(NSLayoutConstraint *)heightToolBar and:(UIButton *)hintButton {
    
    if ([self.hintButton.titleLabel.text isEqualToString:@"Hide hint"] ) {
        [self hideHint];
        return;
    }
    if (hint1_OK) {
        [self showTemporaryMessage:@"No more hints available." atPoint:CGPointMake(self.geometryView.center.x,50) withColor:[UIColor darkGrayColor] andTime:3.0];
        [hintButton setTitle:@"Show hint" forState:UIControlStateNormal];
        hint1_OK = NO;
        return;
    }
    
    [hintButton setTitle:@"Hide hint" forState:UIControlStateNormal];
    for (int a=0; a<90; a++) {
        [self performBlock:^{
            heightToolBar.constant= 70 - a;
        } afterDelay:a* (1/90.0) ];
    }
    
    Message* message1 = [[Message alloc] initWithMessage:@"We are looking for a circle such that:" andPoint:CGPointMake(270,100)];
    Message* message2 = [[Message alloc] initWithMessage:@"  AB = DE" andPoint:CGPointMake(270,120)];
    Message* message3 = [[Message alloc] initWithMessage:@"Remember the intersting fact that we've learned in Level 14." andPoint:CGPointMake(270,140)];
    Message* message4 = [[Message alloc] initWithMessage:@"The perpendicular bisector of DE must pass through the center." andPoint:CGPointMake(270,160)];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        [message1 position: CGPointMake(150,500)];
        [message2 position: CGPointMake(150,520)];
        [message3 position: CGPointMake(150,540)];
        [message4 position: CGPointMake(150,560)];
    }
    
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
    DHGeometryView* perpView = [[DHGeometryView alloc]initWithObjects:@[lp,ip1] andSuperView:geometryView];
    
    UIView* hintView = [[UIView alloc]initWithFrame:geometryView.frame];
    [geometryView addSubview:hintView];
    [hintView addSubview:perpView];
    [hintView addSubview:circleView];
    [hintView addSubview:segmentView];
    [hintView addSubview:message1];
    [hintView addSubview:message2];
    [hintView addSubview:message3];
    [hintView addSubview:message4];
    
    if (!hint1_OK) {
        [self afterDelay:0.0 performBlock:^{
            [self fadeIn:message1 withDuration:1.0];
            [self fadeIn:circleView withDuration:2.0];
        }];
        [self afterDelay:3.0 performBlock:^{
            [self fadeIn:message2 withDuration:1.0];
        }];
        [self afterDelay:4.0 performBlock:^{
            [self fadeIn:segmentView withDuration:0.0];
            [self movePointFrom:p1 to:ip2 withDuration:3.0 inView:segmentView];
            [self movePointFrom:p2 to:ip3 withDuration:3.0 inView:segmentView];
            
        }];
        [self afterDelay:8.0 performBlock:^{
            [self fadeIn:message3 withDuration:1.0];

        }];
        [self afterDelay:12.0 performBlock:^{
            [self fadeIn:perpView withDuration:2.0];
            [self fadeIn:message4 withDuration:1.0];
            hint1_OK = YES;
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
