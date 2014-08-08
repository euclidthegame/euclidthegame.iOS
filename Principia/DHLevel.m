//
//  DHLevel.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevel.h"

@implementation DHLevel

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

-(void)fadeIn:(UIView*)view withDuration:(CGFloat)time {
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"opacity";
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:1];
    animation.duration = time;
    [view.layer addAnimation:animation forKey:nil];
    [view.layer setValue:[NSNumber numberWithFloat:1.0] forKeyPath:@"opacity"];
}
-(void)fadeOut:(DHGeometryView*)view withDuration:(CGFloat)time {
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"opacity";
    animation.fromValue = [NSNumber numberWithFloat:1];
    animation.toValue = [NSNumber numberWithFloat:0];
    animation.duration = time;
    [view.layer addAnimation:animation forKey:nil];
    [view.layer setValue:[NSNumber numberWithFloat:0.0] forKeyPath:@"opacity"];
}

-(void)movePointFrom:(DHPoint*)start to:(DHPoint*)end withDuration:(CGFloat)time inView:(DHGeometryView*)geometryView {
    CGPoint delta = PointFromToWithSteps(start.position, end.position,time*100);
    for (int a=0; a<roundf(time*100.0); a++) {
        [self performBlock:^{
            start.position = CGPointMake(start.position.x + delta.x,start.position.y + delta.y);
            [start updatePosition];
            [geometryView setNeedsDisplay];
        } afterDelay:a* (1/100.0)];
    }
}
-(void)movePointOnCircle:(DHPointOnCircle*)point toAngle:(CGFloat)endAngle withDuration:(CGFloat)time inView:(DHGeometryView*)geometryView {
    CGFloat startAngle = point.angle;
    for (int a=0; a<time * 100; a++) {
        [self performBlock:^{
            point.angle = startAngle + (endAngle -startAngle)* a/(time * 100.0) ;
            [point updatePosition];
            [geometryView setNeedsDisplay];
        } afterDelay:a/100.0];
    }
}
-(void)movePointOnLine:(DHPointOnLine*)point toTValue:(CGFloat)tValue withDuration:(CGFloat)time inView:(DHGeometryView*)geometryView {
        CGFloat startValue = point.tValue;
        for (int a=0; a<time * 100; a++) {
            [self performBlock:^{
                point.tValue = startValue + (tValue - startValue) * a/(time* 100.0);
                NSLog(@"%f %i",point.tValue, a);
                [point updatePosition];
                [geometryView setNeedsDisplay];
            } afterDelay:a/100.0];
        }
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
- (void)position:(CGPoint)point{
    self.point = point;
    CGRect frame = self.frame;
    frame.origin = self.point;
    self.frame = frame;
    [self sizeToFit];
}
@end