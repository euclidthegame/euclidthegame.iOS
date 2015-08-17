//
//  DHLevel3.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelMidPoint.h"
#import <CoreGraphics/CGBase.h>
#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@interface DHLevelMidPoint () {
    DHLineSegment* _lineAB;
    DHPoint* _pointA;
    DHPoint* _pointB;
    BOOL _step1finished;
    BOOL pointOnMidLineOK;
    BOOL secondPontOnMidLineOK;
}

@end

@implementation DHLevelMidPoint

- (NSString*)levelDescription
{
    return @"Construct the midpoint of line segment AB.";
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct the midpoint of line segment AB. \n\nThe midpoint divides the line segment AB into two parts of equal length.");
}

- (NSString *)additionalCompletionMessage
{
    return @"Well done! You unlocked a new tool: Constructing a midpoint!";
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable);
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
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:400];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:400];
    DHLineSegment* l1 = [[DHLineSegment alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    
    _lineAB = l1;
    _pointA = p1;
    _pointB = p2;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHMidPoint* mid = [[DHMidPoint alloc] init];
    mid.start = _lineAB.start;
    mid.end = _lineAB.end;
    [objects addObject:mid];
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
    
    _lineAB.start.position = CGPointMake(100, 100);
    _lineAB.end.position = CGPointMake(400, 400);
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
    pointOnMidLineOK = NO;
    secondPontOnMidLineOK = NO;
    BOOL midPointOK = NO;
    BOOL lineThroughMidPointOK = NO;
    self.progress = 0;
    
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:_lineAB.start andPoint2:_lineAB.end];
    DHPerpendicularLine* midLine = [[DHPerpendicularLine alloc] initWithLine:_lineAB andPoint:mp];
    
    for (id object in geometricObjects) {
        if (object != _lineAB && !EqualDirection(_lineAB, object) && PointOnLine(mp, object)) {
            lineThroughMidPointOK = YES;
        }
        
        if ([[object class] isSubclassOfClass:[DHPoint class]] == NO) continue;
        if (object == _lineAB.start || object == _lineAB.end) continue;
        
        if (EqualPoints(object,mp) && [object class] != [DHPointOnLine class]) {
            midPointOK = YES;
        }
        DHPoint* p = object;
        if (DistanceFromPointToLine(p, midLine) < 0.0001) {
            if (!pointOnMidLineOK) {
                pointOnMidLineOK = YES;
            } else {
                secondPontOnMidLineOK = YES;
            }
        }
    }
    
    //self.progress = (pointOnMidLineOK + secondPontOnMidLineOK + midPointOK)/3.0 * 100;
    
    if (midPointOK) {
        self.progress = 100;
        return YES;
    } else if (lineThroughMidPointOK) {
        self.progress = 50;
    }
    
    return NO;
}

- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    
    DHCircle* cAB = [[DHCircle alloc] initWithCenter:_lineAB.start andPointOnRadius:_lineAB.end];
    DHCircle* cBA = [[DHCircle alloc] initWithCenter:_lineAB.end andPointOnRadius:_lineAB.start];
    DHTrianglePoint* pTop = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.start andPoint2:_lineAB.end];
    DHTrianglePoint* pBottom = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.end andPoint2:_lineAB.start];
    DHLineSegment* segment = [[DHLineSegment alloc]initWithStart:pBottom andEnd:pTop];
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:_lineAB.start andPoint2:_lineAB.end];
    
    for (id object in objects){
        if (EqualCircles(object,cAB)) return cAB.center.position;
        if (EqualCircles(object,cBA)) return cBA.center.position;
        if (EqualPoints(object, pTop)) return pTop.position;
        if (EqualPoints(object,pBottom)) return pBottom.position;
        if (LineObjectCoversSegment(object,segment)) return MidPointFromPoints(segment.start.position,segment.end.position);
        if (EqualPoints(object,mp)) return mp.position;
    }
    return CGPointMake(NAN, NAN);
    
}

