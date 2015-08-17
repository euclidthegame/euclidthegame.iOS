//
//  DHLevelSegmentInThree.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-09.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelSegmentInThree.h"

#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@interface DHLevelSegmentInThree () {
    DHLineSegment* _lAB;
}
@end

@implementation DHLevelSegmentInThree

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
- (void)showHint
{
    DHGeometryView* geometryView = self.levelViewController.geometryView;
    
    if (self.showingHint) {
        [self hideHint];
        return;
    }
    
    self.showingHint = YES;
    
    [self slideOutToolbar];
    
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
    
    [self afterDelay:1.0 :^{
        if (!self.showingHint) return;
        
        UIView* hintView = [[UIView alloc]initWithFrame:geometryView.frame];
        [geometryView addSubview:hintView];
        
        [hintView addSubview:segment3View];
        [hintView addSubview:segment2View];
        [hintView addSubview:segment1View];
        
        Message* message1 = [[Message alloc] initAtPoint:CGPointMake(30,300) addTo:hintView];
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            [message1 position: CGPointMake(150,400)];
        }

        [self afterDelay:2.0 :^{
            [self showEndHintMessageInView:hintView];
        }];
        
        [self afterDelay:0.0 performBlock:^{
            [message1 text:@"Let's start with a simpler challenge."];
            [self fadeIn:message1 withDuration:1.0];
        }];
        [self afterDelay:4.0 performBlock:^{
            [message1 appendLine:(@"Construct: \n (1) a random point C, not on the segment AB"
                                  @"\n (2) a line segment from A to C")
                    withDuration:1.0 forceNewLine:YES];
            [self fadeIn:segment1View withDuration:1.0];
        }];
        [self afterDelay:8.0 performBlock:^{
            [message1 appendLine:@" (3) a line segment with length AC that starts on C"
                    withDuration:1.0 forceNewLine:YES];
            [self fadeIn:segment2View withDuration:1.0];
        }];
        [self afterDelay:12.0 performBlock:^{
            [message1 appendLine:@" (4) a line segment with length AC that starts on D"
                    withDuration:1.0 forceNewLine:YES];
            [self fadeIn:segment3View withDuration:1.0];
        }];
        [self afterDelay:16.0 performBlock:^{
            [message1 appendLine:@"Note that the line segment AE is now cut into three equal parts."
                    withDuration:1.0 forceNewLine:YES];
        }];
        
    }];
    
}
@end

