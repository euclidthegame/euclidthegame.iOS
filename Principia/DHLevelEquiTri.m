//
//  DHLevel2.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelEquiTri.h"
#import "DHGeometryView.h"
#import "DHLevelViewController.h"

@interface DHLevelEquiTri() {
    DHLineSegment* _lineAB;
    DHPoint* _pointA;
    DHPoint* _pointB;
    BOOL cBA_OK, cAB_OK;
}
@end

@implementation DHLevelEquiTri

- (NSString*)levelDescription
{
    return (@"Construct an equilateral triangle.");
}

- (NSString*)levelDescriptionExtra
{
    return(@"Construct an equilateral triangle such that segment AB is one of its sides. \n\n"
                          @"An equilateral triangle is a triangle whose sides are of equal length.");
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable);
}

- (NSString *)additionalCompletionMessage
{
    return @"Well done! You unlocked a new tool: Constructing equilateral triangles!";
}

- (NSUInteger)minimumNumberOfMoves
{
    return 4;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 4;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:400];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:400];
    DHLineSegment* l1 = [[DHLineSegment alloc] initWithStart:p1 andEnd:p2];
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    
    _pointA = p1;
    _pointB = p2;
    _lineAB = l1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:_lineAB.start andPointOnRadius:_lineAB.end];
    DHCircle* c2 = [[DHCircle alloc] initWithCenter:_lineAB.end andPointOnRadius:_lineAB.start];
    DHIntersectionPointCircleCircle* ip = [[DHIntersectionPointCircleCircle alloc] init];
    ip.c1 = c1;
    ip.c2 = c2;
    ip.onPositiveY = YES;
    [objects addObject:ip];
    
    DHLineSegment* sAC = [[DHLineSegment alloc]initWithStart:_lineAB.start andEnd:ip];
    [objects insertObject:sAC atIndex:0];

    DHLineSegment* sBC = [[DHLineSegment alloc]initWithStart:_lineAB.end andEnd:ip];
    [objects insertObject:sBC atIndex:0];    
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
    // Solution criteria
    BOOL pC_OK = NO;
    BOOL pD_OK = NO;
    BOOL sAC_OK = NO;
    BOOL sBC_OK = NO;
    BOOL sAD_OK = NO;
    BOOL sBD_OK = NO;
    cAB_OK = NO;
    cBA_OK = NO;
    
    DHTrianglePoint* pC = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.start andPoint2:_lineAB.end];
    DHTrianglePoint* pD = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.end andPoint2:_lineAB.start];
    DHLineSegment* sAC = [[DHLineSegment alloc]initWithStart:_lineAB.start andEnd:pC];
    DHLineSegment* sAD = [[DHLineSegment alloc]initWithStart:_lineAB.start andEnd:pD];
    DHLineSegment* sBC = [[DHLineSegment alloc]initWithStart:_lineAB.end andEnd:pC];
    DHLineSegment* sBD = [[DHLineSegment alloc]initWithStart:_lineAB.end andEnd:pD];
    
    DHCircle* cAB = [[DHCircle alloc] initWithCenter:_lineAB.start andPointOnRadius:_lineAB.end];
    DHCircle* cBA = [[DHCircle alloc] initWithCenter:_lineAB.end andPointOnRadius:_lineAB.start];

    for (id object in geometricObjects) {
        if ([object class] == [DHPoint class]) continue;
        if (object == _lineAB) continue;
        
        if (EqualCircles(object, cAB)) cAB_OK = YES;
        if (EqualCircles(object, cBA)) cBA_OK = YES;

        if (LineObjectCoversSegment(object,sAC)) sAC_OK = YES;
        if (LineObjectCoversSegment(object,sAD)) sAD_OK = YES;
        if (LineObjectCoversSegment(object,sBC)) sBC_OK = YES;
        if (LineObjectCoversSegment(object,sBD)) sBD_OK = YES;
        if (EqualPoints(object,pC)) pC_OK = YES;
        if (EqualPoints(object,pD)) pD_OK = YES;
    }
    
    self.progress = ((pC_OK || pD_OK) + (sAC_OK || sAD_OK || sBC_OK || sBD_OK) +
                     ((sAC_OK && sBC_OK) || (sAD_OK && sBD_OK)))/3.0 * 100;
    
    if ((pC_OK && sAC_OK && sBC_OK) || (pD_OK && sAD_OK && sBD_OK)) {
        return YES;
    }
    
    return NO;
}

- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    // Objects to test
    DHCircle* cAB = [[DHCircle alloc] initWithCenter:_lineAB.start andPointOnRadius:_lineAB.end];
    DHCircle* cBA = [[DHCircle alloc] initWithCenter:_lineAB.end andPointOnRadius:_lineAB.start];
    DHTrianglePoint* pTop = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.start andPoint2:_lineAB.end];
    DHTrianglePoint* pBottom = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.end andPoint2:_lineAB.start];
    DHLineSegment* sAC = [[DHLineSegment alloc]initWithStart:_lineAB.start andEnd:pTop];
    DHLineSegment* sAD = [[DHLineSegment alloc]initWithStart:_lineAB.start andEnd:pBottom];
    DHLineSegment* sBC = [[DHLineSegment alloc]initWithStart:_lineAB.end andEnd:pTop];
    DHLineSegment* sBD = [[DHLineSegment alloc]initWithStart:_lineAB.end andEnd:pBottom];
    
    for (id object in objects){
        if (EqualCircles(object,cAB)) return cAB.center.position;
        if (EqualCircles(object, cBA)) return cBA.center.position;
        if (EqualPoints(object, pTop)) return pTop.position;
        if (EqualPoints(object,pBottom)) return  pBottom.position;
        if (LineObjectCoversSegment(object,sAC)) return MidPointFromPoints(sAC.start.position,sAC.end.position);
        if (LineObjectCoversSegment(object,sAD)) return  MidPointFromPoints(sAD.start.position,sAD.end.position);
        if (LineObjectCoversSegment(object,sBD)) return  MidPointFromPoints(sBD.start.position,sBD.end.position);
        if (LineObjectCoversSegment(object,sBC)) return  MidPointFromPoints(sBC.start.position,sBC.end.position);
        
    }
    return CGPointMake(NAN, NAN);
}

