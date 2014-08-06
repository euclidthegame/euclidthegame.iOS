//
//  DHLevelLineCopy2.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-05.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelLineCopy2.h"

#import "DHGeometricObjects.h"

@interface DHLevelLineCopy2 () {
    DHLineSegment* _lineAB;
    DHPoint* _pointC;
    Message* _message1, *_message2, *_message3, *_message4;
    BOOL _step1finished;
}

@end

@implementation DHLevelLineCopy2

- (NSString*)subTitle
{
    return @"Straight translation";
}

- (NSString*)levelDescription
{
    return @"Translate the segment AB to the point C.";
}

- (NSString*)levelDescriptionExtra
{
    return @"Translate the segment AB to point C. \n\nIn other words, construct a line segment with the same length and same direction as line segment AB but with starting point C. Note that point C lays on the same line as segment AB.";
}

- (NSString *)additionalCompletionMessage
{
    return (@"You enhanced your tool: Translating lines!");
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable |
            DHTranslateToolAvailable_Weak);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 2;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 4;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:180 andY:200];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:330 andY:150];
    
    DHLineSegment* l1 = [[DHLineSegment alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    DHPointOnLine* p3 = [[DHPointOnLine alloc] init];
    p3.line = l1;
    p3.tValue = 1.4;
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    [geometricObjects addObject:p3];
    
    _pointC = p3;
    _lineAB = l1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHTranslatedPoint* p = [[DHTranslatedPoint alloc] init];
    p.startOfTranslation = _pointC;
    p.translationStart = _lineAB.start;
    p.translationEnd = _lineAB.end;
    
    DHLineSegment* l = [[DHLineSegment alloc] initWithStart:_pointC andEnd:p];
    
    [objects insertObject:l atIndex:0];
    [objects addObject:p];
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
    
    _lineAB.start.position = CGPointMake(200, 300);
    _lineAB.end.position = CGPointMake(220, 150);
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
    BOOL segmentOfEqualLengthOK = NO;
    BOOL lineObjectCoversSegmentOK = NO;
    BOOL endPointOK = NO;
    
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = _pointC;
    tp.translationStart = _lineAB.start;
    tp.translationEnd = _lineAB.end;
    DHLineSegment* sCD = [[DHLineSegment alloc] initWithStart:_pointC andEnd:tp];
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if (object == _pointC || object == _lineAB) continue;

        if (LineObjectCoversSegment(object, sCD)) {
            lineObjectCoversSegmentOK = YES;
        }
        if (EqualPoints(object, tp)) {
            endPointOK = YES;
        }
        if (LineSegmentsWithEqualLength(_lineAB, object)) {
            segmentOfEqualLengthOK = YES;
        }
    }
    
    self.progress = (segmentOfEqualLengthOK)/2.0*100;

    if (lineObjectCoversSegmentOK && endPointOK) {
        self.progress = 100;
        return YES;
    }
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = _pointC;
    tp.translationStart = _lineAB.start;
    tp.translationEnd = _lineAB.end;
    DHLineSegment* sCD = [[DHLineSegment alloc] initWithStart:_pointC andEnd:tp];
    
    
    for (id object in objects){
        if (LineObjectCoversSegment(object, sCD)) return MidPointFromLine(sCD);
        if (EqualPoints(object, tp)) return tp.position;
        if (LineSegmentsWithEqualLength(_lineAB, object) && EqualDirection2(_lineAB,object)){
            DHLineObject* line = object;
            [UIView animateWithDuration:2.0 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                _message3.alpha = 0; _message4.alpha =0; } completion:nil];
            return MidPointFromLine(line);
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
    
    _message1 = [[Message alloc] initWithMessage:@"You have just unlocked the translate a line tool." andPoint:CGPointMake(150,720)];
    _message2 = [[Message alloc] initWithMessage:@"Tap on it to select it." andPoint:CGPointMake(150,740)];
    _message3 = [[Message alloc] initWithMessage:@"Note that this tool can't be used directly in this level." andPoint:CGPointMake(150,760)];
    _message4 = [[Message alloc] initWithMessage:@"Can it be used indirectly ?" andPoint:CGPointMake(150,780)];

    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        [_message1 position: CGPointMake(150,480)];
        [_message2 position: CGPointMake(150,500)];
        [_message3 position: CGPointMake(150,520)];
        [_message4 position: CGPointMake(150,540)];
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
    } afterDelay:4.0];
    
    int segmentindex = 10; //translate line tool
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