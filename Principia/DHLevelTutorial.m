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
    Message* message1; Message* message2; Message* message3; Message* message4; Message* message5; Message* message6;
    BOOL norepeat; BOOL levelcomplete;
    BOOL step1; BOOL step2; BOOL step3; BOOL step4; BOOL step5; BOOL step6; BOOL step7; BOOL step8; BOOL step9; BOOL step10;
    BOOL step11; BOOL step12;
}
@end


@implementation DHLevelTutorial

- (NSString*)subTitle
{
    return @"Learn the basics";
}

- (NSString*)levelDescription
{
    return (@"Follow the instructions.");
}

- (NSString *)additionalCompletionMessage
{
    return @"Well done! You are now ready to begin with Level 1.";
}

- (DHToolsAvailable)availableTools
{
    return (DHLineSegmentToolAvailable);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 4;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:310 andY:450];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:460 andY:450];
    DHPoint* pAhidden = [[DHPoint alloc] initWithPositionX:10000 andY:10000];
    DHPoint* pBhidden = [[DHPoint alloc] initWithPositionX:10000 andY:10000];
    _pointA = pA;
    _pointB = pB;
    
    norepeat = NO;
    levelcomplete = NO;
    step1= YES;
    
    [geometricObjects addObject:pAhidden];
    [geometricObjects addObject:pBhidden];
    
    message1 = [[Message alloc] initWithMessage:@"" andPoint:CGPointMake(200,350)];
    message2 = [[Message alloc] initWithMessage:@"" andPoint:CGPointMake(200,370)];
    message3 = [[Message alloc] initWithMessage:@"" andPoint:CGPointMake(20,850)];
    message4 = [[Message alloc] initWithMessage:@"" andPoint:CGPointMake(20,870)];
    message5 = [[Message alloc] initWithMessage:@"" andPoint:CGPointMake(20,890)];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    return levelcomplete;
}

