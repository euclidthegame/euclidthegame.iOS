//
//  DHGeometryView.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
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
        self.backgroundColor = [UIColor whiteColor];
       
    }
    return self;
}

//makes a hidden "subview" of a geometryView
- (instancetype)initWithObjects:(NSArray*)objects andSuperView:(DHGeometryView*)geometryView
{
    self = [super initWithFrame:geometryView.frame];
    if (self) {
        // Initialization code
        _geoViewTransform = [[DHGeometricTransform alloc] init];
        self.hideBorder = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        self.opaque = NO;
        [_geoViewTransform setOffset:geometryView.geoViewTransform.offset];
        [_geoViewTransform setScale:geometryView.geoViewTransform.scale];
        self.geometricObjects = [[NSMutableArray alloc]initWithArray:objects];
        [self.layer setValue:[NSNumber numberWithFloat:0.0] forKeyPath:@"opacity"];
    }
    return self;
}

//makes a hidden "subview" of a geometryView and adds to a view as subivew
- (instancetype)initWithObjects:(NSArray*)objects supView:(DHGeometryView*)geometryView addTo:(UIView*)view
{
    self = [super initWithFrame:geometryView.frame];
    if (self) {
        // Initialization code
        _geoViewTransform = [[DHGeometricTransform alloc] init];
        self.hideBorder = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        self.opaque = NO;
        [_geoViewTransform setOffset:geometryView.geoViewTransform.offset];
        [_geoViewTransform setScale:geometryView.geoViewTransform.scale];
        self.geometricObjects = [[NSMutableArray alloc]initWithArray:objects];
        [self.layer setValue:[NSNumber numberWithFloat:0.0] forKeyPath:@"opacity"];
        [view addSubview:self];
    }
    return self;
}

//makes an animation view
- (instancetype)initWithObjects:(NSArray*)objects andSuperView:(UIView*)view andGeometryView:(DHGeometryView*)geometryView
{
    self = [super initWithFrame:CGRectMake(geometryView.frame.origin.x,geometryView.frame
                                           .origin.y,view.frame.size.width,view.frame.size.height)];
    if (self) {
        // Initialization code
        _geoViewTransform = [[DHGeometricTransform alloc] init];
        self.hideBorder = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        self.opaque = NO;
        CGPoint relativeOffset = [geometryView.superview convertPoint:geometryView.frame.origin toView:view];
        CGPoint newOffset = CGPointMake(geometryView.geoViewTransform.offset.x+relativeOffset.x, geometryView.geoViewTransform.offset.y+relativeOffset.y);
        [_geoViewTransform setOffset:newOffset];
        [_geoViewTransform setScale:geometryView.geoViewTransform.scale];
        self.geometricObjects = [[NSMutableArray alloc]initWithArray:objects];    }
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
            
            if ([[object class] isSubclassOfClass:[DHLine class]]) {
                DHLine* l = object;
                CGPoint pos = l.start.position;
                CGPoint pos2 = l.end.position;
                
                if (pos.x == pos2.x) {
                    if (pos.x + pointMargin > maxX) maxX = pos.x + pointMargin;
                    if (pos.x - pointMargin < minX) minX = pos.x - pointMargin;
                }
                if (pos.y == pos2.y) {
                    if (pos.y + pointMargin > maxY) maxY = pos.y + pointMargin;
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
    
    for (id<DHGeometricObject> object in self.temporaryGeometricObjects) {
        if ([[object class] isSubclassOfClass:[DHPoint class]] == NO)
            [object drawInContext:context withTransform:self.geoViewTransform];
    }
    for (id<DHGeometricObject> object in self.geometricObjects) {
        [object drawInContext:context withTransform:self.geoViewTransform];
    }
    for (id<DHGeometricObject> object in self.temporaryGeometricObjects) {
        if ([[object class] isSubclassOfClass:[DHPoint class]])
            [object drawInContext:context withTransform:self.geoViewTransform];
    }
    
    if (!self.hideBorder) {
        CGContextSetLineWidth(context, 1.0/self.contentScaleFactor);
        CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
        CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1.0);
        
        if (!self.hideBottomBorder) {
            CGContextMoveToPoint(context, 0, self.bounds.size.height-1.0/self.contentScaleFactor);
            CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height-1.0/self.contentScaleFactor);
        }
        
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, self.bounds.size.width, 0);
        CGContextStrokePath(context);
    }
}

- (void)centerContent
{
    if (self.geometricObjects.count == 0) {
        return;
    }
    
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
    CGPoint center = CGPointMake((maxX+minX)*0.5, (maxY+minY)*0.5);
    CGPoint centerView = [self.geoViewTransform geoToView:center];
    CGPoint offset = CGPointMake(-(centerView.x - geoViewSize.width*0.5), -(centerView.y - geoViewSize.height*0.5));
    
    [self.geoViewTransform offsetWithVector:offset];
}

- (CGPoint)getCenterInGeoCoordinates
{
    return [self.geoViewTransform viewToGeo:self.center];
}

- (void)centerOnGeoCoordinate:(CGPoint)geoCoord
{
    CGPoint currentCenter = [self.geoViewTransform viewToGeo:self.center];
    CGPoint offset = CGPointMake(-(geoCoord.x - currentCenter.x), -(geoCoord.y - currentCenter.y));
    [self.geoViewTransform offsetWithVector:offset];
}

@end
