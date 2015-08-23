//
//  DHGameModeSelectionButton.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-18.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGameModeSelectionButton.h"

@implementation DHGameModeSelectionButton {
    BOOL _selected;
    id _target;
    SEL _action;
    
    BOOL _iPhoneVersion;
    DHGameModePercentCompleteView* _percentCompleteView;
    UILabel* _titleLabel;
    UILabel* _descriptionLabel;
    UILabel* _difficultyDescriptionLabel;
    
    CGFloat _shadowRadius;
    CGFloat _shadowRadiusSelected;
    CGSize _shadowOffset;
    CGSize _shadowOffsetSelected;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _selected = NO;
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            _iPhoneVersion = YES;
        }
        
        _shadowRadius = 6.0;
        _shadowRadiusSelected = 3.0;
        _shadowOffset = CGSizeMake(3, 3);
        _shadowOffsetSelected = CGSizeMake(1, 1);
        self.layer.cornerRadius = 8.0;
        
        if (_iPhoneVersion) {
            _shadowRadius = 1.5;
            _shadowRadiusSelected = 0;
            _shadowOffset = CGSizeMake(1.0, 1.0);
            self.layer.cornerRadius = 4.0;
        }
        
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = _shadowOffset;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = _shadowRadius;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _titleLabel.textColor = [[UIApplication sharedApplication] delegate].window.tintColor;
        [self addSubview:_titleLabel];
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _descriptionLabel.textColor = [UIColor darkGrayColor];
        [_descriptionLabel setLineBreakMode:NSLineBreakByWordWrapping];
        _descriptionLabel.numberOfLines = 2;
        [self addSubview:_descriptionLabel];
        
        _difficultyDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _difficultyDescriptionLabel.textColor = [UIColor lightGrayColor];
        _difficultyDescriptionLabel.hidden = YES;
        [self addSubview:_difficultyDescriptionLabel];
        _difficultyDescriptionLabel.font = [UIFont systemFontOfSize:11];
        
        if (_iPhoneVersion) {
            _titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
            _descriptionLabel.font = [UIFont systemFontOfSize:13.0];
        } else {
            _titleLabel.font = [UIFont boldSystemFontOfSize:22.0];
            _descriptionLabel.font = [UIFont systemFontOfSize:18.0];
        }
    }
    
    return self;
}
- (void)setTouchActionWithTarget:(id)target andAction:(SEL)action
{
    _target = target;
    _action = action;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self select];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if(!CGRectContainsPoint(self.bounds, touchPoint)) {
        [self deselect];
    } else {
        if (!_selected) [self select];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self deselect];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_selected && _target && _action) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_action];
