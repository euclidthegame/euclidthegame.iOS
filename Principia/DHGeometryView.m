//
//  DHGeometryView.m
//  Principia
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometryView.h"

@implementation DHGeometryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (id object in self.geometricObjects) {
        [object drawInContext:context];
    }
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1.0);
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0);
    CGContextStrokePath(context);
}

@end
