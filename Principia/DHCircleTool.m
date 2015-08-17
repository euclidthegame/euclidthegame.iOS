//
//  DHCircleTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHCircleTool {
    CGPoint _touchPointInViewStart;
    DHPoint* _tempIntersectionCenter;
    DHPoint* _tempIntersectionRadius;
    DHPoint* _tempPointOnRadius;
    DHCircle* _temporaryCircle;
}
- (NSString*)initialToolTip
{
    return @"Tap on any point to mark the center of a new circle";
}
- (void)touchBegan:(UITouch*)touch
{
    _touchPointInViewStart = [touch locationInView:touch.view];
    
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    NSArray* geoObjects = self.delegate.geometryObjects;
    
    DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
    if (!point) {
        point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects, geoViewScale);
        if (point) {
            if (!self.center) _tempIntersectionCenter = point;
            else _tempIntersectionRadius = point;
        }
    }
    
    if (!self.center && point) {
        self.center = point;
        point.highlighted = true;
        [self.delegate toolTipDidChange:@"Drag to a point that the circle will pass through"];
        
        if (_tempIntersectionCenter) {
            [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionCenter]];
        }
    } else if (self.center) {
        _tempPointOnRadius = [[DHPoint alloc] initWithPosition:touchPoint];
        _temporaryCircle = [[DHCircle alloc] initWithCenter:self.center andPointOnRadius:_tempPointOnRadius];
        if (point && point != self.center) {
            point.highlighted = YES;
            _temporaryCircle.pointOnRadius = point;
            [self.delegate toolTipDidChange:@"Release to create circle"];
        } else {
            _temporaryCircle.temporary = YES;
            [self.delegate toolTipDidChange:@"Drag to a point that the circle will pass through"];
        }
        [self.delegate addTemporaryGeometricObjects:@[_temporaryCircle]];
        if (_tempIntersectionRadius) {
            [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionRadius]];
        }
    }
    [touch.view setNeedsDisplay];
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    NSArray* geoObjects = self.delegate.geometryObjects;
    
    DHToolTempObjectCleanup(_tempIntersectionRadius);
    
    if (!_temporaryCircle && self.center) {
        _tempPointOnRadius = [[DHPoint alloc] initWithPosition:touchPoint];
        _temporaryCircle = [[DHCircle alloc] initWithCenter:self.center andPointOnRadius:_tempPointOnRadius];
        [self.delegate addTemporaryGeometricObjects:@[_temporaryCircle]];
    }
    
    if (_temporaryCircle) {
        _temporaryCircle.pointOnRadius.highlighted = NO;
        _temporaryCircle.pointOnRadius = _tempPointOnRadius;
        _tempPointOnRadius.position = touchPoint;
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects, geoViewScale);
            if (point) _tempIntersectionRadius = point;
        }
        if (!point) {
            point = FindPointClosestToCircle(_temporaryCircle, geoObjects, 8/geoViewScale);
        }
        
        if (point && point != self.center) {
            _temporaryCircle.pointOnRadius = point;
            point.highlighted = YES;
            _temporaryCircle.temporary = NO;
            
            if (_tempIntersectionRadius) [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionRadius]];

            [self.delegate toolTipDidChange:@"Release to create circle"];
        } else {
            [self.delegate toolTipDidChange:@"Drag to a point that the circle will pass through"];
            _temporaryCircle.temporary = YES;
        }
    }
    [touch.view setNeedsDisplay];
}
- (void)touchEnded:(UITouch*)touch
{
    // Do nothing if no start point
    if (!self.center) {
        return;
    }
    
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:3];
    CGPoint touchPointInView = [touch locationInView:touch.view];
    
    if (_temporaryCircle) {
        _temporaryCircle.pointOnRadius.highlighted = NO;
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCircle]];
        
        if (_temporaryCircle.pointOnRadius != _tempPointOnRadius) {
            _temporaryCircle.temporary = NO;
            if (_tempIntersectionCenter) [objectsToAdd addObject:_tempIntersectionCenter];
            if (_tempIntersectionRadius) [objectsToAdd addObject:_tempIntersectionRadius];
            [objectsToAdd addObject:_temporaryCircle];
            
            [self.delegate addGeometricObjects:objectsToAdd];
            
            [self reset];
        } else {
            if(DistanceBetweenPoints(_touchPointInViewStart, touchPointInView) > kClosestTapLimit ) {
                [self reset];
            } else {
                _temporaryCircle = nil;
                _tempPointOnRadius = nil;
                [self.delegate toolTipDidChange:@"Tap on a second point that the circle will pass through"];
            }
        }
    } else if (self.center) {
        [self.delegate toolTipDidChange:@"Tap on a second point that the circle will pass through"];
    }
    
    [touch.view setNeedsDisplay];
}
- (BOOL)active
{
    if (self.center) {
        return YES;
    }
    
    return NO;
}
- (void)reset
{
    DHToolTempObjectCleanup(_tempIntersectionCenter);
    DHToolTempObjectCleanup(_tempIntersectionRadius);
    DHToolTempObjectCleanup(_temporaryCircle);
    
    self.center.highlighted = NO;
    self.center = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)dealloc
{
    DHToolTempObjectCleanup(_tempIntersectionCenter);
    DHToolTempObjectCleanup(_tempIntersectionRadius);
    DHToolTempObjectCleanup(_temporaryCircle);
    
    self.center.highlighted = NO;
}
@end
