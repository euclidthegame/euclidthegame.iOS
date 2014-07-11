//
//  DHGeometricTransform.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-10.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTransform.h"

@interface DHGeometricTransform () {
    CGFloat _geoTransformScale;
    CGFloat _geoTransformRotation;
    CGPoint _geoTransformOffset;
}
@end


@implementation DHGeometricTransform

- (id)init
{
    self = [super init];
    if (self) {
        _geoTransformScale = 1;
    }
    return self;
}

- (CGFloat)scale
{
    return _geoTransformScale;
}

- (void)setOffset:(CGPoint)offset
{
    _geoTransformOffset = offset;
}

- (void)offsetWithVector:(CGPoint)offset
{
    _geoTransformOffset = CGPointMake(_geoTransformOffset.x + offset.x, _geoTransformOffset.y + offset.y);
}

- (void)setScale:(CGFloat)scale
{
    _geoTransformScale = scale;
}

- (CGPoint)viewToGeo:(CGPoint)point
{
    return CGPointMake((point.x - _geoTransformOffset.x)/_geoTransformScale,
                       (point.y - _geoTransformOffset.y)/_geoTransformScale);
}

- (CGPoint)geoToView:(CGPoint)point
{
    return CGPointMake(point.x*_geoTransformScale + _geoTransformOffset.x,
                       point.y*_geoTransformScale + _geoTransformOffset.y);
}

- (void)zoomAtPoint:(CGPoint)center scale:(CGFloat)scale {
    CGPoint centerInGeo = [self viewToGeo:center];
    
    _geoTransformScale *= scale;
    
    CGPoint centerAfterZoom = [self geoToView:centerInGeo];
    
    CGPoint offset = CGPointMake(center.x - centerAfterZoom.x, center.y - centerAfterZoom.y);
    _geoTransformOffset = CGPointMake(_geoTransformOffset.x + offset.x, _geoTransformOffset.y + offset.y);
}

- (void)rotateBy:(CGFloat)angle
{
    _geoTransformRotation += angle;
}

- (void)setRotation:(CGFloat)angle
{
    _geoTransformRotation = angle;
}

@end