#pragma clang diagnostic pop
    }
    [self deselect];
}
- (void)select
{
    self.layer.shadowOffset = _shadowOffsetSelected;
    self.layer.shadowRadius = _shadowRadiusSelected;
    _selected = YES;
}
- (void)deselect
{
    if (!_selected) return;
    
    _selected = NO;
    self.layer.shadowOffset = _shadowOffset;
    CABasicAnimation* fadeAnim = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    fadeAnim.fromValue = [NSNumber numberWithFloat:_shadowRadiusSelected];
    fadeAnim.toValue = [NSNumber numberWithFloat:_shadowRadius];
    fadeAnim.duration = 0.5;
    [self.layer addAnimation:fadeAnim forKey:@"shadowRadius"];
    
    // Change the actual data value in the layer to the final value.
    self.layer.shadowRadius = _shadowRadius;
    
    //self.layer.shadowRadius = 8.0;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    CGFloat percentCompleteWidth = _iPhoneVersion ? 70:130;
    
    if (_percentCompleteView) {
        _percentCompleteView.frame = CGRectMake(bounds.size.width-percentCompleteWidth, 0,
                                                percentCompleteWidth, bounds.size.height);
    }
    if (_iPhoneVersion) {
        _titleLabel.frame = CGRectMake(8, 5, 150, 15);
        _descriptionLabel.frame = CGRectMake(8, 24, 220, 40);
        [_titleLabel sizeToFit];
        [_descriptionLabel sizeToFit];
        _difficultyDescriptionLabel.frame = CGRectMake(150, 5, 100, 15);
    } else {
        _titleLabel.frame = CGRectMake(20, 0, 200, bounds.size.height);
        _descriptionLabel.frame = CGRectMake(220, 0, 280, bounds.size.height);
        _difficultyDescriptionLabel.frame = CGRectMake(40, bounds.size.height-30, 130, 20);
    }
}
- (BOOL)showPercentComplete
{
    if (_percentCompleteView) {
        return YES;
    }
    return NO;
}
- (void)setShowPercentComplete:(BOOL)showPercentComplete
{
    if (showPercentComplete && !_percentCompleteView) {
        _percentCompleteView = [[DHGameModePercentCompleteView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _percentCompleteView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        [self addSubview:_percentCompleteView];
    } else if (!showPercentComplete && _percentCompleteView) {
        [_percentCompleteView removeFromSuperview];
        _percentCompleteView = nil;
    }
}
- (CGFloat)percentComplete
{
    return _percentCompleteView.percentComplete;
}
- (void)setPercentComplete:(CGFloat)percentComplete
{
    _percentCompleteView.percentComplete = percentComplete;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}
- (NSString *)title
{
    return _titleLabel.text;
}
- (void)setGameModeDescription:(NSString *)gameModeDescription
{
    _descriptionLabel.text = gameModeDescription;
}
- (NSString *)gameModeDescription
{
    return _descriptionLabel.text;
}
- (void)setDifficultyDescription:(NSString *)difficultyDescription
{
    _difficultyDescriptionLabel.text = [@"Difficulty: " stringByAppendingString:difficultyDescription];
    _difficultyDescriptionLabel.hidden = NO;
}
- (NSString *)difficultyDescription
{
    return _difficultyDescriptionLabel.text;
}

- (void)tintColorDidChange
{
    _titleLabel.textColor = self.tintColor;
    [self setNeedsDisplay];
}

@end

@implementation DHGameModePercentCompleteView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    }
    return self;
}
- (void)tintColorDidChange
{
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect
{
    const CGPoint pieChartCenter = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
    CGFloat pieChartRadius = 22.0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.percentComplete == 1.0) {
        // Draw checkmark
        CGContextSetFillColorWithColor(context, self.tintColor.CGColor);
        CGContextSetStrokeColorWithColor(context, self.tintColor.CGColor);
        CGContextMoveToPoint(context, pieChartCenter.x, pieChartCenter.y);
        CGContextAddLineToPoint(context, pieChartCenter.x+pieChartRadius, pieChartCenter.y);
        CGContextAddArc(context, pieChartCenter.x, pieChartCenter.y, pieChartRadius, 0, 2*M_PI, 0);
        CGContextDrawPath(context, kCGPathFillStroke);
        
        CGContextStrokeEllipseInRect(context, CGRectMake(pieChartCenter.x-pieChartRadius,
                                                         pieChartCenter.y-pieChartRadius,
                                                         pieChartRadius*2, pieChartRadius*2));
        
        CGContextSetLineWidth(context, 3.0);
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
        
        CGContextMoveToPoint(context, pieChartCenter.x - pieChartRadius*0.5, pieChartCenter.y);
        CGContextAddLineToPoint(context, pieChartCenter.x - pieChartRadius*0.5 + 7, pieChartCenter.y + 7);
        CGContextAddLineToPoint(context, pieChartCenter.x - pieChartRadius*0.5 + 7 + 14, pieChartCenter.y + 7 - 14);
        CGContextDrawPath(context, kCGPathStroke);
    } else {
        // Write %-complete text
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        NSString* percentLabelText = [NSString stringWithFormat:@"%d%%", (uint)(self.percentComplete*100)];
        NSDictionary* attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                     NSParagraphStyleAttributeName: paragraphStyle,
                                     NSForegroundColorAttributeName: [UIColor darkGrayColor]};
        CGSize textSize = [percentLabelText sizeWithAttributes:attributes];
        CGRect labelRect = CGRectMake(pieChartCenter.x -textSize.width*0.5,
                                      pieChartCenter.y -textSize.height*0.5, textSize.width, textSize.height);
        [percentLabelText drawInRect:labelRect withAttributes:attributes];
        
        // Draw pie-chart
        CGFloat startAngle = -((float)M_PI / 2); // 90 degrees
        CGFloat endAngle = ((2 * (float)M_PI) + startAngle);
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        
        // Create our arc, with the correct angles
        [bezierPath addArcWithCenter:pieChartCenter
                              radius:pieChartRadius
                          startAngle:startAngle
                            endAngle:(endAngle - startAngle) + startAngle
                           clockwise:YES];
        
        [[UIColor colorWithWhite:0.9 alpha:1] setStroke];
        CGContextAddPath(context, bezierPath.CGPath);
        CGContextSetLineWidth(context, 3.0);
        CGContextSetShadowWithColor(context, CGSizeMake(1.0, 1.0), 1.0, [UIColor lightGrayColor].CGColor);
        CGContextStrokePath(context);
        
        UIBezierPath* progress = [UIBezierPath bezierPath];
        
        // Create our arc, with the correct angles
        [progress addArcWithCenter:pieChartCenter
                            radius:pieChartRadius
                        startAngle:startAngle
                          endAngle:(endAngle - startAngle) * (self.percentComplete) + startAngle
                         clockwise:YES];
        
        // Set the display for the path, and stroke it
        progress.lineWidth = 4;
        CGContextSetShadowWithColor(context, CGSizeMake(0.0, 0.0), 0.0, [UIColor lightGrayColor].CGColor);
        [self.tintColor setStroke];
        [progress stroke];
    }
}
- (void)setPercentComplete:(CGFloat)percentComplete
{
    if (percentComplete > 1.0) {
        _percentComplete = 1.0;
    } else if (percentComplete < 0) {
        _percentComplete = 0.0;
    } else {
        _percentComplete = percentComplete;
    }
    [self setNeedsDisplay];
}

@end
