//
//  DHMagnifyingView.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-24.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHMagnifyingView.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kACLoupeDefaultRadius = 64;
static CGFloat const kACLoupeDefaultOffset = -54;

static CGFloat const kACMagnifyingGlassDefaultRadius = 40;
static CGFloat const kACMagnifyingGlassDefaultOffset = -40;
static CGFloat const kACMagnifyingGlassDefaultScale = 1.5;

@implementation DHMagnifyingView

- (id)init {
    self = [self initWithFrame:CGRectMake(0, 0, kACMagnifyingGlassDefaultRadius*2, kACMagnifyingGlassDefaultRadius*2)];
    return self;
}

- (id)initWithLoupe {
    self = [self initWithLoupeInFrame:CGRectMake(0, 0, kACLoupeDefaultRadius*2, kACLoupeDefaultRadius*2)];
    return self;
}

- (id)initWithLoupeInFrame:(CGRect)frame {
	
	if (self = [self initWithFrame:frame]) {
		self.layer.borderWidth = 0;
		self.touchPointOffset = CGPointMake(0, kACLoupeDefaultOffset);
        
        UIImageView *loupeImageView = nil;
        
        loupeImageView = [[UIImageView alloc] initWithFrame:CGRectOffset(CGRectInset(self.bounds, -3.0, -3.0), 0, 2.5)];
        loupeImageView.image = [UIImage imageNamed:@"kb-loupe-hi_7"];
        
		loupeImageView.backgroundColor = [UIColor clearColor];
		[self addSubview:loupeImageView];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		
		self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
		self.layer.borderWidth = 3;
		self.layer.cornerRadius = frame.size.width / 2;
		self.layer.masksToBounds = YES;
		self.touchPointOffset = CGPointMake(0, kACMagnifyingGlassDefaultOffset);
		self.scale = kACMagnifyingGlassDefaultScale;
		self.viewToMagnify = nil;
		self.scaleAtTouchPoint = YES;
	}
	return self;
}

- (void)setFrame:(CGRect)f {
	super.frame = f;
	self.layer.cornerRadius = f.size.width / 2;
}

- (void)setTouchPoint:(CGPoint)point {
	_touchPoint = point;
    //_touchPoint = [self.superview convertPoint:point fromView:self.viewToMagnify];
	self.center = CGPointMake(point.x + _touchPointOffset.x, point.y + _touchPointOffset.y);
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, (CGRect){CGPointZero, rect.size});
	CGContextTranslateCTM(context, self.frame.size.width/2, self.frame.size.height/2 );
	CGContextScaleCTM(context, _scale, _scale);
	CGContextTranslateCTM(context, -_touchPoint.x, -_touchPoint.y +
                          (self.scaleAtTouchPoint? 0 : self.bounds.size.height/2));
	[self.viewToMagnify.layer renderInContext:context];
}

@end
