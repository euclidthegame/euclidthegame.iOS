//
//  DHGeometricTransform.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-10.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGeometricTransform.h"

@implementation DHGeometricTransform {
    CGFloat _geoTransformScale;
    CGFloat _geoTransformRotation;
    CGPoint _geoTransformOffset;
}

- (id)init
{
    self = [super init];
    if (self) {
        _geoTransformScale = 1;
        _geoTransformOffset = CGPointMake(0, 0);
    }
    return self;
}

- (CGFloat)scale
{
    return _geoTransformScale;
}

- (CGPoint) offset
{
    return _geoTransformOffset;
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
    // Cap the scale to between 0.1x and 2x
    if (_geoTransformScale > 2) {
        _geoTransformScale = 2;
    }
    if (_geoTransformScale < 0.1) {
        _geoTransformScale = 0.1;
    }
    
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
    
    // Cap the scale to between 0.1x and 2x
    if (_geoTransformScale > 2) {
        _geoTransformScale = 2;
    }
    if (_geoTransformScale < 0.1) {
        _geoTransformScale = 0.1;
    }
    
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
