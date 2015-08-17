//
//  DHLevelPerpendicularB.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-04.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelPerpendicularB.h"

#import <CoreGraphics/CGBase.h>
#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@interface DHLevelPerpendicularB () {
    DHPoint* _pointA;
    DHPoint* _pointB;
    DHLine* _lineA;
    BOOL _step1finished;
    BOOL pointOnLineOK;
}

@end

@implementation DHLevelPerpendicularB

- (NSString*)levelDescription
{
    return @"Construct a line through A perpendicular to the given line.";
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct a line (segment) perpendicular to the given line going through point A."
            @"\n \nWhen a straight line standing on a straight line makes the adjacent angles equal to one another, each of the equal angles is right, and the straight line standing on the other is called a perpendicular to that on which it stands.");
}


- (NSUInteger)minimumNumberOfMoves
{
    return 2;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 3;
}

- (NSString *)additionalCompletionMessage
{
    return @"You unlocked a new tool: Constructing perpendicular lines!";
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable_Weak |
            DHBisectToolAvailable);
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:300];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:400 andY:200];
    
    DHLine* l1 = [[DHLine alloc] initWithStart:p1 andEnd:p2];
    
    [geometricObjects addObject:l1];
    //[geometricObjects addObject:p1];
    //[geometricObjects addObject:p2];
    [geometricObjects addObject:p3];
    
    _pointA = p1;
    _pointB = p3;
    _lineA = l1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHCircle* c = [[DHCircle alloc] initWithCenter:_pointB andPointOnRadius:_lineA.end];
    DHIntersectionPointLineCircle* ip = [[DHIntersectionPointLineCircle alloc] init];
    ip.c = c;
    ip.l = _lineA;
    ip.preferEnd = NO;
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:ip andPoint2:_lineA.end];
    
    DHLineSegment* sPerp = [[DHLineSegment alloc] init];
    sPerp.start = _pointB;
    sPerp.end = mp;
    
    [objects insertObject:sPerp atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _lineA.start.position;
    CGPoint pointB = _lineA.end.position;
    
    _lineA.start.position = CGPointMake(100, 250);
    _lineA.end.position = CGPointMake(600, 400);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _lineA.start.position = pointA;
    _lineA.end.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    BOOL pointOnLineEquidistantOK = NO;
    BOOL pointOnPerpLineOK = NO;
    
    DHPerpendicularLine* pl = [[DHPerpendicularLine alloc] initWithLine:_lineA andPoint:_pointB];
    CGVector vLine = CGVectorNormalize(_lineA.vector);
    CGFloat distAB = DistanceBetweenPoints(_lineA.start.position, _pointB.position);
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if (object == _lineA.start || object == _pointB) continue;
        
        
        if ([object class] == [DHPointOnLine class]) {
            DHPointOnLine* p = object;
            if (PointOnLine(p, _lineA) ) {
                pointOnLineOK = YES;
            }
        }
        if ([[object class]  isSubclassOfClass:[DHPoint class]]) {
            DHPoint* p = object;
            CGFloat distPB = DistanceBetweenPoints(p.position, _pointB.position);
            CGFloat distPLine = DistanceFromPointToLine(p, _lineA);
            if (fabs(distAB-distPB) < 0.001 && distPLine < 0.0001) {
                pointOnLineEquidistantOK = YES;
            }

            CGFloat distPPerpLine = DistanceFromPointToLine(p, pl);
            if (distPPerpLine < 0.0001) {
                pointOnPerpLineOK = YES;
            }
        }
        
        if ([[object class]  isSubclassOfClass:[DHLineObject class]]) {
            DHLineObject* l = object;
            CGFloat distAL = DistanceFromPointToLine(_pointB, l);
            CGFloat lDotLine = CGVectorDotProduct(CGVectorNormalize(l.vector), vLine);
            if (distAL < 0.0001 && fabs(lDotLine) < 0.0001) {
                self.progress = 100;
                return YES;
            }
        }
    }
    
    self.progress = (pointOnLineEquidistantOK + pointOnPerpLineOK*4)/10.0 * 100;
    
    return NO;
}

- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    DHPerpendicularLine* perp = [[DHPerpendicularLine alloc] init];
    perp.line = _lineA;
    perp.point = _pointB;
    
    for (id object in objects){
        
        if (EqualCircles(object,[[DHCircle alloc] initWithCenter:_pointB andPointOnRadius:_pointA]))
            return _pointB.position;
        
        if ([object class]==[DHIntersectionPointLineCircle class] && PointOnLine(object,_lineA))
        {
            DHPoint* p = object;
            return p.position;
        }
        if (PointOnLine(object,perp)){ DHPoint* p = object; return p.position; }
        if (EqualDirection(object,perp) && PointOnLine(_pointB, object))  return _pointB.position;
        
    }
    return CGPointMake(NAN, NAN);
}

- (void)animation:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view {
    
    

    NSMutableArray* geometricObjects2 = [[NSMutableArray alloc]init];
    
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:320 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:300];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:400 andY:200];
    DHLineSegment* l1 = [[DHLineSegment alloc] initWithStart:p1 andEnd:p2];
    DHCircle* c = [[DHCircle alloc] initWithCenter:p3 andPointOnRadius:l1.end];
    DHIntersectionPointLineCircle* ip = [[DHIntersectionPointLineCircle alloc] init];
    ip.c = c;
    ip.l = l1;
    ip.preferEnd = NO;
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:ip andPoint2:l1.end];
    DHLineSegment* sPerp = [[DHLineSegment alloc] init];
    sPerp.start = p3;
    sPerp.end = mp;
    [geometricObjects2 addObject:l1];
    [geometricObjects2 insertObject:sPerp atIndex:0];

    CGFloat steps = 100;
    CGPoint dA = PointFromToWithSteps(_pointB.position, p3.position, steps);
    
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
        CGPoint oldPointA = _pointB.position;
        _pointB.position = p3.position;
        [geometryView centerContent];
        newOffset = geometryView.geoViewTransform.offset;
        [geometryView.geoViewTransform setOffset:oldOffset];
        [geometryView.geoViewTransform setScale:oldScale];
        _pointB.position = oldPointA;
    }
    
    CGPoint offset = PointFromToWithSteps(oldOffset, newOffset, 100);
    CGFloat scale =  pow((newScale/oldScale),0.01) ;
    
    
    for (int a=0; a<steps; a++) {
        [self performBlock:^{
            [geometryView.geoViewTransform offsetWithVector:CGPointMake(offset.x, offset.y)];
            [geometryView.geoViewTransform setScale:geometryView.geoViewTransform.scale *scale];
            _pointB.position = CGPointMake(_pointB.position.x + dA.x,_pointB.position.y + dA.y);
            
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
        geoView.geometricObjects = geometricObjects2;
        //adjust points to new coordinates

        
        CGPoint relPos = [geoView.superview convertPoint:geoView.frame.origin toView:geometryView];
        p1.position = CGPointMake(p1.position.x + newOffset.x, p1.position.y - relPos.y + newOffset.y );
        p2.position = CGPointMake(p2.position.x +newOffset.x  , p2.position.y - relPos.y +newOffset.y );
        p3.position = CGPointMake(p3.position.x +newOffset.x  , p3.position.y - relPos.y +newOffset.y );

        [geoView setNeedsDisplay];
        
        //getcoordinates of Equilateral triangle tool
        UIView* segment5 = [toolControl.subviews objectAtIndex:2];
        UIView* segment6 = [toolControl.subviews objectAtIndex:3];
        CGPoint pos5 = [segment5.superview convertPoint:segment5.frame.origin toView:geoView];
        CGPoint pos6 = [segment6.superview convertPoint:segment6.frame.origin toView:geoView];
        
        CGFloat xpos = (pos5.x + pos6.x )/2 -4 ;
        CGFloat ypos =  view.frame.size.height +7;
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if(UIInterfaceOrientationIsLandscape(orientation)) {
            ypos = ypos - 36;
            xpos = xpos + 4;
        }
        
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.keyPath = @"position";
        animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(geoView.layer.position.x, geoView.layer.position.y)];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(xpos, ypos)];
        animation.duration = 3;
        
        CABasicAnimation *animation2 = [CABasicAnimation animation];
        animation2.keyPath = @"transform.scale";
        animation2.fromValue = [NSNumber numberWithFloat:1];
        animation2.toValue = [NSNumber numberWithFloat:0.17];
        animation2.duration = 3;
        
        [geoView.layer addAnimation:animation forKey:@"basic1"];
        [geoView.layer addAnimation:animation2 forKey:@"basic2"];
        geoView.layer.position = CGPointMake(xpos, ypos);
        
        geoView.transform = CGAffineTransformMakeScale(0.17, 0.17);
        
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
             [toolControl setEnabled:YES forSegmentAtIndex:8];
         }
         completion:^(BOOL finished){
             [geoView removeFromSuperview];
         }];
    } afterDelay:1.0];
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
    hintView.backgroundColor = [UIColor whiteColor];
    hintView.layer.opacity = 0;
    hintView.hideBottomBorder = YES;
    [geometryView addSubview:hintView];
    [self fadeInViews:@[hintView] withDuration:1.0];
    
    [self afterDelay:1.0 :^{
        if (!self.showingHint) return;
        hintView.frame = geometryView.frame;
        
        CGFloat centerX = [geometryView.geoViewTransform viewToGeo:geometryView.center].x;
        
        DHPoint* p1 = [[DHPoint alloc] initWithPositionX:centerX-50 andY:300];
        DHPoint* p2 = [[DHPoint alloc] initWithPositionX:centerX+50 andY:300];
        DHPoint* p3 = [[DHPoint alloc] initWithPositionX:centerX andY:100];
        
        DHLineSegment* s12 = [[DHLineSegment alloc] initWithStart:p1 andEnd:p2];
        DHLineSegment* s13 = [[DHLineSegment alloc] initWithStart:p1 andEnd:p3];
        DHLineSegment* s23 = [[DHLineSegment alloc] initWithStart:p2 andEnd:p3];
        s12.temporary = s13.temporary = s23.temporary = YES;
        
        DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:p1 andPoint2:p2];
        DHLineSegment* s3MP = [[DHLineSegment alloc] initWithStart:p3 andEnd:mp];
        DHLineSegment* s12H = [[DHLineSegment alloc] initWithStart:p1 andEnd:p2];
        mp.temporary = YES;
        s3MP.highlighted = YES;
        s12H.highlighted = YES;
        DHAngleIndicator* a1 = [[DHAngleIndicator alloc] initWithLine1:s12H line2:s3MP andRadius:15];
        a1.squareRightAngles = YES;
        a1.anglePosition = 1;
        
        DHGeometryView* triView = [[DHGeometryView alloc] initWithObjects:@[s12, s13, s23]
                                                                  supView:geometryView addTo:hintView];
        DHGeometryView* perpView = [[DHGeometryView alloc] initWithObjects:@[a1, s3MP, s12H, mp]
                                                                  supView:geometryView addTo:hintView];
        
        Message* message1 = [self createMiddleMessageWithSuperView:hintView];
        
        [self afterDelay:0.0:^{
            [message1 text:@"For an isosceles triangle (with two equal sides) it can be proved"];
            [self fadeInViews:@[message1, triView] withDuration:3.0];
        }];
        
        [self afterDelay:3.0 :^{
            [message1 appendLine:(@"that a line from the tip to the midpoint of its base")
                    withDuration:2.0];
            [self fadeInViews:@[perpView] withDuration:3.0];
        }];
        
        [self afterDelay:7.0 :^{
            [message1 appendLine:(@"will always be perpendicular to the base.")
                    withDuration:2.0];

            [self movePoint:p1 toPosition:CGPointMake(p1.position.x-100, p1.position.y)
               withDuration:4.0 inViews:@[triView, perpView]];
            [self movePoint:p2 toPosition:CGPointMake(p2.position.x+100, p2.position.y)
               withDuration:4.0 inViews:@[triView, perpView]];
        }];
        
        [self afterDelay:2.0 :^{
            [self showEndHintMessageInView:hintView];
        }];
        
    }];
}

@end
