//
//  DHGeometryView.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometryView.h"

@implementation DHGeometryView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        _geoViewTransform = [[DHGeometricTransform alloc] init];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _geoViewTransform = [[DHGeometricTransform alloc] init];
       
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self.keepContentCenteredAndZoomedIn) {
        const CGFloat pointMargin = 20.0;

        // Determine size of contents and scale/translate view to fit and center all items
        CGFloat minX = CGFLOAT_MAX;
        CGFloat minY = CGFLOAT_MAX;
        CGFloat maxX = CGFLOAT_MIN;
        CGFloat maxY = CGFLOAT_MIN;
        for (id<DHGeometricObject> object in self.geometricObjects) {
            if ([[object class] isSubclassOfClass:[DHPoint class]]) {
                DHPoint* p = object;
                CGPoint pos = p.position;
                
                if (pos.x + pointMargin > maxX) maxX = pos.x + pointMargin;
                if (pos.y + pointMargin > maxY) maxY = pos.y + pointMargin;
                if (pos.x - pointMargin < minX) minX = pos.x - pointMargin;
                if (pos.y - pointMargin < minY) minY = pos.y - pointMargin;
            }

            if ([[object class] isSubclassOfClass:[DHLineSegment class]]) {
                {
                    DHLineSegment* l = object;
                    CGPoint pos = l.start.position;
                    
                    if (pos.x + pointMargin > maxX) maxX = pos.x + pointMargin;
                    if (pos.y + pointMargin > maxY) maxY = pos.y + pointMargin;
                    if (pos.x - pointMargin < minX) minX = pos.x - pointMargin;
                    if (pos.y - pointMargin < minY) minY = pos.y - pointMargin;
                }
                {
                    DHLineSegment* l = object;
                    CGPoint pos = l.end.position;
                    
                    if (pos.x + pointMargin > maxX) maxX = pos.x + pointMargin;
                    if (pos.y + pointMargin > maxY) maxY = pos.y + pointMargin;
                    if (pos.x - pointMargin < minX) minX = pos.x - pointMargin;
                    if (pos.y - pointMargin < minY) minY = pos.y - pointMargin;
                }
            }
            
            if ([[object class] isSubclassOfClass:[DHCircle class]]) {
                DHCircle* c = object;
                CGPoint pos = c.center.position;
                CGFloat radius = c.radius;
                
                if (pos.x + radius > maxX) maxX = pos.x + radius;
                if (pos.y + radius > maxY) maxY = pos.y + radius;
                if (pos.x - radius < minX) minX = pos.x - radius;
                if (pos.y - radius < minY) minY = pos.y - radius;
            }
        }
        CGSize geoViewSize = self.frame.size;
        CGFloat scaleX = (geoViewSize.width-30) / (maxX - minX);
        CGFloat scaleY = (geoViewSize.height-30) / (maxY - minY);
        CGFloat scale = MIN(scaleX, scaleY);
        // Cap the scale to between 0.1x and 2x
        if (scale > 2) {
            scale = 2;
        }
        if (scale < 0.1) {
            scale = 0.1;
        }
        
        [self.geoViewTransform setScale:scale];
        CGPoint center = CGPointMake((maxX+minX)*0.5, (maxY+minY)*0.5);
        CGPoint centerView = [self.geoViewTransform geoToView:center];
        CGPoint offset = CGPointMake(-(centerView.x - geoViewSize.width*0.5), -(centerView.y - geoViewSize.height*0.5));
        [self.geoViewTransform setOffset:offset];
    }

    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (id<DHGeometricObject> object in self.geometricObjects) {
        [object drawInContext:context withTransform:self.geoViewTransform];
    }
    
    if (!self.hideBorder) {
        CGContextSetLineWidth(context, 1.0/self.contentScaleFactor);
        CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
        CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1.0);
        
        CGContextMoveToPoint(context, 0, self.bounds.size.height-1.0/self.contentScaleFactor);
        CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height-1.0/self.contentScaleFactor);
        
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, self.bounds.size.width, 0);
        CGContextStrokePath(context);
    }
}

@end
