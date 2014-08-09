//
//  DHLevelLineCopyOnLine.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelLineCopyOnLine.h"

#import "DHGeometricObjects.h"

@interface DHLevelLineCopyOnLine () {
    DHLineSegment* _lineAB;
    DHLineSegment* _lineCD;
    Message* _message1, *_message2, *_message3, *_message4;
    BOOL _step1finished;
    BOOL circleWithABRadiusAtCOK;
}

@end

@implementation DHLevelLineCopyOnLine

- (NSString*)subTitle
{
    return @"Staying online";
}

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
            [UIView animateWithDuration:2.0 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                _message3.alpha = 0;  } completion:nil];
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

- (void)hint:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view and:(NSLayoutConstraint*)heightToolBar and:(UIButton*)hintButton{
    
    if ([hintButton.titleLabel.text  isEqual: @"Hide hint"]) {
        [hintButton setTitle:@"Show hint" forState:UIControlStateNormal];
        [geometryView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        return;
    }
    
    [hintButton setTitle:@"Hide hint" forState:UIControlStateNormal];
    
    if (circleWithABRadiusAtCOK) {
        Message* message0 = [[Message alloc] initWithMessage:@"No more hints available." andPoint:CGPointMake(150,150)];
        [geometryView addSubview:message0];
        [self fadeIn:message0 withDuration:1.0];
        [self afterDelay:4.0 :^{[self fadeOut:message0 withDuration:1.0];}];
        return;
    }
    
    _message1 = [[Message alloc] initWithMessage:@"You have just unlocked the compass tool." andPoint:CGPointMake(150,720)];
    _message2 = [[Message alloc] initWithMessage:@"Tap on it to select it." andPoint:CGPointMake(150,740)];
    _message3 = [[Message alloc] initWithMessage:@"This tool requires a line and two points or a line and a point." andPoint:CGPointMake(150,760)];
    
    
    
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
    
    int segmentindex = 11; //compass tool
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
