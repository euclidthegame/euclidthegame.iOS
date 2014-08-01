//
//  DHLevel1.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelTutorial.h"

@interface DHLevelTutorial () {
    DHPoint* _pointA;
    DHPoint* _pointB;
    DHPoint* _point;
    Message* message1;
    Message* message2;
    Message* message3;
    Message* message4;
    Message* message5;
    Message* message6;
    BOOL _noRepeat, _levelComplete;
    NSUInteger _currentStep;
    //BOOL step1, step2, step3, step4, step5, step6, step7, step8, step9, step10, step11, step12;
}
@end


@implementation DHLevelTutorial

- (NSString*)subTitle
{
    return @"Learn the basics";
}

- (NSString*)levelDescription
{
    return (@"");
}

- (NSString *)additionalCompletionMessage
{
    return @"Well done! You are now ready to begin with Level 1.";
}

- (DHToolsAvailable)availableTools
{
    return (0);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 4;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        _pointA = [[DHPoint alloc] initWithPositionX:310 andY:450];
        _pointB = [[DHPoint alloc] initWithPositionX:460 andY:450];
    } else {
        _pointA = [[DHPoint alloc] initWithPositionX:430 andY:250];
        _pointB = [[DHPoint alloc] initWithPositionX:590 andY:250];
    }
    
    _noRepeat = NO;
    _levelComplete = NO;
    _currentStep = 1;
    
    message1 = [[Message alloc] initWithMessage:@"" andPoint:CGPointMake(200,300)];
    message2 = [[Message alloc] initWithMessage:@"" andPoint:CGPointMake(200,320)];
    message3 = [[Message alloc] initWithMessage:@"" andPoint:CGPointMake(20,850)];
    message4 = [[Message alloc] initWithMessage:@"" andPoint:CGPointMake(20,870)];
    message5 = [[Message alloc] initWithMessage:@"" andPoint:CGPointMake(20,890)];
}

- (void)positionMessagesForOrientation:(UIInterfaceOrientation)orientation
{
    CGRect frame1 = message1.frame;
    CGRect frame2 = message2.frame;
    CGRect frame3 = message3.frame;
    CGRect frame4 = message4.frame;
    CGRect frame5 = message5.frame;
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        frame1.origin = CGPointMake(200,300);
        frame2.origin = CGPointMake(200,320);
        frame3.origin = CGPointMake(20,850);
        frame4.origin = CGPointMake(20,870);
        frame5.origin = CGPointMake(20,890);
    } else {
        frame1.origin = CGPointMake(300,100);
        frame2.origin = CGPointMake(300,122);
        frame3.origin = CGPointMake(20,590);
        frame4.origin = CGPointMake(20,612);
        frame5.origin = CGPointMake(20,634);
    }
    
    message1.point = frame1.origin;
    message2.point = frame2.origin;
    message3.point = frame3.origin;
    message4.point = frame4.origin;
    message5.point = frame5.origin;
    message1.frame = frame1;
    message2.frame = frame2;
    message3.frame = frame3;
    message4.frame = frame4;
    message5.frame = frame5;
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    if (_levelComplete){
        message3.alpha = 0;
        message4.alpha = 0;
        message5.alpha = 0;
    }
    return _levelComplete;
}

