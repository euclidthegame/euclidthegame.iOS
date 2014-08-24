//
//  DHMagnifyingView.h
//  Euclid
//
//  Created by David Hallgren on 2014-08-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHMagnifyingView : UIView

@property (nonatomic, retain) UIView *viewToMagnify;
@property (nonatomic, assign) CGPoint touchPoint;
@property (nonatomic, assign) CGPoint touchPointOffset;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) BOOL scaleAtTouchPoint;

- (id)initWithLoupe;

@end
