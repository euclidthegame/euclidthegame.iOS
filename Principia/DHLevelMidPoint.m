//
//  DHLevel3.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelMidPoint.h"
#import <CoreGraphics/CGBase.h>
#import "DHGeometricObjects.h"

@interface DHLevelMidPoint () {
    DHLineSegment* _initialLine;
    DHPoint* _pointA;
    DHPoint* _pointB;
    Message* _message1, *_message2, *_message3, *_message4;
    BOOL _step1finished;
    BOOL pointOnMidLineOK;
    BOOL secondPontOnMidLineOK;
}

@end

@implementation DHLevelMidPoint

- (NSString*)subTitle
{
    return @"Half 'n Half";
}

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
    return @"Well done ! You unlocked a new tool: Constructing a midpoint!";
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
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:300];
    DHLineSegment* l1 = [[DHLineSegment alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    
    _initialLine = l1;
    _pointA = p1;
    _pointB = p2;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHMidPoint* mid = [[DHMidPoint alloc] init];
    mid.start = _initialLine.start;
    mid.end = _initialLine.end;
    [objects addObject:mid];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _initialLine.start.position;
    CGPoint pointB = _initialLine.end.position;
    
    _initialLine.start.position = CGPointMake(100, 100);
    _initialLine.end.position = CGPointMake(400, 400);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _initialLine.start.position = pointA;
    _initialLine.end.position = pointB;
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
    self.progress =0 ;
    
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:_initialLine.start andPoint2:_initialLine.end];
    DHPerpendicularLine* midLine = [[DHPerpendicularLine alloc] initWithLine:_initialLine andPoint:mp];
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class] isSubclassOfClass:[DHPoint class]] == NO) continue;
        if (object == _initialLine.start || object == _initialLine.end) continue;
        
        if (EqualPoints(object,mp)) {
            midPointOK = YES;
        }
        DHPoint* p = object;
        if (DistanceFromPointToLine(p, midLine) < 0.0001) {
            if (!pointOnMidLineOK) {
                pointOnMidLineOK = YES;
                [UIView animateWithDuration:2.0 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                    _message3.alpha = 0;
                } completion:nil];
            } else {
                secondPontOnMidLineOK = YES;
                [UIView animateWithDuration:2.0 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                    _message4.alpha = 0;  } completion:nil];
            }
        }
    }
    
    //self.progress = (pointOnMidLineOK + secondPontOnMidLineOK + midPointOK)/3.0 * 100;
    if (midPointOK) {
        self.progress = 100;
        return YES;
    }
    
    return NO;
}

- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{

DHCircle* cAB = [[DHCircle alloc] initWithCenter:_initialLine.start andPointOnRadius:_initialLine.end];
DHCircle* cBA = [[DHCircle alloc] initWithCenter:_initialLine.end andPointOnRadius:_initialLine.start];
DHTrianglePoint* pTop = [[DHTrianglePoint alloc] initWithPoint1:_initialLine.start andPoint2:_initialLine.end];
DHTrianglePoint* pBottom = [[DHTrianglePoint alloc] initWithPoint1:_initialLine.end andPoint2:_initialLine.start];
DHLineSegment* segment = [[DHLineSegment alloc]initWithStart:pBottom andEnd:pTop];
DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:_initialLine.start andPoint2:_initialLine.end];

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
    _initialLine = l1;
    DHMidPoint* mid = [[DHMidPoint alloc] init];
    mid.start = _initialLine.start;
    mid.end = _initialLine.end;
    
    CGFloat steps = 100;
    CGPoint dA = PointFromToWithSteps(_pointA.position, p1.position, steps);
    CGPoint dB = PointFromToWithSteps(_pointB.position, p2.position, steps);
    
    CGPoint oldOffset = geometryView.geoViewTransform.offset;
    CGFloat oldScale = geometryView.geoViewTransform.scale;
    CGFloat newScale = 1;
    CGPoint newOffset = CGPointMake(0,0);
    
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
        
        
        //adjust points to new coordinates
        
        CGPoint relPos = [geoView.superview convertPoint:geoView.frame.origin toView:geometryView];
        p1.position = CGPointMake(p1.position.x + newOffset.x, p1.position.y - relPos.y + newOffset.y );
        p2.position = CGPointMake(p2.position.x +newOffset.x  , p2.position.y - relPos.y +newOffset.y );

        [geoView setNeedsDisplay];
        
        //getcoordinates of Equilateral triangle tool
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
- (void)hint:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view and:(NSLayoutConstraint*)heightToolBar and:(UIButton*)hintButton{
    
    if ([hintButton.titleLabel.text  isEqual: @"Hide hint"]) {
        [hintButton setTitle:@"Show hint" forState:UIControlStateNormal];
        [geometryView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        return;
    }
    
    if (pointOnMidLineOK && secondPontOnMidLineOK) {
        Message* message0 = [[Message alloc] initWithMessage:@"No more hints available." andPoint:CGPointMake(150,150)];
        [geometryView addSubview:message0];
        [self fadeIn:message0 withDuration:1.0];
        [self afterDelay:4.0 :^{[self fadeOut:message0 withDuration:1.0];}];
        return;
    }
    
    [hintButton setTitle:@"Hide hint" forState:UIControlStateNormal];
    UIView* hintView = [[UIView alloc]initWithFrame:CGRectMake(0,0,0,0)];
    [geometryView addSubview:hintView];
    _message1 = [[Message alloc] initAtPoint:CGPointMake(150,720) addTo:hintView];
    _message2 = [[Message alloc] initAtPoint:CGPointMake(150,740) addTo:hintView];
    _message3 = [[Message alloc] initAtPoint:CGPointMake(150,760) addTo:hintView];
    _message4 = [[Message alloc] initAtPoint:CGPointMake(150,780) addTo:hintView];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        [_message1 position: CGPointMake(150,480)];
        [_message2 position: CGPointMake(150,500)];
        [_message3 position: CGPointMake(150,520)];
        [_message4 position: CGPointMake(150,540)];
    }
    
    [_message1 text:@"You have just unlocked the equilateral triangle tool."];
    [self fadeIn:_message1 withDuration:2.0];
    
    [self afterDelay:3.0 :^{
        _step1finished =YES;
        [_message2 text:@"Tap on it to select it." ];
        [UIView animateWithDuration:2.0 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
            _message2.alpha = 1; } completion:nil];
    }];
    
    UIView* toolSegment = [toolControl.subviews objectAtIndex:11-5];
    UIView* tool = [toolSegment.subviews objectAtIndex:0];
    
    for (int a=0; a < 100; a++) {
        [self performBlock:
         ^{
             if (toolControl.selectedSegmentIndex == 5 && _step1finished){
                 _step1finished = NO;
                 [_message3 text:@"If the triangle tool is selected, you can use it by tapping on two points."];
                 [_message4 text:@"Note that it matters which point you tap first!"];
                 [UIView animateWithDuration:2.0 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                     _message1.alpha = 0;
                     _message2.alpha = 0;

                     _message3.alpha = 1;
                     _message4.alpha = 1;
                 } completion:nil];
             }
             else if (toolControl.selectedSegmentIndex !=5 && _step1finished){
                 [UIView animateWithDuration:0.5 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:
                  ^{tool.alpha = 0; } completion:^(BOOL finished){
                      [UIView animateWithDuration:0.5 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:
                       ^{tool.alpha = 1; } completion:nil];}];
             }
         } afterDelay:a];
    }
}
@end
