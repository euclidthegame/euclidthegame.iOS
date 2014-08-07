//
//  DHLevel6.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-02.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelPerpendicular.h"
#import <CoreGraphics/CGBase.h>
#import "DHGeometricObjects.h"

@interface DHLevelPerpendicular () {
    DHPoint* _pointA;
    DHPoint* _pointHidden1;
    DHPoint* _pointHidden2;
    DHLine* _lineBC;
    Message* _message1, *_message2, *_message3, *_message4;
    BOOL _step1finished;
    BOOL pointOnLineOK;
}

@end

@implementation DHLevelPerpendicular

- (NSString*)subTitle
{
    return @"Perpendicular";
}

- (NSString*)levelDescription
{
    return @"Construct a line on A that is perpendicular to the given line.";
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct a line (segment) on A that is perpendicular to the given line. \n \nWhen a straight line standing on a straight line makes the adjacent angles equal to one another, each of the equal angles is right, and the straight line standing on the other is called a perpendicular to that on which it stands.");
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable_Weak |
            DHBisectToolAvailable);
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
    DHPointOnLine* p1 = [[DHPointOnLine alloc] init];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:200 andY:300];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:500 andY:300];
    
    DHLine* l1 = [[DHLine alloc] init];
    l1.start = p2;
    l1.end = p3;

    p1.line = l1;
    p1.tValue = 0.75;
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    
    _pointA = p1;
    _lineBC = l1;
    _pointHidden1 = p2;
    _pointHidden2 = p3;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHPoint* p = [[DHPoint alloc] initWithPositionX:500 andY:200];
    DHCircle* c = [[DHCircle alloc] initWithCenter:p andPointOnRadius:_pointA];
    DHIntersectionPointLineCircle* ip1 = [[DHIntersectionPointLineCircle alloc] init];
    ip1.c = c;
    ip1.l = _lineBC;
    ip1.preferEnd = NO;
    DHLine* l1 = [[DHLine alloc] initWithStart:ip1 andEnd:p];
    DHIntersectionPointLineCircle* ip2 = [[DHIntersectionPointLineCircle alloc] init];
    ip2.c = c;
    ip2.l = l1;
    ip2.preferEnd = YES;
    
    
    DHRay* r = [[DHRay alloc] init];
    r.start = _pointA;
    r.end = ip2;
    
    [objects insertObject:r atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }

    // Move B and C and ensure solution holds    
    CGPoint pointB = _lineBC.start.position;
    CGPoint pointC = _lineBC.end.position;
    
    _lineBC.start.position = CGPointMake(100, 100);
    _lineBC.end.position = CGPointMake(400, 400);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];

    _lineBC.start.position = pointB;
    _lineBC.end.position = pointC;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    pointOnLineOK = NO;
    BOOL pointOnPerpLineOK = NO;
    self.progress = 0;
    DHPerpendicularLine* pl = [[DHPerpendicularLine alloc] initWithLine:_lineBC andPoint:_pointA];
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if (object == _pointA) continue;
        
        if ([object class] == [DHPointOnLine class]) {
            DHPointOnLine* p = object;
            if (PointOnLine(p, _lineBC) ) {
                pointOnLineOK = YES;
                [UIView animateWithDuration:2.0 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                    _message4.alpha = 0;  } completion:nil];
            }
        }
        if ([[object class]  isSubclassOfClass:[DHPoint class]] && [object class] != [DHPoint class]) {
            CGFloat dist = DistanceFromPointToLine(object, pl);
            if (dist < 0.001) {
                pointOnPerpLineOK = YES;
            }
        }
        
        if ([[object class]  isSubclassOfClass:[DHLineObject class]]) {
            DHLineObject* l = object;
            CGFloat distAL = DistanceFromPointToLine(_pointA, l);
            CGVector bc = CGVectorNormalize(_lineBC.vector);
            
            CGFloat lDotBC = CGVectorDotProduct(CGVectorNormalize(l.vector), bc);
            if (distAL < 0.001 && fabs(lDotBC) < 0.001) {
                self.progress = 100;
                return YES;
            }
        }
    }
    
    self.progress = (pointOnPerpLineOK * 50);
    
    return NO;
}

- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    DHPerpendicularLine* perp = [[DHPerpendicularLine alloc] init];
    perp.line = _lineBC;
    perp.point = _pointA;
    
    for (id object in objects){
        
        if ([object class] == [DHCircle class])
        {
            DHCircle* c = object;
            if (EqualPoints(c.center,_pointA)) return c.center.position;
        }
        if ([object class] == [DHIntersectionPointLineCircle class])
        {
            DHPoint* p = object;
            if (PointOnLine(p,_lineBC)) return p.position;
        }
        if (PointOnLine(object,perp)){ DHPoint* p = object; return p.position; }
        if (EqualDirection(object,perp) && PointOnLine(_pointA, object))  return _pointA.position;
        
    }
    return CGPointMake(NAN, NAN);
}
- (void)hint:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view and:(NSLayoutConstraint*)heightToolBar and:(UIButton*)hintButton{
    
    if ([hintButton.titleLabel.text  isEqual: @"Hide hint"]) {
        [hintButton setTitle:@"Show hint" forState:UIControlStateNormal];
        [geometryView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        return;
    }
    
    if (pointOnLineOK){
        [self showTemporaryMessage:@"No more hints available." atPoint:CGPointMake(self.geometryView.center.x,50) withColor:[UIColor darkGrayColor] andTime:5.0];
        return;
    }
    
    [hintButton setTitle:@"Hide hint" forState:UIControlStateNormal];
    
    _message1 = [[Message alloc] initWithMessage:@"There is only one point given." andPoint:CGPointMake(20,720)];
    _message2 = [[Message alloc] initWithMessage:@"But most tools in the toolbar require at least 2 points! " andPoint:CGPointMake(20,740)];
    _message3 = [[Message alloc] initWithMessage:@"A second point can be constructed using the point tool. Tap on it to select it." andPoint:CGPointMake(20,760)];
    _message4 = [[Message alloc] initWithMessage:@"Good ! Let's start with constructing a point. For example, on the given line." andPoint:CGPointMake(20,780)];
    
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
