//
//  DHLevelLineCopyOnLine.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-06.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelLineCopyOnLine.h"

#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@interface DHLevelLineCopyOnLine () {
    DHLineSegment* _lineAB;
    DHLineSegment* _lineCD;
    BOOL _step1finished;
    BOOL circleWithABRadiusAtCOK;
}

@end

@implementation DHLevelLineCopyOnLine

- (NSString*)levelDescription
{
    return (@"Construct a point E on CD such that CE has the same length as AB.");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct a new point E on the line segment CD such that CE has the same length as AB.");
}

- (NSUInteger)minimumNumberOfMoves
{
    return 1;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 5;
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable_Weak |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable | DHTranslateToolAvailable |
            DHCompassToolAvailable);
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:100 andY:300];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:200 andY:400];
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:150 andY:200];
    DHPoint* pD = [[DHPoint alloc] initWithPositionX:400 andY:200];
    
    DHLineSegment* lAB = [[DHLineSegment alloc] init];
    lAB.start = pA;
    lAB.end = pB;
    
    DHLineSegment* lCD = [[DHLineSegment alloc] init];
    lCD.start = pC;
    lCD.end = pD;
    
    [geometricObjects addObject:lAB];
    [geometricObjects addObject:lCD];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    [geometricObjects addObject:pC];
    [geometricObjects addObject:pD];
    
    _lineAB = lAB;
    _lineCD = lCD;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = _lineCD.start;
    tp.translationStart = _lineAB.start;
    tp.translationEnd = _lineAB.end;
    DHCircle* c = [[DHCircle alloc] initWithCenter:_lineCD.start andPointOnRadius:tp];
    DHIntersectionPointLineCircle* ip = [[DHIntersectionPointLineCircle alloc] init];
    ip.c = c;
    ip.l = _lineCD;
    
    [objects addObject:ip];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _lineAB.start.position;
    CGPoint pointB = _lineAB.end.position;
    
    _lineAB.start.position = CGPointMake(110, 300);
    _lineAB.end.position = CGPointMake(205, 450);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _lineAB.start.position = pointA;
    _lineAB.end.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = _lineCD.start;
    tp.translationStart = _lineAB.start;
    tp.translationEnd = _lineAB.end;
    DHCircle* circle = [[DHCircle alloc] initWithCenter:_lineCD.start andPointOnRadius:tp];
    CGFloat distAB = DistanceBetweenPoints(_lineAB.start.position, _lineAB.end.position);
    
    circleWithABRadiusAtCOK = NO;
    
    for (id object in geometricObjects){
        if (PointOnLine(object,_lineCD)){
            DHPoint* p = object;
            CGFloat distCP = DistanceBetweenPoints(p.position, _lineCD.start.position);
            if (EqualScalarValues(distAB, distCP)) {
                self.progress = 100;
                return YES;
            }
        }
        if (EqualCircles(object,circle)) {
            circleWithABRadiusAtCOK = YES;
        }
    }
    
    self.progress = circleWithABRadiusAtCOK/2.0*100;
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = _lineCD.start;
    tp.translationStart = _lineAB.start;
    tp.translationEnd = _lineAB.end;
    DHCircle* circle = [[DHCircle alloc] initWithCenter:_lineCD.start andPointOnRadius:tp];
    
    for (id object in objects){
        if (PointOnLine(object,_lineCD)){
            DHPoint* p = object;
            if (LineSegmentsWithEqualLength([[DHLineSegment alloc]initWithStart:_lineCD.start andEnd:p],_lineAB))
                return p.position;
        }
        if (EqualCircles(object,circle)) return circle.center.position;
        
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
        
        UIView* hintView = [[UIView alloc]initWithFrame:geometryView.frame];
        hintView.backgroundColor = [UIColor whiteColor];
        
        DHGeometryView* oldObjects = [[DHGeometryView alloc] initWithObjects:geometryView.geometricObjects supView:geometryView addTo:hintView];
        oldObjects.hideBorder = NO;
        [oldObjects.layer setValue:[NSNumber numberWithFloat:1.0] forKeyPath:@"opacity"];
        
        [geometryView addSubview:hintView];
        
        Message* message1 = [[Message alloc] initAtPoint:CGPointMake(80,460) addTo:hintView];
        
        DHPoint* p1 = [[DHPoint alloc] initWithPosition:_lineAB.start.position];
        DHTranslatedPoint* p2 = [[DHTranslatedPoint alloc] initWithPoint1:_lineAB.start andPoint2:_lineAB.end
                                                                andOrigin:p1];
        DHCircle* c1 = [[DHCircle alloc] initWithCenter:p1 andPointOnRadius:p2];
        
        CGFloat abAngle = CGVectorAngle(_lineAB.vector);
        CGFloat cdAngle = CGVectorAngle(_lineCD.vector);
        DHPointOnCircle* p3 = [[DHPointOnCircle alloc] initWithCircle:c1 andAngle:abAngle];
        p3.label = @"";
        
        DHLineSegment* segmentP1P3 = [[DHLineSegment alloc] initWithStart:c1.center andEnd:p3];
        segmentP1P3.temporary = YES;
        
        [hintView addSubview:oldObjects];
        DHGeometryView* segmentView = [[DHGeometryView alloc] initWithObjects:@[segmentP1P3, p3] supView:geometryView
                                                                        addTo:hintView];
        
        [hintView bringSubviewToFront:message1];
        
        [self afterDelay:0.0:^{
            [message1 text:@"If you could simply move a copy of AB to C,"];
            [self fadeInViews:@[message1, segmentView] withDuration:2.0];
            [self movePoint:p1 toPosition:_lineCD.start.position withDuration:2.5 inViews:@[segmentView]];
        }];
        
        [self afterDelay:3.0 :^{
            [message1 appendLine:@"and rotate it to be parallel to CD, this would be simple."
                    withDuration:2.0];
            [self movePointOnCircle:p3 toAngle:cdAngle withDuration:2.0 inViews:@[segmentView]];
        }];
        
        [self afterDelay:6.0 :^{
            [message1 appendLine:@"Can you make an equivalent construction with the available tools?"
                    withDuration:2.0];
        }];
        
        [self afterDelay:2.0 :^{
            [self showEndHintMessageInView:hintView];
        }];
        
    }];
}

@end
