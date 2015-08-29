//
//  DHPopupView.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-19.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHPopoverView.h"


const CGFloat kPopoverWidth = 180;
const CGFloat kTriangleHeight = 17;
const CGFloat kTriangleWidth = 20;

#pragma mark - Helper class

// Helper class for drawing the triangle
@interface DHPopoverViewTriangle : UIView
@end
@implementation DHPopoverViewTriangle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
        self.alpha = 1;
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect triRect = CGRectMake(0, 0, kTriangleWidth, kTriangleHeight);
    //CGRectMake(CGRectGetMidX(_originFrame)-kTriangleWidth/2, CGRectGetMaxY(_originFrame)+10, kTriangleWidth, kTriangleHeight);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint   (ctx, CGRectGetMinX(triRect), CGRectGetMaxY(triRect));  // bottom left
    CGContextAddLineToPoint(ctx, CGRectGetMidX(triRect), CGRectGetMinY(triRect));  // top center
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(triRect), CGRectGetMaxY(triRect));  // bottom right
    CGContextClosePath(ctx);
    
    CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);
    CGContextFillPath(ctx);
}
@end


// Helper class for drawing the separators
@interface DHPopoverViewSeparator : UIView
@end
@implementation DHPopoverViewSeparator
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
        self.alpha = 1;
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
    CGContextMoveToPoint   (ctx, 0, 0);
    CGContextAddLineToPoint(ctx, self.frame.size.width, 0);
    CGContextClosePath(ctx);
    
    CGContextSetLineWidth(ctx, 0.5);
    
    CGContextSetRGBStrokeColor(ctx, 0.6, 0.6, 0.6, 1);
    CGContextStrokePath(ctx);
}
@end


#pragma mark - Main class PopoverView

// Main class
@implementation DHPopoverView {
    CGRect _originFrame;
    NSMutableArray *_buttons;
    NSMutableArray *_separators;
    UIView* _triangle;
    UIColor *_appTintColor;
    UIView* _container;
    UIView* _menuBackground;
}

- (id)initWithOriginFrame:(CGRect)originFrame delegate:(UIViewController<DHPopoverViewDelegate>*)delegate firstButtonTitle:(NSString*)firstButtonTitle
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    _appTintColor = [[delegate popOverTintColor] copy];
    self = [super initWithFrame:window.bounds];
    if (self) {
        self.verticalDirection = DHPopoverViewVerticalDirectionDown;
        self.width = kPopoverWidth;
        self.buttonHeight = 44.0;
        self.separatorInset = 15.0;
        
        _menuBackground = [[UIView alloc] initWithFrame:window.bounds];
        _menuBackground.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
        _menuBackground.layer.cornerRadius = 5.0;
        _menuBackground.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        _menuBackground.layer.shadowRadius = 5.0;
        _menuBackground.layer.shadowOffset = CGSizeMake(3, 3);
        _menuBackground.layer.shadowOpacity = 0.5;
        
        _container = [[UIView alloc] initWithFrame:window.bounds];
        [self addSubview:_container];
        [_container addSubview:_menuBackground];
        
        _triangle = [[DHPopoverViewTriangle alloc] initWithFrame:CGRectMake(0, 0, kTriangleWidth, kTriangleHeight)];
        [_container addSubview:_triangle];
        _originFrame = originFrame;
        _delegate = delegate;
        [self setupView];
        
        if (firstButtonTitle) {
            [self addButtonWithTitle:firstButtonTitle];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusBarWillRotate:)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    // TODO: Clean up this function, previously required to rotate view with orientation, now works automatically
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }

    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(0);
    CGSize rotatedSize = CGRectApplyAffineTransform(window.bounds, rotationTransform).size;
    
    const CGFloat buttonHeight = self.buttonHeight;
    
    _container.transform = rotationTransform;
    // Transform invalidates the frame, so use bounds/center
    _container.bounds = CGRectMake(0, 0, rotatedSize.width, rotatedSize.height);
    _container.center = CGPointMake(window.bounds.size.width / 2, window.bounds.size.height / 2);
    
    for (UIButton* button in _buttons) {
        CGRect buttonFrame = CGRectMake(0,button.tag*buttonHeight,_width, buttonHeight);
        [button setFrame:buttonFrame];
    }
    for (NSInteger i = 0; i < _separators.count; ++i) {
        CGRect sepFrame = CGRectMake(self.separatorInset,(i+1)*buttonHeight, _width-self.separatorInset*2, 1);
        [_separators[i] setFrame:sepFrame];
    }
    
    CGFloat menuFrameY = CGRectGetMaxY(_originFrame)+25;
    CGFloat menuFrameHeight = buttonHeight*(_buttons.count);
    _triangle.frame = CGRectMake(CGRectGetMidX(_originFrame)-kTriangleWidth/2,
                                 CGRectGetMaxY(_originFrame)+10, kTriangleWidth, kTriangleHeight);
    
    if (self.verticalDirection == DHPopoverViewVerticalDirectionUp) {
        menuFrameY = CGRectGetMinY(_originFrame) - 10 - (menuFrameHeight + kTriangleHeight) + 2;
        _triangle.frame = CGRectMake(CGRectGetMidX(_originFrame)-kTriangleWidth/2,
                                     CGRectGetMinY(_originFrame)-10-kTriangleHeight, kTriangleWidth, kTriangleHeight);
        _triangle.transform = CGAffineTransformMakeRotation(M_PI);
    }
    _menuBackground.frame = CGRectMake(rotatedSize.width-_width-10, menuFrameY,
                                       _width, menuFrameHeight);
}

