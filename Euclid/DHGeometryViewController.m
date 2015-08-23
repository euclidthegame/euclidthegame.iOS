//
//  DHViewController.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGeometryViewController.h"
#import "DHGeometryView.h"
#import "DHMath.h"
#import "DHMagnifyingView.h"
#import "DHSettings.h"

static CGFloat const kACMagnifyingViewDefaultShowDelay = 0.5;

@interface DHGeometryViewController ()
@property (nonatomic, strong) DHMagnifyingView *magnifyingGlass;
@property (nonatomic, strong) NSTimer *touchTimer;
- (void)addMagnifyingGlassAtPoint:(CGPoint)point;
- (void)removeMagnifyingGlass;
- (void)updateMagnifyingGlassAtPoint:(CGPoint)point;
@end


@implementation DHGeometryViewController {
    CGFloat _lastScale;
    CGPoint _lastPoint;
    BOOL twoFingers;
}

#pragma mark Life-cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Manage input
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.currentLevel respondsToSelector:@selector(hideHint)] && self.currentLevel.showingHint) {
        return;
    }

    NSArray *allTouches = [[event allTouches] allObjects];
    if ([allTouches count] == 2) {
        twoFingers = YES;
        [self removeMagnifyingGlass];
        [_currentTool reset];
        [_currentTool.delegate toolTipDidChange:@"Use two fingers to pan or zoom"];
    }
    else {
        twoFingers = NO;
        
        if ([DHSettings magnifierEnabled]) {
            UITouch *touch = [touches anyObject];
            
            _magnifyingGlass = [[DHMagnifyingView alloc] initWithLoupe];
            _magnifyingGlass.scale = 1.2;
            _magnifyingGlass.touchPoint = [touch locationInView:self.geometryView];

            NSValue* userInfo = [NSValue valueWithCGPoint:[touch locationInView:self.geometryView]];
            self.touchTimer = [NSTimer scheduledTimerWithTimeInterval:kACMagnifyingViewDefaultShowDelay
                                                               target:self
                                                             selector:@selector(addMagnifyingGlassTimer:)
                                                             userInfo:userInfo
                                                              repeats:NO];
        }
        
        for (UITouch* touch in touches) {
            if ([_currentTool associatedTouch] == 0) {
                [_currentTool setAssociatedTouch:(intptr_t)touch];
                [_currentTool touchBegan:touch];
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.currentLevel respondsToSelector:@selector(hideHint)] && self.currentLevel.showingHint) {
        return;
    }
    
    if (twoFingers){
        NSArray *allTouches = [[event allTouches] allObjects];
        if ([allTouches count] == 2) {
            UITouch *touchA = [allTouches objectAtIndex:0];
            UITouch *touchB = [allTouches objectAtIndex:1];
            
            CGPoint pointA_ = [touchA locationInView:self.view];
            CGPoint pointA = [touchA previousLocationInView:self.view];
            
            CGPoint pointB_ = [touchB locationInView:self.view];
            CGPoint pointB = [touchB previousLocationInView:self.view];
            
            // First, move A to A’ by using a Translation with vector AA’, B is also moved to B1
            CGPoint vectorAA_ = CGPointMake(pointA_.x - pointA.x, pointA_.y - pointA.y);
            [self.geometryView.geoViewTransform offsetWithVector:vectorAA_];
            
            // Calculate B1
            CGPoint pointB1 = CGPointMake(pointB.x + vectorAA_.x, pointB.y + vectorAA_.y);
            
            // Second, move B1 to B2 by using a resize with origin in A’, scale A’B'/A’B1
            CGFloat scale = DistanceBetweenPoints(pointA_, pointB_) / DistanceBetweenPoints(pointA_, pointB1);
            [self.geometryView.geoViewTransform zoomAtPoint:pointA_ scale:scale];
            
            // Finally, use a Rotation with origin A’, angle (AB, A’B') to make vector A’B2 to same direction with A’B',
            // B2 is moved to B’
            CGVector vectorAB = CGVectorBetweenPoints(pointA, pointB);
            CGVector vectorA_B_ = CGVectorBetweenPoints(pointA_, pointB_);
            CGFloat rotation = CGVectorAngleBetween(vectorAB, vectorA_B_);
            
            [self.geometryView.geoViewTransform rotateBy:rotation];
            
            [self.view setNeedsDisplay];
        }
        
        return;
    }
    
    UITouch *touch = [touches anyObject];
    [self updateMagnifyingGlassAtPoint:[touch locationInView:self.geometryView]];
    for (UITouch* touch in touches) {
        if ([_currentTool associatedTouch] == (intptr_t)touch) {
            [_currentTool touchMoved:touch];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self removeMagnifyingGlass];
    
    if ([self.currentLevel respondsToSelector:@selector(hideHint)] && self.currentLevel.showingHint) {
        [self.currentLevel hideHint];
        return;
    }
    
    if (twoFingers) {
        [_currentTool.delegate toolTipDidChange:_currentTool.initialToolTip];
        twoFingers = NO;
    }
    
    for (UITouch* touch in touches) {
        if ([_currentTool associatedTouch] == (intptr_t)touch) {
            [_currentTool touchEnded:touch];
            [_currentTool setAssociatedTouch:0];
        }
    }
}

#pragma mark Layout/appereance
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - private functions

- (void)addMagnifyingGlassTimer:(NSTimer*)timer {
	NSValue *v = timer.userInfo;
	CGPoint point = [v CGPointValue];
	[self addMagnifyingGlassAtPoint:point];
}

#pragma mark - magnifier functions

- (void)addMagnifyingGlassAtPoint:(CGPoint)point {
	
	if (!_magnifyingGlass) {
		_magnifyingGlass = [[DHMagnifyingView alloc] initWithLoupe];
        _magnifyingGlass.scale = 1.2;
        _magnifyingGlass.touchPoint = point;
	}
	
	if (!_magnifyingGlass.viewToMagnify) {
		_magnifyingGlass.viewToMagnify = self.geometryView;
		
	}
	[[[UIApplication sharedApplication] keyWindow] addSubview:_magnifyingGlass];
	[_magnifyingGlass setNeedsDisplay];
}

- (void)removeMagnifyingGlass
{
    [self.touchTimer invalidate];
	self.touchTimer = nil;
	[_magnifyingGlass removeFromSuperview];
}

- (void)updateMagnifyingGlassAtPoint:(CGPoint)point
{
	_magnifyingGlass.touchPoint = point;
	[_magnifyingGlass setNeedsDisplay];
}

@end
