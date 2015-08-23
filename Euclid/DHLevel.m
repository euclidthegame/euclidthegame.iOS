//
//  DHLevel.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevel.h"
#import "DHLevelViewController.h"

@implementation DHLevel
- (instancetype)init
{
    self = [super init];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            _iPhoneVersion = YES;
        }
    }
    return self;
}
- (void)showTemporaryMessage:(NSString*)message atPoint:(CGPoint)point withColor:(UIColor*)color andTime:(CGFloat)time
{
    UILabel* label = [[UILabel alloc] init];
    label.alpha = 0;
    label.text = message;
    label.textColor = color;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary* attributes = @{NSFontAttributeName: label.font,
                                 NSParagraphStyleAttributeName: paragraphStyle};
    CGSize textSize = [message sizeWithAttributes:attributes];
    
    CGRect frame = label.frame;
    CGFloat originX = point.x - textSize.width*0.5;
    if (originX < 0) {
        originX = 0;
    }
    if (originX + textSize.width > self.view.frame.size.width) {
        originX = self.view.frame.size.width - textSize.width;
    }
    CGFloat originY = point.y - 20 - textSize.height;
    if (originY < self.geometryView.frame.origin.y) {
        originY = self.geometryView.frame.origin.y;
    }
    frame.origin = CGPointMake(roundf(originX), roundf(originY));
    frame.size = textSize;
    label.frame = frame;
    [self.geometryView addSubview:label];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         label.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5
                                               delay:time
                                             options: UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              label.alpha = 0;
                                          }
                                          completion:^(BOOL finished){
                                              [label removeFromSuperview];
                                          }];
                     }];
    
}

-(void)fadeIn:(UIView*)view withDuration:(CGFloat)time
{
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"opacity";
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:1];
    animation.duration = time;
    [view.layer addAnimation:animation forKey:nil];
    [view.layer setValue:[NSNumber numberWithFloat:1.0] forKeyPath:@"opacity"];
}

-(void)fadeInViews:(NSArray*)array withDuration:(CGFloat)time
{
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"opacity";
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:1];
    animation.duration = time;
    
    for (id object in array) {
        UIView* view = object;
    [view.layer addAnimation:animation forKey:nil];
    [view.layer setValue:[NSNumber numberWithFloat:1.0] forKeyPath:@"opacity"];
    }
}

-(void)fadeOut:(DHGeometryView*)view withDuration:(CGFloat)time
{
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"opacity";
    animation.fromValue = [NSNumber numberWithFloat:1];
    animation.toValue = [NSNumber numberWithFloat:0];
    animation.duration = time;
    [view.layer addAnimation:animation forKey:nil];
    [view.layer setValue:[NSNumber numberWithFloat:0.0] forKeyPath:@"opacity"];
}

-(void)movePointFrom:(DHPoint*)start to:(DHPoint*)end withDuration:(CGFloat)time inView:(DHGeometryView*)geometryView
{
    CGPoint delta = PointFromToWithSteps(start.position, end.position,time*100);
    for (int a=0; a<roundf(time*100.0); a++) {
        [self performBlock:^{
            start.position = CGPointMake(start.position.x + delta.x,start.position.y + delta.y);
            [start updatePosition];
            [geometryView setNeedsDisplay];
        } afterDelay:a* (1/100.0)];
    }
}

-(void)movePoint:(DHPoint*)point toPosition:(CGPoint)end withDuration:(CGFloat)time inViews:(NSArray*)geometryViews;
{
    CGPoint delta = PointFromToWithSteps(point.position, end,time*100);
    for (int a=0; a<roundf(time*100.0); a++) {
        [self performBlock:^{
            point.position = CGPointMake(point.position.x + delta.x,point.position.y + delta.y);
            [point updatePosition];
            for (id view in geometryViews) {
                [view setNeedsDisplay];
            }
        } afterDelay:a* (1/100.0)];
    }
}

