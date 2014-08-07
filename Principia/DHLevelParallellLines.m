//
//  DHLevelParallellLines.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-04.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelParallellLines.h"

#import "DHGeometricObjects.h"

@interface DHLevelParallellLines () {
    DHPoint* _pointA;
    DHLine* _givenLine;
    Message* _message1, *_message2, *_message3;
    BOOL _step1finished;
    BOOL perpendicularLineOK ;
}

@end

@implementation DHLevelParallellLines

- (NSString*)subTitle
{
    return @"Parallell";
}

- (NSString*)levelDescription
{
    return @"Construct a line through point A parallell to the given line.";
}

- (NSString*)levelDescriptionExtra
{
    return @"Construct a line through point A parallell to the given line. \n\nParallel lines are lines which do not meet one another in either direction.";
}

- (NSString *)additionalCompletionMessage
{
    return @"You have unlocked a new tool: Constructing parallel lines!";
}

- (NSUInteger)minimumNumberOfMoves
{
    return 2;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 4;
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable_Weak |
            DHBisectToolAvailable | DHPerpendicularToolAvailable);
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:300];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:400 andY:200];
    
    DHLine* l1 = [[DHLine alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    [geometricObjects addObject:l1];
    //[geometricObjects addObject:p1];
    //[geometricObjects addObject:p2];
    [geometricObjects addObject:p3];
    
    _pointA = p3;
    _givenLine = l1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHParallelLine* l = [[DHParallelLine alloc] init];
    l.line = _givenLine;
    l.point = _pointA;
    
    [objects insertObject:l atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _givenLine.start.position;
    CGPoint pointB = _givenLine.end.position;
    
    _givenLine.start.position = CGPointMake(280, 310);
    _givenLine.end.position = CGPointMake(480, 320);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _givenLine.start.position = pointA;
    _givenLine.end.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    perpendicularLineOK = NO;
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class]  isSubclassOfClass:[DHLineObject class]] == NO) continue;
        
        DHLineObject* l = object;
        
        if (l.tMin < 0 && l.tMax > 1 && LinesPerpendicular(l, _givenLine)) {
            [UIView animateWithDuration:2.0 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                _message3.alpha = 0;  } completion:nil];
            perpendicularLineOK = YES;
        }
        
        CGVector bc = CGVectorNormalize(_givenLine.vector);
        
        CGFloat lDotBC = CGVectorDotProduct(CGVectorNormalize(l.vector), bc);
        if (!(fabs(lDotBC) > 1 - 0.001)) continue;
        
        CGFloat dist = DistanceFromPointToLine(_pointA, l);
        if (dist < 0.01) {
            self.progress = 100;
            return YES;
        }
    }
    
    self.progress = (perpendicularLineOK)/2.0 * 100;
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    DHPerpendicularLine* perp1 = [[DHPerpendicularLine alloc] initWithLine:_givenLine andPoint:_pointA];
    DHPerpendicularLine* perp2 = [[DHPerpendicularLine alloc] initWithLine:perp1 andPoint:_pointA];
    
    for (id object in objects){
        if (EqualDirection(object,perp1))  {

            return _pointA.position;
        }
        if (EqualDirection(object,perp2))  return _pointA.position;
    }
    return CGPointMake(NAN, NAN);
}
- (void)animation:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view {
    
    
    NSMutableArray* geometricObjects2 = [[NSMutableArray alloc]init];
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:300];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:400 andY:200];

    
    DHLineSegment* l1 = [[DHLineSegment alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    [geometricObjects2 addObject:l1];
    //[geometricObjects addObject:p2];
    [geometricObjects2 addObject:p3];
    
    DHParallelLine* l = [[DHParallelLine alloc] init];
    l.line = l1;
    l.point = p3;
    DHPointOnLine *p4 = [[DHPointOnLine alloc] initWithLine:l andTValue:-100];
    DHPointOnLine *p5 = [[DHPointOnLine alloc] initWithLine:l andTValue:100];
    
    DHLineSegment *l2 = [[DHLineSegment alloc] initWithStart:p4 andEnd:p5];
    [geometricObjects2 insertObject:l2 atIndex:0];
    
    CGFloat steps = 100;
    CGPoint dA = PointFromToWithSteps(_pointA.position, p3.position, steps);
    
    CGPoint oldOffset = geometryView.geoViewTransform.offset;
    CGFloat oldScale = geometryView.geoViewTransform.scale;
    CGFloat newScale = 1;
    CGPoint newOffset = CGPointMake(0,0);
    
    if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        [geometryView.geoViewTransform setScale:newScale];
        CGPoint oldPointA = _pointA.position;
        _pointA.position = p3.position;
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
        geoView.geometricObjects = geometricObjects2;
        //adjust points to new coordinates
        
        
        CGPoint relPos = [geoView.superview convertPoint:geoView.frame.origin toView:geometryView];
        p1.position = CGPointMake(p1.position.x + newOffset.x, p1.position.y - relPos.y + newOffset.y );
        p2.position = CGPointMake(p2.position.x +newOffset.x  , p2.position.y - relPos.y +newOffset.y );
        p3.position = CGPointMake(p3.position.x +newOffset.x  , p3.position.y - relPos.y +newOffset.y );
        
        [geoView setNeedsDisplay];
        
        //getcoordinates of Equilateral triangle tool
        UIView* segment5 = [toolControl.subviews objectAtIndex:1];
        UIView* segment6 = [toolControl.subviews objectAtIndex:2];
        CGPoint pos5 = [segment5.superview convertPoint:segment5.frame.origin toView:geoView];
        CGPoint pos6 = [segment6.superview convertPoint:segment6.frame.origin toView:geoView];
        
        CGFloat xpos = (pos5.x + pos6.x )/2 -33 ;
        CGFloat ypos =  view.frame.size.height - 50;
        
        if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            ypos = ypos +10;
            xpos = xpos +35;
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
        
        CABasicAnimation *animation3 = [CABasicAnimation animation];
        animation3.keyPath = @"transform.rotation";
        animation3.fromValue = [NSNumber numberWithFloat:0];
        animation3.toValue = [NSNumber numberWithFloat:2.1];
        animation3.duration = 3;
        animation3.removedOnCompletion = NO;
        
        [geoView.layer addAnimation:animation forKey:@"basic1"];
        [geoView.layer addAnimation:animation2 forKey:@"basic2"];
        [geoView.layer addAnimation:animation3 forKey:@"basic3"];
        
        geoView.layer.position = CGPointMake(xpos, ypos);
        geoView.transform = CGAffineTransformMakeScale(0.16, 0.16);
        [geoView.layer setValue:[NSNumber numberWithFloat:2.1] forKeyPath:@"transform.rotation"];
        
        
        [self performBlock:^{
            
            CABasicAnimation *animation4 = [CABasicAnimation animation];
            animation4.keyPath = @"opacity";
            animation4.fromValue = [NSNumber numberWithFloat:1];
            animation4.toValue = [NSNumber numberWithFloat:0];
            animation4.duration = 1;
            [geoView.layer addAnimation:animation4 forKey:@"basic4"];
            geoView.alpha = 0;
            
            
        } afterDelay:2.8];
        [UIView
         animateWithDuration:1.0 delay:3 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             [toolControl setEnabled:YES forSegmentAtIndex:9];
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
    
    if (perpendicularLineOK){
        [self showTemporaryMessage:@"No more hints available."  atPoint:CGPointMake(100,50) withColor:[UIColor darkGrayColor] andTime:10.0];
        return;
    }
    
    
    [hintButton setTitle:@"Hide hint" forState:UIControlStateNormal];
    
    _message1 = [[Message alloc] initWithMessage:@"You have just unlocked the perpendicular line tool." andPoint:CGPointMake(150,720)];
    _message2 = [[Message alloc] initWithMessage:@"Tap on it to select it." andPoint:CGPointMake(150,740)];
    _message3 = [[Message alloc] initWithMessage:@"Note that this tool only requires a line and one point!" andPoint:CGPointMake(150,760)];
    
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        [_message1 position: CGPointMake(150,480)];
        [_message2 position: CGPointMake(150,500)];
        [_message3 position: CGPointMake(150,520)];
    }
    
    UIView* hintView = [[UIView alloc]initWithFrame:CGRectMake(0,0,0,0)];
    [geometryView addSubview:hintView];
    [hintView addSubview:_message1];
    [hintView addSubview:_message2];
    [hintView addSubview:_message3];
    
    [UIView animateWithDuration:2 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
        _message1.alpha = 1; } completion:nil];
    
    [self performBlock:^{
        [UIView animateWithDuration:2.0 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
            _message2.alpha = 1; } completion:nil];
    } afterDelay:3.0];
    
    [self performBlock:^{
        _step1finished =YES;
    } afterDelay:4.0];
    
    int segmentindex = 8; //perpendicular line tool
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
                     _message3.alpha = 1;
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
