//
//  DHLevelSegmentInThree.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-09.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelSegmentInThree.h"

#import "DHGeometricObjects.h"

@interface DHLevelSegmentInThree () {
    DHLineSegment* _lAB;
    BOOL hint1_OK;
    BOOL hint2_OK;
}

@end

@implementation DHLevelSegmentInThree

- (NSString*)subTitle
{
    return @"Lucky number three";
}

- (NSString*)levelDescription
{
    return (@"Construct two points, cutting the given segment into three equal pieces");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct two points, such that the segment is cut into three equal pieces.");
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
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:150 andY:250];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:450 andY:230];
    
    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:pA andEnd:pB];

    [geometricObjects addObject:lAB];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    
    _lAB = lAB;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHPointOnLine* pC = [[DHPointOnLine alloc] initWithLine:_lAB andTValue:1/3.0];
    DHPointOnLine* pD = [[DHPointOnLine alloc] initWithLine:_lAB andTValue:2/3.0];
    pC.hideBorder = YES;
    pD.hideBorder = YES;
    [objects addObject:pC];
    [objects addObject:pD];
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
    DHPointOnLine* pC = [[DHPointOnLine alloc] initWithLine:_lAB andTValue:1/3.0];
    DHPointOnLine* pD = [[DHPointOnLine alloc] initWithLine:_lAB andTValue:2/3.0];
    
    BOOL firstPointOK = NO;
    BOOL secondPointOK = NO;
    BOOL intersectionAtFirstPointOK = NO;
    BOOL intersectionAtSecondPointOK = NO;
    
    for (id object in geometricObjects){
        if (object == _lAB || object == _lAB.start || object == _lAB.end) continue;
        
        // Do not count lines parallel with AB intersecting lines with C or D
        if (EqualDirection2(_lAB, object)) continue;
        
        if (PointOnLine(pC, object) || PointOnCircle(pC, object)) intersectionAtFirstPointOK = YES;
        if (PointOnLine(pD, object) || PointOnCircle(pD, object)) intersectionAtSecondPointOK = YES;
        if (EqualPoints(object, pC)) firstPointOK = YES;
        if (EqualPoints(object,pD)) secondPointOK = YES;
    }
    
    if (firstPointOK && secondPointOK) {
        self.progress = 100;
        return YES;
    }
    
    self.progress = (intersectionAtFirstPointOK + firstPointOK +
                     intersectionAtSecondPointOK + secondPointOK)/4.0*100;
    
    return NO;
}

- (CGPoint)testObjectsForProgressHints:(NSArray *)objects{
    
    DHPointOnLine* pC = [[DHPointOnLine alloc] initWithLine:_lAB andTValue:1/3.0];
    DHPointOnLine* pD = [[DHPointOnLine alloc] initWithLine:_lAB andTValue:2/3.0];
    
    
    for (id object in objects){
        // Do not count lines parallel with AB intersecting lines with C or D
        if (EqualDirection2(_lAB, object)) continue;
        
        if (PointOnLine(pC, object)) return Position(object);
        if (PointOnCircle(pC, object)) return Position(object);
        if (PointOnLine(pD, object)) return Position(object);
        if (PointOnCircle(pD, object)) return Position(object);
        if (EqualPoints(object, pC)) return pC.position;
        if (EqualPoints(object,pD)) return pD.position;
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
    
    Message* message1 = [[Message alloc] initWithMessage:@"Let's start with a simpler challenge. " andPoint:CGPointMake(30,300)];
    Message* message2 = [[Message alloc] initWithMessage:@"Construct: - a random point C not on the line and the line segment AC" andPoint:CGPointMake(30,320)];
    Message* message3 = [[Message alloc] initWithMessage:@"                  - a line segment with length AC that starts on C" andPoint:CGPointMake(30,340)];
    Message* message4 = [[Message alloc] initWithMessage:@"                  - a line segment with length AC that starts on D" andPoint:CGPointMake(30,360)];
    Message* message5 = [[Message alloc] initWithMessage:@"Note that the line segment AE is now cut into three equal parts." andPoint:CGPointMake(30,400)];
    
    DHPoint* pointC = [[DHPoint alloc]initWithPositionX:_lAB.start.position.x+50 andY:_lAB.end.position.y-50];
    pointC.label = @"C";
    DHTranslatedPoint* pointD = [[DHTranslatedPoint alloc]initStart:_lAB.start end:pointC newStart:pointC];
    pointD.label = @"D";
    DHTranslatedPoint* pointE = [[DHTranslatedPoint alloc]initStart:_lAB.start end:pointC newStart:pointD];
    pointE.label = @"E";
    DHLineSegment* segment1 = [[DHLineSegment alloc]initWithStart:_lAB.start andEnd:pointC];
    DHLineSegment* segment2 = [[DHLineSegment alloc]initWithStart:pointC andEnd:pointD];
    DHLineSegment* segment3 = [[DHLineSegment alloc]initWithStart:pointD andEnd:pointE];
    
    
    DHGeometryView* segment1View = [[DHGeometryView alloc]initWithObjects:@[segment1,pointC] andSuperView:geometryView];
    DHGeometryView* segment2View = [[DHGeometryView alloc]initWithObjects:@[segment2,pointD] andSuperView:geometryView];
    DHGeometryView* segment3View = [[DHGeometryView alloc]initWithObjects:@[segment3,pointE] andSuperView:geometryView];
    
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        [message1 position: CGPointMake(150,500)];
        [message2 position: CGPointMake(150,520)];
        [message3 position: CGPointMake(150,540)];
        [message4 position: CGPointMake(150,560)];
        [message4 position: CGPointMake(150,580)];
    }
    
    UIView* hintView = [[UIView alloc]initWithFrame:geometryView.frame];
    [geometryView addSubview:hintView];
    
    [hintView  addSubview:segment3View];
    [hintView  addSubview:segment2View];
    [hintView addSubview:segment1View];

    [hintView addSubview:message1];
    [hintView addSubview:message2];
    [hintView addSubview:message3];
    [hintView addSubview:message4];
    [hintView addSubview:message5];
    
    
    
    if (!hint1_OK) {
        [self afterDelay:0.0 performBlock:^{
            [self fadeIn:message1 withDuration:1.0];
        }];
        [self afterDelay:4.0 performBlock:^{
            [self fadeIn:message2 withDuration:1.0];
            [self fadeIn:segment1View withDuration:1.0];
        }];
        [self afterDelay:8.0 performBlock:^{
            [self fadeIn:message3 withDuration:1.0];
            [self fadeIn:segment2View withDuration:1.0];
        }];
        [self afterDelay:12.0 performBlock:^{
            [self fadeIn:message4 withDuration:1.0];
            [self fadeIn:segment3View withDuration:1.0];
        }];
        [self afterDelay:16.0 performBlock:^{
            [self fadeIn:message5 withDuration:1.0];
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

