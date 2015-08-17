//
//  DHIntersectTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHIntersectTool {
    DHPoint* _tempIntersectionPoint;
    DHGeometricObject* _tempObject1;
    DHGeometricObject* _tempObject2;
}
- (NSString*)initialToolTip
{
    return @"Tap an intersection between two lines/circles to add a new point";
}
- (void)touchBegan:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    NSArray* geoObjects = self.delegate.geometryObjects;
    
    DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects, geoViewScale);
    if (intersectionPoint) {
        _tempIntersectionPoint = intersectionPoint;
        [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionPoint]];
        
        if ([_tempIntersectionPoint isKindOfClass:[DHIntersectionPointLineLine class]]) {
            DHIntersectionPointLineLine* ip = (DHIntersectionPointLineLine*)_tempIntersectionPoint;
            _tempObject1 = ip.l1;
            _tempObject2 = ip.l2;
        }
        if ([_tempIntersectionPoint isKindOfClass:[DHIntersectionPointLineCircle class]]) {
            DHIntersectionPointLineCircle* ip = (DHIntersectionPointLineCircle*)_tempIntersectionPoint;
            _tempObject1 = ip.l;
            _tempObject2 = ip.c;
        }
        if ([_tempIntersectionPoint isKindOfClass:[DHIntersectionPointCircleCircle class]]) {
            DHIntersectionPointCircleCircle* ip = (DHIntersectionPointCircleCircle*)_tempIntersectionPoint;
            _tempObject1 = ip.c1;
            _tempObject2 = ip.c2;
        }
        _tempObject1.highlighted = YES;
        _tempObject2.highlighted = YES;
        [touch.view setNeedsDisplay];
    }
}
- (void)touchMoved:(UITouch*)touch
{
    if (_tempIntersectionPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionPoint]];
        _tempIntersectionPoint = nil;
        _tempObject1.highlighted = NO;
        _tempObject2.highlighted = NO;
        _tempObject1 = nil;
        _tempObject2 = nil;
        [touch.view setNeedsDisplay];
    }
    [self touchBegan:touch];
}
- (void)touchEnded:(UITouch*)touch
{
    if (_tempIntersectionPoint) {
        [self.delegate addGeometricObject:_tempIntersectionPoint];
        [self reset];
        return;
    }
}
- (BOOL)active
{
    return false;
}
- (void)reset
{
    if (_tempIntersectionPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionPoint]];
        _tempIntersectionPoint = nil;
    }
    _tempObject1.highlighted = NO;
    _tempObject2.highlighted = NO;
    _tempObject1 = nil;
    _tempObject2 = nil;
    self.associatedTouch = 0;
}
- (void)dealloc
{
    [self reset];
}
@end
