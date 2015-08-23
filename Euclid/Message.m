//
//  Message.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-23.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "Message.h"

static const CGFloat kMessageiPhoneMargin = 10.0;

@interface Message ()

@property (nonatomic, weak) Message* childAbove;
@property (nonatomic, weak) Message* childBelow;
@property (nonatomic, weak) Message* parentAbove;
@property (nonatomic, weak) Message* parentBelow;

@end

@implementation Message {
    NSTimer* _flashTimer;
    NSDate* _timerStart;
    BOOL _iPhoneVersion;
    BOOL _fixedPosition;
}
- (instancetype)initWithMessage:(NSString*)message andPoint:(CGPoint)point
{
    self = [super init];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            _iPhoneVersion = YES;
        }
        if (_iPhoneVersion) {
            self.font = [UIFont systemFontOfSize:13];
            [self setLineBreakMode:NSLineBreakByWordWrapping];
        }
        self.numberOfLines = 0;
        
        self.alpha = 0;
        self.text = message;
        self.textColor = [UIColor darkGrayColor];
        [self position:point];
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        self.layer.cornerRadius = 5.0;
    }
    return self;
}
- (instancetype)initAtPoint:(CGPoint)point addTo:(UIView*)view
{
    self = [self initWithMessage:@"" andPoint:point];
    if (self) {
        [view addSubview:self];
    }
    return self;
}
- (void)text:(NSString*)string
{
    self.text = [NSString stringWithString:string];
    [self sizeToFit];
    
    if (self.parentAbove) [self positionBelow:self.parentAbove];
    if (self.parentBelow) [self positionAbove:self.parentBelow];
    if (self.childAbove) [self.childAbove positionAbove:self];
    if (self.childBelow) [self.childAbove positionBelow:self];
}
- (void)text:(NSString*)string position:(CGPoint)point
{
    self.text = string;
    
    [self position:point];
}
- (void)position:(CGPoint)point {
    if (_iPhoneVersion && !_fixedPosition) {
        point.x = kMessageiPhoneMargin;
        point.y = point.y * 0.5;
    }
    
    self.point = point;
    CGRect frame = self.frame;
    frame.origin = self.point;
    self.frame = frame;
    [self sizeToFit];
    
    if (self.parentAbove) [self positionBelow:self.parentAbove];
    if (self.parentBelow) [self positionAbove:self.parentBelow];
    if (self.childAbove) [self.childAbove positionAbove:self];
    if (self.childBelow) [self.childAbove positionBelow:self];
}
- (void)positionFixed:(CGPoint)point
{
    _fixedPosition = YES;
    [self position:point];
}
- (void)setFlash:(BOOL)flash
{
    _flash = flash;
    if (_flash) {
        if (_flashTimer == nil)
        {
            _flashTimer = [NSTimer timerWithTimeInterval:1/30.0
                                                  target:self
                                                selector:@selector(updateFlashState:)
                                                userInfo:nil
                                                 repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_flashTimer forMode:NSRunLoopCommonModes];
            _timerStart = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
        }
    } else {
        if (_flashTimer && [_flashTimer isValid])
        {
            [_flashTimer invalidate];
        }
        
        _flashTimer = nil;
    }
}
- (void)updateFlashState:(NSTimer *)timer
{
    NSTimeInterval elapsedTime = -[_timerStart timeIntervalSinceNow];
    self.alpha = 0.4*cos(elapsedTime*0.5*M_PI)+0.6;
}
- (void)dealloc
{
    if (_flashTimer && [_flashTimer isValid])
    {
        [_flashTimer invalidate];
    }
}
- (void)positionAbove:(Message *)message
{
    CGPoint point = message.point;
    if (_iPhoneVersion) {
        point.y -= self.bounds.size.height;
    } else {
        point.y -= 20;
    }
    self.point = point;
    CGRect frame = self.frame;
    frame.origin = self.point;
    self.frame = frame;
    [self sizeToFit];
    
    self.parentBelow = message;
    message.childAbove = self;
}
- (void)positionBelow:(Message *)message
{
    CGPoint point = message.point;
    if (_iPhoneVersion) {
        point.y += message.bounds.size.height;
    } else {
        point.y += 20;
    }
    self.point = point;
    CGRect frame = self.frame;
    frame.origin = self.point;
    self.frame = frame;
    [self sizeToFit];
    
    self.parentAbove = message;
    message.childBelow = self;
}
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (_iPhoneVersion) {
        CGRect frame = self.frame;
        self.frame = frame;
        [self sizeToFit];
    }
}
- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat maxWidth;
    CGFloat left = self.frame.origin.x;
    if (!self.superview) {
        maxWidth = [[UIScreen mainScreen] bounds].size.width - left*2;
    } else {
        maxWidth = self.superview.bounds.size.width - left*2;
    }
    return [super sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];

    
    if (_iPhoneVersion) {
        CGFloat maxWidth;
        if (!self.superview) {
            maxWidth = [[UIScreen mainScreen] bounds].size.width - kMessageiPhoneMargin*2;
        } else {
            maxWidth = self.superview.bounds.size.width - kMessageiPhoneMargin*2;
        }
        return [super sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    } else {
        return [super sizeThatFits:size];
    }
}
- (void)appendLine:(NSString*)line withDuration:(CGFloat)duration;
{
    [self appendLine:line withDuration:duration forceNewLine:NO];
}

- (void)appendLine:(NSString *)line withDuration:(CGFloat)duration forceNewLine:(BOOL)newLine
{
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = duration;
    [self.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    if (_iPhoneVersion && !newLine) {
        self.text = [self.text stringByAppendingFormat:@" %@", line];
    } else {
        self.text = [self.text stringByAppendingFormat:@"\n%@", line];
    }
    
    [self sizeToFit];
}

@end
