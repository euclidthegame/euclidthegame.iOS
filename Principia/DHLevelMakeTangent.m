//
//  DHLevelMakeTangent.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-06.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelMakeTangent.h"

#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@interface DHLevelMakeTangent () {
    DHCircle* _circle;
    BOOL _step1finished;
    BOOL centerOK;
}

@end

@implementation DHLevelMakeTangent

- (NSString*)levelDescription
{
    return (@"Construct a line (segment) tangent to the given circle");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct a line (segment) tangent to the circle. \n\n"
            @"A tangent line to a circle is a line that only touches the circle at one point.");
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
    return 3;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 3;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:200 andY:200];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:300 andY:220];
    
    DHCircle* circle = [[DHCircle alloc] init];
    circle.center = pA;
    circle.pointOnRadius = pB;
    
    [geometricObjects addObject:circle];
 
    _circle = circle;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    
    DHLineSegment* r = [[DHLineSegment alloc] initWithStart:_circle.center andEnd:_circle.pointOnRadius];
    DHPerpendicularLine* pl = [[DHPerpendicularLine alloc] initWithLine:r andPoint:r.end];
    
    [objects insertObject:pl atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    DHPoint* pCenter = _circle.center;
    DHPoint* pRadius = _circle.pointOnRadius;
    
    // Move A and B and ensure solution holds
    CGPoint pointA = pCenter.position;
    CGPoint pointB = pRadius.position;
    
    pCenter.position = CGPointMake(pointA.x - 1, pointA.y - 1);
    pRadius.position = CGPointMake(pointB.x + 1, pointB.y + 1);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    pCenter.position = pointA;
    pRadius.position = pointB;
    
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    BOOL tangentOK = NO;
    centerOK = NO;
    
    for (id object in geometricObjects) {
        
        if (EqualPoints(_circle.center, object)){
            centerOK = YES;
            
        }
        if (LineObjectTangentToCircle(object, _circle)) {
            tangentOK = YES;
            break;
        }
    }
    
    if (tangentOK) {
        self.progress = 100;
        return YES;
    }
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    for (id object in objects){
        if (EqualPoints(_circle.center, object)) {
            return _circle.center.position;
        }
    
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
    hintView.geoViewTransform = geometryView.geoViewTransform;
    hintView.backgroundColor = [UIColor whiteColor];
    hintView.layer.opacity = 0;
    hintView.hideBottomBorder = YES;
    [geometryView addSubview:hintView];
    [self fadeInViews:@[hintView] withDuration:1.0];
    hintView.geometricObjects = [NSMutableArray arrayWithObject:_circle];
    
    [self afterDelay:1.0 :^{
        if (!self.showingHint) return;
        hintView.frame = geometryView.frame;
        [hintView setNeedsDisplay];
        [self afterDelay:0.5 :^{
            [self showEndHintMessageInView:hintView];
        }];
        
        DHLineSegment* s1 = [[DHLineSegment alloc] initWithStart:_circle.center andEnd:_circle.pointOnRadius];
        DHPerpendicularLine* l1 = [[DHPerpendicularLine alloc] initWithLine:s1 andPoint:_circle.pointOnRadius];
        DHPoint* p1 = [[DHPoint alloc] initWithPosition:_circle.pointOnRadius.position];
        DHAngleIndicator* angle = [[DHAngleIndicator alloc] initWithLine1:l1 line2:s1 andRadius:20];
        angle.label = @"?";
        angle.anglePosition = 1;
        
        s1.temporary = YES;
        l1.temporary = YES;
        p1.temporary = YES;

        DHGeometryView* tangentView = [[DHGeometryView alloc] initWithObjects:@[l1]
                                                                   supView:geometryView addTo:hintView];
        DHGeometryView* radiusView = [[DHGeometryView alloc] initWithObjects:@[angle, s1, _circle.center]
                                                                      supView:geometryView addTo:hintView];
        DHGeometryView* p1View = [[DHGeometryView alloc] initWithObjects:@[p1]
                                                                      supView:geometryView addTo:hintView];
        
        Message* message1 = [[Message alloc] initAtPoint:CGPointMake(80,460) addTo:hintView];
        
        [self afterDelay:0.0:^{
            [message1 text:@"Assume that we already have a tangent to the circle."];
            [self fadeInViews:@[message1, tangentView] withDuration:2.0];
        }];
        [self afterDelay:2.5:^{
            [message1 appendLine:@"By definition, it will only touch the circle at one point."
                    withDuration:2.0];
            [self fadeInViews:@[p1View] withDuration:2.0];
        }];
        [self afterDelay:5.0:^{
            [message1 appendLine:@"Can you work out what the angle between the tangent and"
                    withDuration:2.0];
        }];

        [self afterDelay:6.0:^{
            [self fadeInViews:@[radiusView] withDuration:4.0];
        }];
        
        [self afterDelay:7.5:^{
            [message1 appendLine:@"a segment from that point to the circle center must be?"
                    withDuration:2.0];
        }];
        
    }];
}


@end