- (void)statusBarWillRotate:(NSNotification *)notification
{
    [self dismissWithAnimation:NO];
    [_delegate popoverViewDidClose:self];
}

- (void)setupView
{
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    self.alpha = 0;
    self.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    [UIView beginAnimations:@"animateInPopOverView" context:nil];
    [UIView setAnimationDuration:0.4];
    self.alpha = 1;
    [UIView commitAnimations];
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(closePopoverView)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [_container addGestureRecognizer: singleTap];
}

- (NSInteger)addButtonWithImage:(UIImage *)image enabled:(BOOL)enabled
{
    NSInteger buttonIndex;
    
    if(!_buttons) _buttons = [NSMutableArray array];
    if (!_separators) _separators = [NSMutableArray array];
    buttonIndex = _buttons.count;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setImage:image forState:UIControlStateNormal];
    button.tag = buttonIndex;
    [button addTarget:self
               action:@selector(buttonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    [_buttons addObject:button];
    [_menuBackground addSubview:button];
    button.enabled = enabled;
    
    if (_buttons.count > 1) {
        DHPopoverViewSeparator* separator = [[DHPopoverViewSeparator alloc] init];
        [_separators addObject:separator];
        [_menuBackground addSubview:separator];
    }
    
    return buttonIndex;
}

- (NSInteger)addButtonWithTitle:(NSString*)title enabled:(BOOL)enabled
{
    NSInteger buttonIndex;
    
    if(!_buttons) _buttons = [NSMutableArray array];
    if (!_separators) _separators = [NSMutableArray array];
    buttonIndex = _buttons.count;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:_appTintColor forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    button.tag = buttonIndex;
    [button addTarget:self
               action:@selector(buttonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    [_buttons addObject:button];
    [_menuBackground addSubview:button];
    button.enabled = enabled;
    
    if (_buttons.count > 1) {
        DHPopoverViewSeparator* separator = [[DHPopoverViewSeparator alloc] init];
        [_separators addObject:separator];
        [_menuBackground addSubview:separator];
    }
    
    return buttonIndex;
}
- (NSInteger)addButtonWithTitle:(NSString*)title
{
    return [self addButtonWithTitle:title enabled:YES];
}

- (void)buttonPressed:(UIButton*)sender{
    [_delegate popoverView:self clickedButtonAtIndex:sender.tag];
}

- (void)closePopoverView {
    [_delegate closePopoverView:self];
}

- (NSString*)titleForButton:(NSInteger)buttonIndex
{
    UIButton* button = [_buttons objectAtIndex:buttonIndex];
    return [button titleForState:UIControlStateNormal];
}

- (UIImage *)imageForButton:(NSInteger)buttonIndex
{
    UIButton* button = [_buttons objectAtIndex:buttonIndex];
    return [button imageForState:UIControlStateNormal];
}

- (void)show
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    window.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;

    [self rotateToOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    [window addSubview:self];
}

- (void)dismissWithAnimation:(BOOL)animated
{
    self.superview.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    [self.superview tintColorDidChange];
    
    if(animated) {
        [UIView animateWithDuration:0.4 delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{ self.alpha = 0.0;}
                         completion:^(BOOL fin) {
                             if (fin) {
                                 [self removeFromSuperview];
                             }
                         }];
    } else {
        [self removeFromSuperview];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