- (void)tutorial:(NSMutableArray*)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstruction and:(UIView *)geometryView and:(UIView *)view and:(BOOL)update
{
    
    if (norepeat && update) return;
    
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
        if (EqualSegments(sAB, object)) segmentAB =YES;
        if (EqualCircles(cAB,object)) circleAB = YES;
        if (EqualCircles(cBA,object)) circleBA = YES;
        if ([object class] == [DHIntersectionPointCircleCircle class] ||
            [object class] == [DHIntersectionPointLineCircle class] ||
            [object class] == [DHIntersectionPointLineLine class]) {
            intersection = YES;
            DHPoint* p = object;
            _point = [[DHPoint alloc]initWithPositionX:p.position.x andY:p.position.y];
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
    if (step1) {
        // remove toolbar
        toolControl.alpha = 0;
        toolInstruction.alpha = 0;
        [toolControl setEnabled:NO forSegmentAtIndex:2];
        toolControl.selectedSegmentIndex = -1;
        
        //1
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             [message1 text:@"The most fundamental objects in this game are points."];
             [view addSubview:message1];
             message1.alpha = 1;
         }
         completion:^(BOOL finished){
             
             //2
             [geometricObjects addObject:_pointA];
             [geometricObjects addObject:_pointB];
             [geometryView setNeedsDisplay];
             [UIView
              animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                  [message2 text:@"Points are often labeled with capital letters."];
                  [view addSubview:message2];
                  message2.alpha = 1;
              }
              completion:^(BOOL finished){
                  
                  //3
                  _pointA.label =@"A";
                  _pointB.label =@"B";
                  [geometryView setNeedsDisplay];
                  [UIView
                   animateWithDuration:1.5 delay:1.5 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                       [message3 text:@"Other objects can be constructed from those points using the toolbar below."];
                       [view addSubview:message3];
                       message3.alpha = 1;
                       toolControl.alpha = 1;
                   }
                   completion:^(BOOL finished){
                       
                       //4
                       [UIView
                        animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                            [message4 text:@"Let's start with constructing a line segment. Tap on the tool, to select it."];
                            [view addSubview:message4];
                            message4.alpha = 1;
                        }
                        completion:^(BOOL finished){
                            [toolControl setEnabled:YES forSegmentAtIndex:2];
                            step1 = NO;
                            step2 = YES;
                        }];
                   }];
              }];
             
         }];
    }
    
    else if (step2 && toolControl.selectedSegmentIndex == 2 ) {
        message1.alpha = 0; message2.alpha = 0;
        [message1 text:@"Try to construct a line segment that connects point A and B."];
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             message3.alpha = 0;
             message4.alpha = 0;
             toolInstruction.alpha = 1;
             message1.alpha = 1;
         }
         completion:^(BOOL finished){step2 = NO; step3 = YES;}];
    }
    else if (step3 && segmentAB) {
        message6 = [[Message alloc] initWithMessage:@"Well done!" andPoint:Position(sAB)];
        [geometryView addSubview:message6];
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             [toolControl setEnabled:NO forSegmentAtIndex:2];
             message6.alpha = 1;
         }
         completion:^(BOOL finished){
             toolInstruction.alpha = 0;
             [UIView
              animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                  message6.alpha = 0;
                  message1.alpha = 0;
                  [message3 text: @"We can also use points to construct a circle."];
                  message3.alpha = 1;
                  
              }
              completion:^(BOOL finished){
                  [UIView
                   animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                       [message4 text:@"Tap on on the circle tool, to select it."];
                       message4.alpha = 1;
                       [toolControl setEnabled:YES forSegmentAtIndex:4];
                   }
                   completion:^(BOOL finished){
                       step3 = NO;
                       step4 = YES;
                   }];
              }];
         }];
    }
    else if (step4 && toolControl.selectedSegmentIndex == 4) {
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             toolInstruction.alpha = 1;
             [message1 text:@"Try to construct a circle with center A and radius AB."];
             message1.alpha = 1;
             message3.alpha = 0;
             message4.alpha = 0;
         }
         completion:^(BOOL finished){
             step4 = NO;
             step5= YES;
         }];
    }
    else if (step5 && circleAB) {
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
              completion:^(BOOL finished){
                  step5= NO;
                  step6 = YES;
              }];
         }];
        
    }
    else if (step6 && circleBA) {
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
                  [message3 text:@"Sometimes it is usefull to extend a segment using the line tool."];
                  message3.alpha = 1;
                  [toolControl setEnabled:NO forSegmentAtIndex:4];
              }
              completion:^(BOOL finished){
                  [UIView
                   animateWithDuration:1.0 delay:1.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                       [message4 text: @"Tap on it, to select it."];
                       [toolControl setEnabled:YES forSegmentAtIndex:3];
                       message4.alpha = 1;
                   }
                   completion:^(BOOL finished){ step6 = NO; step7 = YES;
                   }];
              }];
         }];
    }
    else if (step7 && toolControl.selectedSegmentIndex == 3) {
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             toolInstruction.alpha = 1;
             message3.alpha = 0;
             message4.alpha = 0;
             [message1 text:@"Try to construct a line using the points A and B."];
             message1.alpha = 1;
         }
         completion:^(BOOL finished){step7= NO; step8 = YES;}];
    }
    else if (step8 && lineAB) {
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
                       [message4 text:@"Tap on the intersect tool, to select it."];
                       [toolControl setEnabled:YES forSegmentAtIndex:1];
                       message4.alpha = 1;
                   }
                   completion:^(BOOL finished){ step8 = NO; step9 = YES;
                   }];
              }];
         }];
    }
    
    else if (step9 && toolControl.selectedSegmentIndex == 1) {
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             toolInstruction.alpha = 1;
             message3.alpha = 0; message4.alpha = 0;
             [message1 text:@"Construct a point at an intersection."];
             message1.alpha = 1;
         }
         completion:^(BOOL finished){ step9 = NO; step10 = YES;  }];
    }
    else if (step10 && intersection) {
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
                        completion:^(BOOL finished){step10 = NO; step11 = YES; }];
                   }];
              }];
         }];
    }
    else if (step11 && toolControl.selectedSegmentIndex == 0 ) {
        [UIView
         animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             toolInstruction.alpha = 1;
             [message1 text:@"Move one of the grey points."];
             message1.alpha = 1;
             message3.alpha = 0;
             message4.alpha = 0;
             message5.alpha = 0;
         }
         completion:^(BOOL finished){step11 = NO; step12 = YES;}];
    }
    
    else if (step12 && moved) {
        norepeat = YES;
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
                  [message3 text: @"These are the 5 primitive tools, you will start with in Level 1."];
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
                       [message4 text:@"To unlock any other tools, you first need to complete some levels!"];
                       message4.alpha = 1;
                       [toolControl setEnabled:YES forSegmentAtIndex:0];
                   }
                   completion:^(BOOL finished){
                       step12 = NO; levelcomplete=YES;
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