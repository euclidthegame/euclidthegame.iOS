//
//  DHLevel5.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-02.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelBisect.h"

#import <CoreGraphics/CGBase.h>
#import "DHGeometricObjects.h"

@interface DHLevelBisect () {
    DHRay* _lineAB;
    DHRay* _lineAC;
    DHPoint* _pointA;
    BOOL _dontrepeat;
    BOOL pointOnLineOK;
    Message* _message1, *_message2, *_message3, *_message4;
    BOOL _step1finished;
}
@end

@implementation DHLevelBisect

- (NSString*)subTitle
{
    return @"Bisecting an angle";
}

- (NSString*)levelDescription
{
    return @"Construct an angle bisector of the given angle.";
}


- (NSString*)levelDescriptionExtra
{
    return (@"Construct an angle bisector of the given angle. \n \nAn angle bisector is a line or a line segment that divides an angle into two equal angles. ");
}

- (NSString *)additionalCompletionMessage
{
    return @"Well done ! You unlocked a new tool: Constructing a bisector!";
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 3;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 4;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:300 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:500 andY:300];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:450 andY:170];
    
    DHRay* l1 = [[DHRay alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    DHRay* l2 = [[DHRay alloc] init];
    l2.start = p1;
    l2.end = p3;
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:l2];
    [geometricObjects addObject:p1];
    //[geometricObjects addObject:p2];
    //[geometricObjects addObject:p3];
    
    _pointA = p1;
    _lineAB = l1;
    _lineAC = l2;
    
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHCircle* cAC = [[DHCircle alloc] initWithCenter:_lineAC.start andPointOnRadius:_lineAC.end];
    DHIntersectionPointLineCircle* ip = [[DHIntersectionPointLineCircle alloc] init];
    ip.c = cAC;
    ip.l = _lineAB;
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:_lineAC.end andPoint2:ip];
    DHRay* rayBisector = [[DHRay alloc] initWithStart:_lineAB.start andEnd:mp];
    [objects insertObject:rayBisector atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointB = _lineAB.end.position;
    CGPoint pointC = _lineAC.end.position;
    
    _lineAB.end.position = CGPointMake(600, 400);
    _lineAC.end.position = CGPointMake(450, 100);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _lineAB.end.position = pointB;
    _lineAC.end.position = pointC;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    BOOL circleOK = NO;
    BOOL intersectionPointOK = NO;
    BOOL midPointOK = NO;
    BOOL bisectOK = NO;
    pointOnLineOK = NO;
    DHBisectLine* b = [[DHBisectLine alloc] init];
    b.line1 = _lineAB;
    b.line2 = _lineAC;
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if (object == _lineAB || object == _lineAC) continue;
        
        if ([object class] == [DHCircle class])
        {
            DHCircle* c = object;
            if (EqualPoints(c.center,_lineAB.start)) circleOK = YES;
        }
        if ([object class] == [DHIntersectionPointLineCircle class])
        {
            DHPoint* p = object;
            if (PointOnLine(p,_lineAB) || PointOnLine(object,_lineAC)) intersectionPointOK = YES;
        }
        if ([object class] == [DHPointOnLine class]){
            pointOnLineOK = YES;
        [UIView animateWithDuration:2.0 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
            _message4.alpha = 0;  } completion:nil];
        }
    
        if (!EqualPoints(object,_pointA) && PointOnLine(object,b)) midPointOK = YES;
        if (EqualDirection(b,object))
        {
            DHLineObject * l = object;
            if (PointOnLine(_lineAB.start, l)) {
                bisectOK = YES;
                self.progress = 100;
                return YES;
            }
        }
    }
    self.progress = ( midPointOK + bisectOK)/2.0 * 100;
    
    return NO;
}

- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    DHBisectLine* b = [[DHBisectLine alloc] init];
    b.line1 = _lineAB;
    b.line2 = _lineAC;
    
    for (id object in objects){
        
        if ([object class] == [DHCircle class])
        {
            DHCircle* c = object;
            if (EqualPoints(c.center,_lineAB.start)) return c.center.position;
        }
        if ([object class] == [DHIntersectionPointLineCircle class] && !_dontrepeat)
        {
            _dontrepeat = YES;
            DHPoint* p = object;
            if (PointOnLine(p,_lineAB) || PointOnLine(object,_lineAC)) return p.position;
        }
        if (PointOnLine(object,b))
        {
            DHPoint* p = object;
            return p.position;
        }
        if (EqualDirection(b,object))
        {
            DHLineObject * l = object;
            if (PointOnLine(_lineAB.start, l)) return l.end.position;
        }
        
    }
    return CGPointMake(NAN, NAN);
}
- (void)animation:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view {
   
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:300 andY:300];
    
    CGFloat steps = 100;
    CGPoint dA = PointFromToWithSteps(_pointA.position, p1.position, steps);
    
    CGPoint oldOffset = geometryView.geoViewTransform.offset;
    CGFloat oldScale = geometryView.geoViewTransform.scale;
    CGFloat newScale = 1;
    CGPoint newOffset = CGPointMake(0,0);
    
    if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        [geometryView.geoViewTransform setScale:newScale];
        CGPoint oldPointA = _pointA.position;
        _pointA.position = p1.position;
        [geometryView centerContent];
        newOffset = geometryView.geoViewTransform.offset;
        [geometryView.geoViewTransform setOffset:oldOffset];
        [geometryView.geoViewTransform setScale:oldScale];
        _pointA.position = oldPointA;
    }
    
    CGPoint offset = PointFromToWithSteps(oldOffset, newOffset, 100);
    CGFloat scale =  pow((newScale/oldScale),0.01) ;
    
    
    for (int a=0; a<steps; a++) {
        [self performBlock:^{
            [geometryView.geoViewTransform offsetWithVector:CGPointMake(offset.x, offset.y)];
            [geometryView.geoViewTransform setScale:geometryView.geoViewTransform.scale *scale];
            _pointA.position = CGPointMake(_pointA.position.x + dA.x,_pointA.position.y + dA.y);
               
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
        
        DHPoint* p1 = [[DHPoint alloc] initWithPositionX:300 andY:300];
        DHPoint* p2 = [[DHPoint alloc] initWithPositionX:500 andY:300];
        DHPoint* p3 = [[DHPoint alloc] initWithPositionX:450 andY:170];
        
        CGPoint relPos = [geoView.superview convertPoint:geoView.frame.origin toView:geometryView];
        p1.position = CGPointMake(p1.position.x + newOffset.x, p1.position.y - relPos.y + newOffset.y );
        p2.position = CGPointMake(p2.position.x +newOffset.x  , p2.position.y - relPos.y +newOffset.y );
        p3.position = CGPointMake(p3.position.x +newOffset.x  , p3.position.y - relPos.y +newOffset.y );
        
        DHLineSegment* l1 = [[DHLineSegment alloc] init];
        l1.start = p1;
        l1.end = p2;
        
        DHLineSegment* l2 = [[DHLineSegment alloc] init];
        l2.start = p1;
        l2.end = p3;
        NSMutableArray* geometricObjects2 = [[NSMutableArray alloc]init];
        [geometricObjects2 addObject:l1];
        [geometricObjects2 addObject:l2];
        [geometricObjects2 addObject:p1];
        

        DHCircle* cAC = [[DHCircle alloc] initWithCenter:l2.start andPointOnRadius:l2.end];
        DHIntersectionPointLineCircle* ip = [[DHIntersectionPointLineCircle alloc] init];
        ip.c = cAC;
        ip.l = l1;
        DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:l2.end andPoint2:ip];
        DHLineSegment* rayBisector = [[DHLineSegment alloc] initWithStart:l1.start andEnd:mp];
        [geometricObjects2 insertObject:rayBisector atIndex:0];
        geoView.geometricObjects = geometricObjects2;
        //adjust points to new coordinates
        [geoView setNeedsDisplay];
        
        //getcoordinates of Equilateral triangle tool
        UIView* segment5 = [toolControl.subviews objectAtIndex:3];
        UIView* segment6 = [toolControl.subviews objectAtIndex:4];
        CGPoint pos5 = [segment5.superview convertPoint:segment5.frame.origin toView:geoView];
        CGPoint pos6 = [segment6.superview convertPoint:segment6.frame.origin toView:geoView];
        
        CGFloat xpos = (pos5.x + pos6.x )/2 -2 ;
        CGFloat ypos =  view.frame.size.height +3;
        
        if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            ypos = ypos - 19;
            xpos = xpos -11;
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
             [toolControl setEnabled:YES forSegmentAtIndex:7];
         }
         completion:^(BOOL finished){
             [geoView removeFromSuperview];
         }];
    } afterDelay:1.0];
}


