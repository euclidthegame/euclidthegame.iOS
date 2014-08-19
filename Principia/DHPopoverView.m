//
//  DHPopupView.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-19.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHPopoverView.h"


const CGFloat kPopoverWidth = 250;
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


#pragma mark - Main class STPopoverView

// Main class
@interface DHPopoverView ()
{
    CGRect _originFrame;
    NSMutableArray *_buttons;
    UIView* _triangle;
    UIColor *_appTintColor;
}
@property (nonatomic, strong) UIView* container;
@end

@implementation DHPopoverView

- (id)initWithOriginFrame:(CGRect)originFrame delegate:(UIViewController<DHPopoverViewDelegate>*)delegate firstButtonTitle:(NSString*)firstButtonTitle
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    _appTintColor = [[delegate popOverTintColor] copy];
    self = [super initWithFrame:window.bounds];
    if (self) {
        _container = [[UIView alloc] initWithFrame:window.bounds];
        [self addSubview:_container];
        _triangle = [[DHPopoverViewTriangle alloc] initWithFrame:CGRectMake(0, 0, kTriangleWidth, kTriangleHeight)];
        [_container addSubview:_triangle];
        _originFrame = originFrame;
        _delegate = delegate;
        [self setupView];
        [self addButtonWithTitle:firstButtonTitle];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusBarWillRotate:)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    CGFloat rotation = 0;
    switch (orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
            rotation = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotation = M_PI_2;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            rotation = M_PI;
            break;
        case UIInterfaceOrientationPortrait:
        default:
            rotation = 0;
            break;
    }
    
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(rotation);
    CGSize rotatedSize = CGRectApplyAffineTransform(window.bounds, rotationTransform).size;
    
    self.container.transform = rotationTransform;
    // Transform invalidates the frame, so use bounds/center
    self.container.bounds = CGRectMake(0, 0, rotatedSize.width, rotatedSize.height);
    self.container.center = CGPointMake(window.bounds.size.width / 2, window.bounds.size.height / 2);
    
    _triangle.frame = CGRectMake(CGRectGetMidX(_originFrame)-kTriangleWidth/2, CGRectGetMaxY(_originFrame)+10, kTriangleWidth, kTriangleHeight);
    for (UIButton* button in _buttons) {
        CGRect buttonFrame = CGRectMake(rotatedSize.width-kPopoverWidth-10, CGRectGetMaxY(_originFrame)+25+button.tag*54, kPopoverWidth, 44);
        [button setFrame:buttonFrame];
    }
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
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopoverView)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer: singleTap];
}

- (NSInteger)addButtonWithTitle:(NSString*)title enabled:(BOOL)enabled
{
    NSInteger buttonIndex;
    
    if(!_buttons) {
        _buttons = [NSMutableArray array];
    }
    buttonIndex = _buttons.count;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    //[button setTintColor:_appTintColor];
    [button setTitleColor:_appTintColor forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    button.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    button.layer.cornerRadius = 5;
    button.tag = buttonIndex;
    [button addTarget:self
               action:@selector(buttonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
    [_buttons addObject:button];
    [self.container addSubview:button];
    button.enabled = enabled;
    
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

- (void)show
{
    [self rotateToOrientation:[_delegate interfaceOrientation]];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    window.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
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
