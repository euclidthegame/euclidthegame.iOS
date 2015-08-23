//
//  DHTransitionFromLevel.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-03.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHTransitionFromLevel.h"
#import "DHLevelSelection2ViewController.h"
#import "DHLevelSelection2LevelCell.h"
#import "DHLevelViewController.h"

@implementation DHTransitionFromLevel
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    DHLevelViewController* fromViewController =
    (DHLevelViewController*)[transitionContext
                             viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    DHLevelSelection2ViewController* toViewController =
    (DHLevelSelection2ViewController*)[transitionContext
                                       viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    [containerView addSubview:toViewController.view];
    [containerView addSubview:fromViewController.view];
    
    NSInteger indexPathItem;
    NSInteger indexPathSection;
    NSInteger levelIndex = fromViewController.levelIndex;
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
    DHLevelSelection2LevelCell *cell = (DHLevelSelection2LevelCell*)[toViewController
                                                                     collectionView:toViewController.collectionView
                                                                     cellForItemAtIndexPath:
                                                                     [NSIndexPath
                                                                      indexPathForItem:indexPathItem
                                                                      inSection:indexPathSection]
                                                                     ];
    
    CGRect fromFrame = [transitionContext initialFrameForViewController:fromViewController];
    CGRect toFrame = [containerView convertRect:cell.frame fromView:cell.superview];
    
    fromViewController.view.alpha = 1.0;
    fromViewController.view.transform = CGAffineTransformIdentity;
    
    CGAffineTransform targetTransform = CGAffineTransformMakeScale(toFrame.size.width/fromFrame.size.width,
                                                                   toFrame.size.height/fromFrame.size.height);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        // Fade in the second view controller's view
        fromViewController.view.alpha = 0.3;
        fromViewController.view.layer.anchorPoint = CGPointMake(0, 0);
        fromViewController.view.layer.position = toFrame.origin;
        fromViewController.view.transform = targetTransform;
    } completion:^(BOOL finished) {
        // Clean up
        // Declare that we've finished
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
