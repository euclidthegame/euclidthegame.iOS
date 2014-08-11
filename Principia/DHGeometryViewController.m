//
//  DHViewController.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometryViewController.h"
#import "DHGeometryView.h"
#import "DHMath.h"

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
    NSArray *allTouches = [[event allTouches] allObjects];
    if ([allTouches count] == 2) {
        twoFingers = YES;
        [_currentTool reset];
        [_currentTool.delegate toolTipDidChange:@"Use two fingers to pan or zoom"];
    }
    else {
        twoFingers = NO;
        for (UITouch* touch in touches) {
            if ([_currentTool associatedTouch] == 0) {
                [_currentTool setAssociatedTouch:(intptr_t)touch];
                [_currentTool touchBegan:touch];
            }
        }
    }
    
    if ([self.currentLevel respondsToSelector:@selector(hideHint)] && self.currentLevel.showingHint) {
        [self.currentLevel hideHint];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
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



@end