- (void)animation:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view {
    
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:300];
    DHLineSegment* l1 = [[DHLineSegment alloc] init];
    l1.start = p1;
    l1.end = p2;
    _lineAB = l1;
    DHMidPoint* mid = [[DHMidPoint alloc] init];
    mid.start = _lineAB.start;
    mid.end = _lineAB.end;
    
    CGFloat steps = 100;
    CGPoint dA = PointFromToWithSteps(_pointA.position, p1.position, steps);
    CGPoint dB = PointFromToWithSteps(_pointB.position, p2.position, steps);
    
    CGPoint oldOffset = geometryView.geoViewTransform.offset;
    CGFloat oldScale = geometryView.geoViewTransform.scale;
    CGFloat newScale = 1;
    CGPoint newOffset = CGPointMake(0,0);
    if (self.iPhoneVersion) {
        newScale = 0.5;
        newOffset = CGPointMake(-30, 0);
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        [geometryView.geoViewTransform setScale:newScale];
        CGPoint oldPointA = _pointA.position;
        CGPoint oldPointB = _pointB.position;
        _pointA.position = p1.position;
        _pointB.position = p2.position;
        [geometryView centerContent];
        newOffset = geometryView.geoViewTransform.offset;
        [geometryView.geoViewTransform setOffset:oldOffset];
        [geometryView.geoViewTransform setScale:oldScale];
        _pointA.position = oldPointA;
        _pointB.position = oldPointB;
    }
    
    CGPoint offset = PointFromToWithSteps(oldOffset, newOffset, 100);
    CGFloat scale =  pow((newScale/oldScale),0.01) ;
    
    for (int a=0; a<steps; a++) {
        [self performBlock:^{
            [geometryView.geoViewTransform offsetWithVector:CGPointMake(offset.x, offset.y)];
            [geometryView.geoViewTransform setScale:geometryView.geoViewTransform.scale *scale];
            _pointA.position = CGPointMake(_pointA.position.x + dA.x,_pointA.position.y + dA.y);
            _pointB.position = CGPointMake(_pointB.position.x + dB.x,_pointB.position.y + dB.y);
            
            for (id object in geometryView.geometricObjects) {
                if ([object respondsToSelector:@selector(updatePosition)]) {
                    [object updatePosition];
                }
            }
            [geometryView setNeedsDisplay];
        } afterDelay:a* (1/steps)];
    }
    
    [self performBlock:^{
        DHGeometryView* geoView = [[DHGeometryView alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
        [view addSubview:geoView];
        geoView.hideBorder = YES;
        geoView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        geoView.opaque = NO;
        
        NSMutableArray* geometricObjects2 = [[NSMutableArray alloc]init];
        
        [geometricObjects2 addObject:l1];
        [geometricObjects2 addObject:p1];
        [geometricObjects2 addObject:p2];
        
        [geometricObjects2 addObject:mid];
        
        geoView.geometricObjects = geometricObjects2;
        
        // Adjust points to new coordinates
        CGPoint relPos = [geoView.superview convertPoint:geoView.frame.origin toView:geometryView];
        p1.position = CGPointMake(p1.position.x + newOffset.x, p1.position.y - relPos.y + newOffset.y );
        p2.position = CGPointMake(p2.position.x +newOffset.x  , p2.position.y - relPos.y +newOffset.y );

        [geoView setNeedsDisplay];
        
        // Get coordinates of Equilateral triangle tool
        UIView* segment5 = [toolControl.subviews objectAtIndex:4];
        UIView* segment6 = [toolControl.subviews objectAtIndex:5];
        CGPoint pos5 = [segment5.superview convertPoint:segment5.frame.origin toView:geoView];
        CGPoint pos6 = [segment6.superview convertPoint:segment6.frame.origin toView:geoView];
   
        CGFloat xpos = (pos5.x + pos6.x )/2  ;
        CGFloat ypos =  view.frame.size.height - 9;
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if(UIInterfaceOrientationIsLandscape(orientation)) {
            ypos = ypos - 16;
        }
        
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.keyPath = @"position";
        animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(geoView.layer.position.x, geoView.layer.position.y)];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(xpos, ypos)];
        animation.duration = 3;
        
        CABasicAnimation *animation2 = [CABasicAnimation animation];
        animation2.keyPath = @"transform.scale";
        animation2.fromValue = [NSNumber numberWithFloat:1];
        animation2.toValue = [NSNumber numberWithFloat:0.16];
        animation2.duration = 3;
        
        [geoView.layer addAnimation:animation forKey:@"basic1"];
        [geoView.layer addAnimation:animation2 forKey:@"basic2"];
        geoView.layer.position = CGPointMake(xpos, ypos);
        
        geoView.transform = CGAffineTransformMakeScale(0.16, 0.16);
        
        [self performBlock:^{
            CABasicAnimation *animation3 = [CABasicAnimation animation];
            animation3.keyPath = @"opacity";
            animation3.fromValue = [NSNumber numberWithFloat:1];
            animation3.toValue = [NSNumber numberWithFloat:0];
            animation3.duration = 1;
            [geoView.layer addAnimation:animation3 forKey:@"basic3"];
            geoView.alpha = 0;
            
        } afterDelay:2.8];
        [UIView
         animateWithDuration:1.0 delay:3 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             [toolControl setEnabled:YES forSegmentAtIndex:6];
         }
         completion:^(BOOL finished){
             [geoView removeFromSuperview];
         }];
    } afterDelay:1.0];
    
}

- (void)showHint {
    DHGeometryView* geometryView = self.levelViewController.geometryView;
    
    if (self.showingHint == YES) {
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
        [hintView addSubview:oldObjects];
        
        [geometryView addSubview:hintView];
        
        Message* message1 = [self createUpperMessageWithSuperView:hintView];
        
        DHTrianglePoint* tp1 = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.start andPoint2:_lineAB.end];
        DHTrianglePoint* tp2 = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.end andPoint2:_lineAB.start];
        
        DHLineSegment* segmentAC = [[DHLineSegment alloc] initWithStart:tp1 andEnd:tp2];
        segmentAC.temporary = YES;
        DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:_lineAB.start andPoint2:_lineAB.end];
        mp.temporary = YES;
        
        DHGeometryView* segmentView = [[DHGeometryView alloc] initWithObjects:@[segmentAC]
                                                                     supView:geometryView addTo:hintView];
        DHGeometryView* mpView = [[DHGeometryView alloc] initWithObjects:@[mp]
                                                                      supView:geometryView addTo:hintView];
        [hintView bringSubviewToFront:message1];

        
        [self afterDelay:0.0:^{
            [message1 text:@"To create a point that is always located at the midpoint,"];
            [self fadeInViews:@[message1] withDuration:2.0];
        }];
        
        [self afterDelay:3.0 :^{
            [message1 appendLine:@"we need to construct a line that passes through the midpoint."
                    withDuration:2.0];
            [self fadeInViews:@[segmentView] withDuration:2.0];
        }];
        
        [self afterDelay:6.0 :^{
            [message1 appendLine:@"Then construct an intersection point with the segment AB."
                    withDuration:2.0];
            [self fadeInViews:@[mpView] withDuration:2.0];
        }];
        
        if (!secondPontOnMidLineOK) {
            [self afterDelay:9.0 :^{
                [message1 appendLine:@"Look for a tool that provides points over/under segment AB's midpoint!"
                        withDuration:2.0];
            }];
        }
        
        [self afterDelay:2.0 :^{
            [self showEndHintMessageInView:hintView];
        }];
        
    }];
    

}

@end
