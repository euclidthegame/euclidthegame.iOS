//
//  DHLevelMakeTangent.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelMakeTangent.h"

#import "DHGeometricObjects.h"

@interface DHLevelMakeTangent () {
    DHCircle* _circle;
    Message* _message1,*_message2,*_message3;
    BOOL _step1finished;
    BOOL centerOK;
}

@end

@implementation DHLevelMakeTangent

- (NSString*)subTitle
{
    return @"Tangentially related";
}

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
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects{
    
    
    for (id object in objects){
        if (EqualPoints(_circle.center, object)) {
            [self fadeOut:_message3 withDuration:1.0];
            return _circle.center.position;
        }
    
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
    
    if (centerOK) {
        [self showTemporaryMessage:@"No more hints available." atPoint:CGPointMake(self.geometryView.center.x,50) withColor:[UIColor darkGrayColor] andTime:5.0];
        return;
    }
    
    _message1 = [[Message alloc] initWithMessage:@"You have just enhanced the midpoint tool." andPoint:CGPointMake(150,720)];
    _message2 = [[Message alloc] initWithMessage:@"Tap on it to select it." andPoint:CGPointMake(150,740)];
    _message3 = [[Message alloc] initWithMessage:@"This tool requires a circle" andPoint:CGPointMake(150,760)];
    
    
    
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
    
    int segmentindex = 6; //midpoint tool
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