-(void)movePointOnCircle:(DHPointOnCircle*)point toAngle:(CGFloat)endAngle
            withDuration:(CGFloat)time inView:(DHGeometryView*)geometryView
{
    CGFloat startAngle = point.angle;
    for (int a=0; a<time * 100; a++) {
        [self performBlock:^{
            point.angle = startAngle + (endAngle -startAngle)* a/(time * 100.0) ;
            [point updatePosition];
            [geometryView setNeedsDisplay];
        } afterDelay:a/100.0];
    }
}
-(void)movePointOnCircle:(DHPointOnCircle*)point toAngle:(CGFloat)endAngle
            withDuration:(CGFloat)time inViews:(NSArray*)views
{
    CGFloat startAngle = point.angle;
    for (int a=0; a<time * 100; a++) {
        [self performBlock:^{
            point.angle = startAngle + (endAngle -startAngle)* a/(time * 100.0) ;
            [point updatePosition];
            for (id object in views){
                DHGeometryView* geometryView = object;
                [geometryView setNeedsDisplay];
            }
        } afterDelay:a/100.0];
    }
}

-(void)movePointOnLine:(DHPointOnLine*)point toTValue:(CGFloat)tValue
          withDuration:(CGFloat)time inView:(DHGeometryView*)geometryView
{
        CGFloat startValue = point.tValue;
        for (int a=0; a<time * 100; a++) {
            [self performBlock:^{
                point.tValue = startValue + (tValue - startValue) * a/(time* 100.0);
                [point updatePosition];
                [geometryView setNeedsDisplay];
            } afterDelay:a/100.0];
        }
}

- (void)slideOutToolbar
{
    NSLayoutConstraint* heightToolBar = self.levelViewController.heightToolBar;
    
    CGFloat targetHeight = 70; //_iPhoneVersion ? 42 : 70;
    NSUInteger steps = targetHeight + 20;
    
    for (int a=0; a<steps; a++) {
        [self afterDelay:a*(1.0/steps) :^{
            heightToolBar.constant= targetHeight - a;
        }];
    }
}

- (void)slideInToolbar
{
    NSLayoutConstraint* heightToolBar = self.levelViewController.heightToolBar;
    
    CGFloat targetHeight = 70; //_iPhoneVersion ? 42 : 70;
    NSUInteger steps = targetHeight + 20;
    
    for (int a=0; a<steps; a++) {
        [self performBlock:^{
            heightToolBar.constant= -20 + a;
        } afterDelay:a* (1.0/steps) ];
    }
}

- (void)showEndHintMessageInView:(UIView*)view
{
    Message* message = [[Message alloc] initAtPoint:CGPointMake(0,0) addTo:view];
    [message text:@"Tap anywhere to resume the game"];
    message.font = [UIFont systemFontOfSize:14.0];
    message.textAlignment = NSTextAlignmentCenter;
    [message positionFixed:CGPointMake(view.frame.size.width*0.5 - message.frame.size.width*0.5,
                                       view.frame.size.height-40)];
    
    if (_iPhoneVersion) {
        message.font = [UIFont systemFontOfSize:11.0];
    }
    
    [self fadeIn:message withDuration:2.0];
    [self afterDelay:2.1 :^{
        message.flash = YES;
    }];
}
- (void)hideHint
{
    [self.levelViewController hintFinished];
    [self slideInToolbar];
    self.showingHint = NO;
    [self.geometryView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
}
- (Message*)createUpperMessageWithSuperView:(UIView*)view
{
    CGFloat message1Top = self.iPhoneVersion ? 25 : 90;
    Message* message = [[Message alloc] initAtPoint:CGPointMake(100,message1Top) addTo:view];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        [message position: CGPointMake(150,500)];
    }
    
    return message;
}
- (Message*)createMiddleMessageWithSuperView:(UIView*)view
{
    CGFloat message1Top = 350;
    Message* message = [[Message alloc] initAtPoint:CGPointMake(100,message1Top) addTo:view];
    return message;
}

@end

@implementation NSObject (Blocks)

- (void)performBlock:(void (^)())block
{
    block();
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay
{
    void (^block_)() = [block copy]; // autorelease this if you're not using ARC
    [self performSelector:@selector(performBlock:) withObject:block_ afterDelay:delay];
}
- (void)afterDelay:(NSTimeInterval)delay performBlock:(void (^)())block {
    void (^block_)() = [block copy]; // autorelease this if you're not using ARC
    [self performSelector:@selector(performBlock:) withObject:block_ afterDelay:delay];
}

- (void)afterDelay:(NSTimeInterval)delay :(void (^)())block {
    void (^block_)() = [block copy]; // autorelease this if you're not using ARC
    [self performSelector:@selector(performBlock:) withObject:block_ afterDelay:delay];
}


@end

