//
//  DHLevelMakeCompass.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-05.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelMakeCompass.h"

#import "DHGeometricObjects.h"

@interface DHLevelMakeCompass () {
    DHLineSegment* _lineAB;
    DHPoint* _pointA;
    DHPoint* _pointB;
    DHPoint* _pointC;
    Message* _message1, *_message2, *_message3, *_message4;
    BOOL _step1finished;
}

@end

@implementation DHLevelMakeCompass

- (NSString*)subTitle
{
    return @"Making a compass";
}

- (NSString*)levelDescription
{
    return (@"Construct a circle with radius AB and center C.");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct a circle with radius equal to line segment AB and center C.");
}

- (NSString *)additionalCompletionMessage
{
    return (@"You unlocked a new tool: Compass!");
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable | DHTranslateToolAvailable);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 2;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 5;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:180 andY:250];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:250 andY:150];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:480 andY:200];
    
    DHLineSegment* l1 = [[DHLineSegment alloc] init];
    l1.start = p1;
    l1.end = p2;

    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    [geometricObjects addObject:p3];
    
    _pointA = p1;
    _pointB = p2;
    _pointC = p3;
    _lineAB = l1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHTranslatedPoint* p = [[DHTranslatedPoint alloc] init];
    p.startOfTranslation = _pointC;
    p.translationStart = _lineAB.start;
    p.translationEnd = _lineAB.end;
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:_pointC andPointOnRadius:p];
    
    [objects insertObject:c atIndex:0];
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
    
    _lineAB.start.position = CGPointMake(190, 245);
    _lineAB.end.position = CGPointMake(240, 130);
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
    BOOL pointOnRadiusOK = NO;
    
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = _pointC;
    tp.translationStart = _lineAB.start;
    tp.translationEnd = _lineAB.end;
    DHCircle* circle = [[DHCircle alloc] initWithCenter:_pointC andPointOnRadius:tp];
    
    for (id object in geometricObjects) {
        if (EqualCircles(object, circle)) {
            self.progress = 100;
            return YES;
        }
        if (PointOnCircle(object, circle)) {
            pointOnRadiusOK = YES;
        }
    }
    
    self.progress = pointOnRadiusOK/2.0*100;
    
    return NO;
}

- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = _pointC;
    tp.translationStart = _lineAB.start;
    tp.translationEnd = _lineAB.end;
    
    DHCircle* circle = [[DHCircle alloc] initWithCenter:_pointC andPointOnRadius:tp];
    
    
    for (id object in objects){
        if (EqualCircles(object, circle)) return _pointC.position;
        if (PointOnCircle(object,circle))
        {
            [UIView animateWithDuration:2.0 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                _message3.alpha = 0;  } completion:nil];
            DHPoint* p = object;
            return p.position;
        }
    }
    
    return CGPointMake(NAN, NAN);
}
- (void)animation:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view {
    
    
    NSMutableArray* geometricObjects2 = [[NSMutableArray alloc]init];
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:180 andY:250];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:250 andY:150];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:480 andY:200];
    
    DHLineSegment* l1 = [[DHLineSegment alloc] init];
    l1.start = p1;
    l1.end = p2;

    DHTranslatedPoint* p = [[DHTranslatedPoint alloc] init];
    p.startOfTranslation = p3;
    p.translationStart = p1;
    p.translationEnd = p2;
    
    DHCircle* c = [[DHCircle alloc] initWithCenter:p3 andPointOnRadius:p];

    DHLineSegment* l2 = [[DHLineSegment alloc] init];
    l2.start = p;
    l2.end = p3;
    
    [geometricObjects2 addObject:p3];
    [geometricObjects2 addObject:l2];
    [geometricObjects2 addObject:p];
    [geometricObjects2 insertObject:c atIndex:0];
    
    CGFloat steps = 100;
    CGPoint dA = PointFromToWithSteps(_pointA.position, p1.position, steps);
    CGPoint dB = PointFromToWithSteps(_pointB.position, p2.position, steps);
    CGPoint dC = PointFromToWithSteps(_pointC.position, p3.position, steps);
    
    CGPoint oldOffset = geometryView.geoViewTransform.offset;
    CGFloat oldScale = geometryView.geoViewTransform.scale;
    CGFloat newScale = 1;
    CGPoint newOffset = CGPointMake(0,0);
    
    if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        [geometryView.geoViewTransform setScale:newScale];
        CGPoint oldPointA = _pointA.position;
        _pointA.position = p1.position;
        CGPoint oldPointB = _pointB.position;
        _pointB.position = p2.position;
        CGPoint oldPointC = _pointC.position;
        _pointC.position = p3.position;
        [geometryView centerContent];
        newOffset = geometryView.geoViewTransform.offset;
        [geometryView.geoViewTransform setOffset:oldOffset];
        [geometryView.geoViewTransform setScale:oldScale];
        _pointA.position = oldPointA;
        _pointB.position = oldPointB;
        _pointC.position = oldPointC;
    }
    
    CGPoint offset = PointFromToWithSteps(oldOffset, newOffset, 100);
    CGFloat scale =  pow((newScale/oldScale),0.01) ;
    
    
    for (int a=0; a<steps; a++) {
        [self performBlock:^{
            [geometryView.geoViewTransform offsetWithVector:CGPointMake(offset.x, offset.y)];
            [geometryView.geoViewTransform setScale:geometryView.geoViewTransform.scale *scale];
            _pointA.position = CGPointMake(_pointA.position.x + dA.x,_pointA.position.y + dA.y);
            _pointB.position = CGPointMake(_pointB.position.x + dB.x,_pointB.position.y + dB.y);
            _pointC.position = CGPointMake(_pointC.position.x + dC.x,_pointC.position.y + dC.y);
            
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
        UIView* segment5 = [toolControl.subviews objectAtIndex:0];
        UIView* segment6 = [toolControl.subviews objectAtIndex:0];
        CGPoint pos5 = [segment5.superview convertPoint:segment5.frame.origin toView:geoView];
        CGPoint pos6 = [segment6.superview convertPoint:segment6.frame.origin toView:geoView];
        
        CGFloat xpos = (pos5.x + pos6.x )/2 -4 ;
        CGFloat ypos =  view.frame.size.height - 18;
        
        if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            ypos = ypos -23;
            xpos = xpos +29;
        }
        
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.keyPath = @"position";
        animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(geoView.layer.position.x, geoView.layer.position.y)];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(xpos, ypos)];
        animation.duration = 3;
        
        CABasicAnimation *animation2 = [CABasicAnimation animation];
        animation2.keyPath = @"transform.scale";
        animation2.fromValue = [NSNumber numberWithFloat:1];
        animation2.toValue = [NSNumber numberWithFloat:0.14];
        animation2.duration = 3;
        
        CABasicAnimation *animation3 = [CABasicAnimation animation];
        animation3.keyPath = @"transform.rotation";
        animation3.fromValue = [NSNumber numberWithFloat:0];
        animation3.toValue = [NSNumber numberWithFloat:0.70];
        animation3.duration = 3;
        animation3.removedOnCompletion = NO;
        
        [geoView.layer addAnimation:animation forKey:@"basic1"];
        [geoView.layer addAnimation:animation2 forKey:@"basic2"];
        [geoView.layer addAnimation:animation3 forKey:@"basic3"];
        
        geoView.layer.position = CGPointMake(xpos, ypos);
        geoView.transform = CGAffineTransformMakeScale(0.14, 0.14);
        [geoView.layer setValue:[NSNumber numberWithFloat:0.70] forKeyPath:@"transform.rotation"];
        
        
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
             [toolControl setEnabled:YES forSegmentAtIndex:11];
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
    
    [hintButton setTitle:@"Hide hint" forState:UIControlStateNormal];
    
    _message1 = [[Message alloc] initWithMessage:@"You have just enhanced the translate a line tool." andPoint:CGPointMake(150,720)];
    _message2 = [[Message alloc] initWithMessage:@"Tap on it to select it." andPoint:CGPointMake(150,740)];
    _message3 = [[Message alloc] initWithMessage:@"This tool requires a line and a point." andPoint:CGPointMake(150,760)];
    
    
    
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
    
    int segmentindex = 10; //translate tool
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