- (void)animation:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view {
    
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:400 ];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:400 ];
    DHLineSegment* l1 = [[DHLineSegment alloc] initWithStart:p1 andEnd:p2];
    _lineAB = l1;
    
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:_lineAB.start andPointOnRadius:_lineAB.end];
    DHCircle* c2 = [[DHCircle alloc] initWithCenter:_lineAB.end andPointOnRadius:_lineAB.start];
    DHIntersectionPointCircleCircle* ip = [[DHIntersectionPointCircleCircle alloc] init];
    ip.c1 = c1;
    ip.c2 = c2;
    ip.onPositiveY = YES;
    
    DHLineSegment* sAC = [[DHLineSegment alloc] initWithStart:_lineAB.start andEnd:ip];
    DHLineSegment* sBC = [[DHLineSegment alloc] initWithStart:_lineAB.end andEnd:ip];
    
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
            _pointA.position = CGPointMake(_pointA.position.x + dA.x, _pointA.position.y + dA.y);
            _pointB.position = CGPointMake(_pointB.position.x + dB.x, _pointB.position.y + dB.y);

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
        if (self.iPhoneVersion) {
            [geoView.geoViewTransform setScale:0.5];
            [geoView.geoViewTransform setOffset:CGPointMake(-30, 0)];
        }
        
        NSMutableArray* geometricObjects2 = [[NSMutableArray alloc]init];
        [geometricObjects2 addObject:l1];
        [geometricObjects2 addObject:p1];
        [geometricObjects2 addObject:p2];
        [geometricObjects2 addObject:ip];
        [geometricObjects2 insertObject:sAC atIndex:0];
        [geometricObjects2 insertObject:sBC atIndex:0];
        geoView.geometricObjects = geometricObjects2;
        
        //adjust points to new coordinates
        
        CGPoint relPos = [geoView.superview convertPoint:geoView.frame.origin toView:geometryView];
        p1.position = CGPointMake(p1.position.x + newOffset.x, p1.position.y - relPos.y + newOffset.y );
        p2.position = CGPointMake(p2.position.x +newOffset.x  , p2.position.y - relPos.y +newOffset.y );
        [geoView setNeedsDisplay];
        
        //getcoordinates of Equilateral triangle tool
        UIView* segment5 = [toolControl.subviews objectAtIndex:5];
        UIView* segment6 = [toolControl.subviews objectAtIndex:6];
        CGPoint pos5 = [segment5.superview convertPoint:segment5.frame.origin toView:geoView];
        CGPoint pos6 = [segment6.superview convertPoint:segment6.frame.origin toView:geoView];
        
        CGFloat xpos = (pos5.x + pos6.x )/2  ;
        CGFloat ypos = view.frame.size.height - 10;
        
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.keyPath = @"position";
        animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(geoView.layer.position.x, geoView.layer.position.y)];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(xpos, ypos)];
        animation.duration = 3;
        
        CABasicAnimation *animation2 = [CABasicAnimation animation];
        animation2.keyPath = @"transform.scale";
        animation2.fromValue = [NSNumber numberWithFloat:1];
        animation2.toValue = [NSNumber numberWithFloat:0.17f];
        animation2.duration = 3;
        
        [geoView.layer addAnimation:animation forKey:@"basic1"];
        [geoView.layer addAnimation:animation2 forKey:@"basic2"];
        
        geoView.transform = CGAffineTransformMakeScale(0.17, 0.17);
        geoView.layer.position = CGPointMake(xpos, ypos);
        
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
             [toolControl setEnabled:YES forSegmentAtIndex:5];
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
    
    [self afterDelay:1.0 :^{
        if (!self.showingHint) return;
        
        UIView* hintView = [[UIView alloc]initWithFrame:geometryView.frame];
        hintView.backgroundColor = [UIColor whiteColor];
        
        DHGeometryView* oldObjects = [[DHGeometryView alloc] initWithObjects:geometryView.geometricObjects
                                                                     supView:geometryView addTo:hintView];
        oldObjects.hideBorder = NO;
        [oldObjects.layer setValue:[NSNumber numberWithFloat:1.0] forKeyPath:@"opacity"];
        
        [geometryView addSubview:hintView];
        
        Message* message1 = [self createUpperMessageWithSuperView:hintView];
        
        DHCircle* c1 = [[DHCircle alloc] initWithCenter:_lineAB.start andPointOnRadius:_lineAB.end];
        c1.temporary = YES;
        
        DHPointOnCircle* pC = [[DHPointOnCircle alloc] initWithCircle:c1 andAngle:- M_PI * 0.10];
        pC.label = @"C";
        
        DHLineSegment* segmentAC = [[DHLineSegment alloc] initWithStart:c1.center andEnd:pC];
        segmentAC.temporary = YES;
        
        // If only left circle already constructed, construct the other one
        if (cAB_OK && !cBA_OK) {
            c1 = [c1 initWithCenter:_lineAB.end andPointOnRadius:_lineAB.start];
            pC = [pC initWithCircle:c1 andAngle:M_PI * 0.10 + M_PI];
            segmentAC = [segmentAC initWithStart:c1.center andEnd:pC];
        }
        // If both circles already constructed, simply show points and skip the circles
        BOOL hideCircle = NO;
        if (cAB_OK && cBA_OK) {
            hideCircle = YES;
        }
        
        [hintView addSubview:oldObjects];
        DHGeometryView* circleView = [[DHGeometryView alloc] initWithObjects:@[c1]
                                                                     supView:geometryView addTo:hintView];
        DHGeometryView* lineACView = [[DHGeometryView alloc] initWithObjects:@[segmentAC]
                                                                     supView:geometryView addTo:hintView];
        DHGeometryView* pointCView = [[DHGeometryView alloc] initWithObjects:@[pC]
                                                                     supView:geometryView addTo:hintView];
        
        [hintView bringSubviewToFront:message1];
        
        [self afterDelay:0.0:^{
            [message1 text:@"Circles have a very useful property."];
            if (hideCircle) {
                [self fadeInViews:@[message1] withDuration:2.0];
            } else {
                [self fadeInViews:@[message1,circleView] withDuration:2.0];
            }
        }];
        
        [self afterDelay:4.0 :^{
            [message1 appendLine:@"Every point on the circle has the same distance to its center."
                    withDuration:2.0];
            [self fadeInViews:@[pointCView] withDuration:2.0];
        }];
        
        [self afterDelay:8.0 :^{
            [message1 appendLine:@"Hence, segment AC has the same length as AB."
                    withDuration:2.0];
            [self fadeInViews:@[lineACView] withDuration:2.0];
        }];
        
        [self afterDelay:12.0 :^{
            [message1 appendLine:@"For any point C on the circle."
                    withDuration:2.0];
            if (cAB_OK && !cBA_OK) {
                [self movePointOnCircle:pC toAngle:3.333*M_PI withDuration:6.0 inViews:@[pointCView,lineACView]];
            } else {
                [self movePointOnCircle:pC toAngle:2.3333*-M_PI withDuration:6.0 inViews:@[pointCView,lineACView]];
            }
        }];

        [self afterDelay:2.0 :^{
            [self showEndHintMessageInView:hintView];
        }];
    
    }];
}

@end


