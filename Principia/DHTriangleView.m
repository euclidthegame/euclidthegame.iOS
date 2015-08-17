//
//  DHTriangleView.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-25.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHTriangleView.h"

@implementation DHTriangleView
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
    CGRect triRect = rect;
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint   (ctx, CGRectGetMinX(triRect), CGRectGetMaxY(triRect));  // bottom left
    CGContextAddLineToPoint(ctx, CGRectGetMidX(triRect), CGRectGetMinY(triRect));  // top center
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(triRect), CGRectGetMaxY(triRect));  // bottom right
    CGContextClosePath(ctx);
    
    CGContextSetFillColorWithColor(ctx, self.superview.tintColor.CGColor);
    CGContextFillPath(ctx);

    /*CGContextBeginPath(ctx);
    CGContextMoveToPoint   (ctx, CGRectGetMinX(triRect), CGRectGetMaxY(triRect));  // bottom left
    CGContextAddLineToPoint(ctx, CGRectGetMidX(triRect), CGRectGetMinY(triRect));  // top center
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(triRect), CGRectGetMaxY(triRect));  // bottom right
    CGContextClosePath(ctx);
    
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
    CGContextStrokePath(ctx);*/
}
- (void)tintColorDidChange
{
    [super tintColorDidChange];
    [self setNeedsDisplay];
}
@end