- (void)tutorial:(NSMutableArray*)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstruction and:(UIView *)geometryView and:(UIView *)view and:(NSLayoutConstraint*)heightToolControl and:(BOOL)update
{
    
    if (_noRepeat && update) return;
    
    BOOL segmentAB = NO;
    BOOL circleAB = NO;
    BOOL circleBA = NO;
    BOOL lineAB = NO;
    BOOL intersection = NO;
    BOOL moved = NO;
    
    DHLineSegment* sAB = [[DHLineSegment alloc]initWithStart:_pointA andEnd:_pointB];
    DHLine *lAB = [[DHLine alloc]initWithStart:_pointA andEnd:_pointB];
    DHCircle* cAB = [[DHCircle alloc] initWithCenter:_pointA andPointOnRadius:_pointB];
    DHCircle* cBA = [[DHCircle alloc] initWithCenter:_pointB andPointOnRadius:_pointA];
    
    for (id object in geometricObjects) {
        if (EqualLineSegments(sAB, object)) segmentAB =YES;
        if (EqualCircles(cAB,object)) circleAB = YES;
        if (EqualCircles(cBA,object)) circleBA = YES;
        if ([object class] == [DHIntersectionPointCircleCircle class] ||
            [object class] == [DHIntersectionPointLineCircle class] ||
            [object class] == [DHIntersectionPointLineLine class]) {
            intersection = YES;
            DHPoint* p = object;
            _point = [[DHPoint alloc] initWithPositionX:p.position.x andY:p.position.y];
        }
        if (EqualLines(lAB,object)) lineAB = YES;
        if (_pointA.position.x != 310){
            moved = YES;
            _point = _pointA;
        }
        else if(_pointB.position.x != 460) {
            moved = YES;
            _point = _pointB;
        }
    }
    if (_currentStep == 1) {
        // remove toolbar
        toolControl.alpha = 0;
        toolInstruction.alpha = 0;
        _currentStep = 2;
        
        [UIView
         animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             [message1 text:@"Points are the most fundamental objects in this game."]; message1.alpha = 1;
             [view addSubview:message1];
         }
         completion:^(BOOL finished){
             
             [geometricObjects addObject:_pointA];
             [geometricObjects addObject:_pointB];
             [geometryView setNeedsDisplay];
             [UIView
              animateWithDuration:1.0 delay:2.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                  [message2 text:@"They are labeled with capital letters."]; message2.alpha = 1;
                  [view addSubview:message2];
              }
              completion:^(BOOL finished){
                  
                  _pointA.label =@"A";
                  _pointB.label =@"B";
                  [geometryView setNeedsDisplay];
                  [UIView
                   animateWithDuration:1.5 delay:1.5 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                       [message3 text:@"Other objects can be constructed from points using the toolbar below."];
                       [view addSubview:message3];
                       message3.alpha = 1;
                       toolControl.alpha = 1;

                   }
                   completion:^(BOOL finished){
                        heightToolControl.constant = 70;
                       [UIView
                        animateWithDuration:1.0 delay:2.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                            [message4 text:@"Let's start by constructing a line segment. Tap on the tool to select it."];
                            [view addSubview:message4];
                            message4.alpha = 1;
                        }
                        completion:^(BOOL finished){
                            [toolControl setEnabled:YES forSegmentAtIndex:2];
                             }]; }]; }]; }];
    }
    else if (_currentStep == 2 && toolControl.selectedSegmentIndex == 2 ) {
        _currentStep = 3;
        message1.alpha = 0; message2.alpha = 0;
        [message1 text:@"Try to construct a line segment that connects point A and B."];
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             message3.alpha = 0; message4.alpha = 0; message1.alpha = 1;
             toolInstruction.alpha = 1;
         }
         completion:^(BOOL finished){}];
    }
    else if (_currentStep == 3 && segmentAB) {
        _currentStep = 4;
        message6 = [[Message alloc] initWithMessage:@"Well done!" andPoint:Position(sAB)];
        [geometryView addSubview:message6];
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             [toolControl setEnabled:NO forSegmentAtIndex:2];
             message6.alpha = 1; message1.alpha = 0;
         }
         completion:^(BOOL finished){
             toolInstruction.alpha = 0;
             [UIView
              animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                  message6.alpha = 0;
                  [message3 text: @"Points can also be used to construct a circle."];
                  message3.alpha = 1;
              }
              completion:^(BOOL finished){
                  [UIView
                   animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                       [message4 text:@"Tap on the circle tool to select it."];
                       message4.alpha = 1;
                       [toolControl setEnabled:YES forSegmentAtIndex:4];
                   }
                   completion:^(BOOL finished){ }]; }]; }];
    }
    else if (_currentStep == 4 && toolControl.selectedSegmentIndex == 4) {
        _currentStep = 5;
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             message3.alpha = 0; message4.alpha = 0;
             toolInstruction.alpha = 1;
             [message1 text:@"Try to construct a circle with center A and radius AB."];
             message1.alpha = 1;
         }
         completion:^(BOOL finished){ }];
    }
    else if (_currentStep == 5 && circleAB) {
        _currentStep = 6;
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             [message6 text: @"Well done!" position:Position(cAB)];
             message6.alpha = 1;
         }
         completion:^(BOOL finished){
             [UIView
              animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                  message6.alpha = 0 ;
                  [message1 text: @"Now, let's make a circle with center B (!) and radius AB."];
                  message1.alpha = 1;
              }
              completion:^(BOOL finished){}] ;}];
    }
    else if (_currentStep == 6 && circleBA) {
        _currentStep = 7;
        [UIView
         animateWithDuration:1.0
         delay:0.0
         options: UIViewAnimationOptionAllowAnimatedContent
         animations:^{
             message1.alpha = 0;
             [message6 text:@"Well done!" position:Position(cBA)];
             message6.alpha = 1;
         }
         completion:^(BOOL finished){
             toolInstruction.alpha = 0;
             [UIView
              animateWithDuration:1.0
              delay:1.0
              options: UIViewAnimationOptionAllowAnimatedContent
              animations:^{
                  message6.alpha = 0;
                  [message3 text:@"Sometimes it is useful to extend a segment using the line tool."];
                  message3.alpha = 1;
                  [toolControl setEnabled:NO forSegmentAtIndex:4];
              }
              completion:^(BOOL finished){
                  [UIView
                   animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                       [message4 text: @"Tap on it to select it."];
                       [toolControl setEnabled:YES forSegmentAtIndex:3];
                       message4.alpha = 1;
                   }
                   completion:^(BOOL finished){}];}];}];
    }
    else if (_currentStep == 7 && toolControl.selectedSegmentIndex == 3) {
        _currentStep = 8;
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             toolInstruction.alpha = 1;
             message3.alpha = 0; message4.alpha = 0;
             [message1 text:@"Try to construct a line using the points A and B."];
             message1.alpha = 1;
         }
         completion:^(BOOL finished){}];
    }
    else if (_currentStep == 8 && lineAB) {
        _currentStep = 9;
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             message1.alpha = 0;
             [message6 text:@"Well done!" position:Position(lAB)];
             message6.alpha = 1;
         }
         completion:^(BOOL finished){
             toolInstruction.alpha = 0;
             [UIView
              animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                  message6.alpha = 0;
                  [message3 text:@"If lines or circles intersect we can create a point at the intersection."];
                  message3.alpha = 1;
                  [toolControl setEnabled:NO forSegmentAtIndex:3];
              }
              completion:^(BOOL finished){
                  [UIView
                   animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                       [message4 text:@"Tap on the intersect tool to select it."];
                       [toolControl setEnabled:YES forSegmentAtIndex:1];
                       message4.alpha = 1;
                   }
                   completion:^(BOOL finished){ }];}];}];
    }
    else if (_currentStep == 9 && toolControl.selectedSegmentIndex == 1) {
        _currentStep = 10;
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             toolInstruction.alpha = 1;
             message3.alpha = 0; message4.alpha = 0;
             [message1 text:@"Construct a point at an intersection."];
             message1.alpha = 1;
         }
         completion:^(BOOL finished){ }];
    }
    else if (_currentStep == 10 && intersection) {
        _currentStep = 11;
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             message1.alpha = 0;
             [message6 text:@"Well done!" position:Position(_point)];
             message6.alpha = 1;
         }
         completion:^(BOOL finished){
             [UIView
              animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                  message6.alpha = 0;
                  [message3 text:@"Note that the intersection point is black. Black points are unmovable and precise."];
                  message3.alpha = 1;
                  toolInstruction.alpha = 0;
                  [toolControl setEnabled:NO forSegmentAtIndex:1];
              }
              completion:^(BOOL finished){
                  [UIView
                   animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                       [message4 text: @"Grey points are not placed precisely on an intersection and are movable."];
                       message4.alpha = 1;
                   }
                   completion:^(BOOL finished){
                       [UIView
                        animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                            [message5 text:@"Try to move a grey point using the point tool."];
                            [view addSubview:message5];
                            message5.alpha = 1;
                            [toolControl setEnabled:YES forSegmentAtIndex:0];
                        }
                        completion:^(BOOL finished){ }];
                   }];
              }];
         }];
    }
    else if (_currentStep == 11 && toolControl.selectedSegmentIndex == 0 ) {
        _currentStep = 12;
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             message3.alpha = 0; message4.alpha = 0; message5.alpha = 0;
             toolInstruction.alpha = 1;
             [message1 text:@"Move one of the grey points."];
             message1.alpha = 1;
         }
         completion:^(BOOL finished){}];
    }
    
    else if (_currentStep == 12 && moved) {
        _currentStep = 13;
        _noRepeat = YES;
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             message1.alpha = 0;
             [message6 text:@"Well done!" position:Position(_point)];
             message6.alpha = 1;
         }
         completion:^(BOOL finished){
             [UIView
              animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                  message6.alpha = 0;
                  [message3 text: @"These are the 5 primitive tools you will start with in Level 1."];
                  message3.alpha = 1;
                  [toolControl setEnabled:YES forSegmentAtIndex:0];
                  [toolControl setEnabled:YES forSegmentAtIndex:1];
                  [toolControl setEnabled:YES forSegmentAtIndex:2];
                  [toolControl setEnabled:YES forSegmentAtIndex:3];
                  [toolControl setEnabled:YES forSegmentAtIndex:4];
              }
              completion:^(BOOL finished){
                  [UIView
                   animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                       [message4 text:@"To unlock the other tools, you need to complete more levels!"];
                       message4.alpha = 1;
                   }
                   completion:^(BOOL finished){
                       [UIView
                        animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                            [message5 text:@"Construct a new object with any of the 5 available tools to complete the tutorial."];
                            message5.alpha = 1;
                        }
                        completion:^(BOOL finished){ _levelComplete=YES;}];
                   }];
              }];
         }];
    }
}

@end

@implementation Message
- (instancetype)initWithMessage:(NSString*)message andPoint:(CGPoint)point
{
    self = [super init];
    if (self) {
        self.alpha = 0;
        self.text = message;
        self.textColor = [UIColor darkGrayColor];
        self.point = point;
        CGRect frame = self.frame;
        frame.origin = self.point;
        self.frame = frame;
        [self sizeToFit];
    }
    return self;
}

- (void)text:(NSString*)string{
    self.text = [NSString stringWithString:string];
    CGRect frame = self.frame;
    frame.origin = self.point;
    self.frame = frame;
    [self sizeToFit];
}
- (void)text:(NSString*)string position:(CGPoint)point{
    self.text = string;
    self.point = point;
    CGRect frame = self.frame;
    frame.origin = self.point;
    self.frame = frame;
    [self sizeToFit];
}
@end