- (void)hint:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view and:(NSLayoutConstraint*)heightToolBar and:(UIButton*)hintButton{
    
    if ([hintButton.titleLabel.text  isEqual: @"Hide hint"]) {
        [hintButton setTitle:@"Show hint" forState:UIControlStateNormal];
        [geometryView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        return;
    }
    
    if (pointOnLineOK) return;
    
    [hintButton setTitle:@"Hide hint" forState:UIControlStateNormal];
    
    _message1 = [[Message alloc] initWithMessage:@"There is only one point given." andPoint:CGPointMake(20,720)];
    _message2 = [[Message alloc] initWithMessage:@"But most tools in the toolbar require at least 2 points! " andPoint:CGPointMake(20,740)];
    _message3 = [[Message alloc] initWithMessage:@"A second point can be constructed using the point tool. Tap on it to select it." andPoint:CGPointMake(20,760)];
    _message4 = [[Message alloc] initWithMessage:@"Good ! Let's start with constructing a point. For example, on one of the given lines." andPoint:CGPointMake(20,780)];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        [_message1 position: CGPointMake(20,480)];
        [_message2 position: CGPointMake(20,500)];
        [_message3 position: CGPointMake(20,520)];
        [_message4 position: CGPointMake(20,540)];
    }
    
    UIView* hintView = [[UIView alloc]initWithFrame:CGRectMake(0,0,0,0)];
    [geometryView addSubview:hintView];
    [hintView addSubview:_message1];
    [hintView addSubview:_message2];
    [hintView addSubview:_message3];
    [hintView addSubview:_message4];
    
    
    [UIView animateWithDuration:2 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
        _message1.alpha = 1; } completion:nil];
    
    [self performBlock:^{
        [UIView animateWithDuration:2.0 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
            _message2.alpha = 1; } completion:nil];
    } afterDelay:3.0];
    
    [self performBlock:^{
        _step1finished =YES;
        [UIView animateWithDuration:2.0 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
            _message3.alpha = 1; } completion:nil];
    } afterDelay:6.0];
    
    [self performBlock:^{
        _step1finished =YES;
    } afterDelay:10.0];
    
    int segmentindex = 0; //pointtool
    UIView* toolSegment = [toolControl.subviews objectAtIndex:11-segmentindex];
    UIView* tool = [toolSegment.subviews objectAtIndex:0];
    
    for (int a=0; a < 100; a++) {
        [self performBlock:
         ^{
             if (toolControl.selectedSegmentIndex == segmentindex && _step1finished){
                 _step1finished = NO;
                 [UIView animateWithDuration:2.0 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                     _message1.alpha = 0;
                     _message2.alpha = 0;
                     _message3.alpha = 0;
                     _message4.alpha = 1;
                 } completion:nil];
             }
             else if (toolControl.selectedSegmentIndex != segmentindex && _step1finished){
                 [UIView animateWithDuration:0.5 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:
                  ^{tool.alpha = 0; } completion:^(BOOL finished){
                      [UIView animateWithDuration:0.5 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:
                       ^{tool.alpha = 1; } completion:nil];}];
             }
         } afterDelay:a];
    }
}

@end
