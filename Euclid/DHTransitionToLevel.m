//
//  DHTransitionToLevel.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-03.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHTransitionToLevel.h"
#import "DHLevelSelection2ViewController.h"
#import "DHLevelSelection2LevelCell.h"
#import "DHLevelViewController.h"

@implementation DHTransitionToLevel

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.6;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    DHLevelSelection2ViewController *fromViewController = (DHLevelSelection2ViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    DHLevelViewController *toViewController = (DHLevelViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toViewController.view];
    
    NSInteger indexPathItem;
    NSInteger indexPathSection;
    NSInteger levelIndex = toViewController.levelIndex;
    if (levelIndex < 10) {
        indexPathItem = levelIndex;
        indexPathSection = 0;
    } else if (levelIndex < 20) {
        indexPathItem = levelIndex-10;
        indexPathSection = 1;
    } else {
        indexPathItem = levelIndex-20;
        indexPathSection = 2;
        
    }
    
    // Get a snapshot of the thing cell we're transitioning from
    DHLevelSelection2LevelCell *cell = (DHLevelSelection2LevelCell*)[fromViewController.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:indexPathItem inSection:indexPathSection]];
    
    CGRect fromFrame = [containerView convertRect:cell.frame fromView:cell.superview];
    CGRect toFrame = [transitionContext finalFrameForViewController:toViewController];
    
    toViewController.view.alpha = 0.3;
    toViewController.view.frame = toFrame;
    toViewController.view.clipsToBounds = YES;
    toViewController.view.layer.anchorPoint = CGPointMake(0, 0);
    toViewController.view.layer.position = fromFrame.origin;
    toViewController.view.transform = CGAffineTransformMakeScale(fromFrame.size.width/toFrame.size.width,
                                                                 fromFrame.size.height/toFrame.size.height);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        // Fade in the second view controller's view
        toViewController.view.alpha = 1.0;
        toViewController.view.transform = CGAffineTransformIdentity;
        toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
        
    } completion:^(BOOL finished) {
        // Clean up
        // Declare that we've finished
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
