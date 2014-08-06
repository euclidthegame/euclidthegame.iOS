//
//  DHCircleTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHCircleTool {
    CGPoint _touchPointInViewStart;
    DHPoint* _temporaryCenter;
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
    
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
    if (!point) {
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        if (intersectionPoint) {
            if (!self.center) _temporaryCenter = intersectionPoint;
            point = intersectionPoint;
        }
    }
    
    if (!self.center && point) {
        self.center = point;
        point.highlighted = true;
        [self.delegate toolTipDidChange:@"Drag to a point that the circle will pass through"];
        
        if (_temporaryCenter) {
            [self.delegate addTemporaryGeometricObjects:@[_temporaryCenter]];
        }
        [touch.view setNeedsDisplay];
    } else if (self.center) {
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryCircle = [[DHCircle alloc] initWithCenter:self.center andPointOnRadius:endPoint];
        if (point && point != self.center) {
            _temporaryCircle.pointOnRadius.position = point.position;
            [self.delegate toolTipDidChange:@"Release to create circle"];
        } else {
            _temporaryCircle.pointOnRadius.position = touchPoint;
            _temporaryCircle.temporary = YES;
            [self.delegate toolTipDidChange:@"Drag to a point that the circle will pass through"];
        }
        [self.delegate addTemporaryGeometricObjects:@[_temporaryCircle]];
        [touch.view setNeedsDisplay];
    }
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    if (!_temporaryCircle && self.center) {
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryCircle = [[DHCircle alloc] initWithCenter:self.center andPointOnRadius:endPoint];
        [self.delegate addTemporaryGeometricObjects:@[_temporaryCircle]];
        [touch.view setNeedsDisplay];
    }
    
    if (_temporaryCircle) {
        CGPoint endPoint = touchPoint;
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects, geoViewScale);
        }
        if (!point) {
            _temporaryCircle.pointOnRadius.position = endPoint;
            point = FindPointClosestToCircle(_temporaryCircle, self.delegate.geometryObjects, 8/geoViewScale);
        }
        
        if (point && point != self.center) {
            endPoint = point.position;
            [self.delegate toolTipDidChange:@"Release to create circle"];
            _temporaryCircle.temporary = NO;
        } else {
            [self.delegate toolTipDidChange:@"Drag to a point that the circle will pass through"];
            _temporaryCircle.temporary = YES;
        }
        _temporaryCircle.pointOnRadius.position = endPoint;
        [touch.view setNeedsDisplay];
    }
}
- (void)touchEnded:(UITouch*)touch
{
    // Do nothing if no start point
    if (!self.center) {
        return;
    }
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:3];
    
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    if (_temporaryCircle) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCircle]];
        _temporaryCircle = nil;
        [self.delegate toolTipDidChange:@"Tap on a second point that the circle will pass through"];
        [touch.view setNeedsDisplay];
    }
    if (_temporaryCenter) {
        [objectsToAdd addObject:_temporaryCenter];
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCenter]];
        _temporaryCenter = nil;
        [touch.view setNeedsDisplay];
    }
    
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
    // Prefer normal point selection above automatic intersection
    if (!point) {
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        if (intersectionPoint && !CGPointEqualToPoint(intersectionPoint.position, self.center.position)) {
            point = intersectionPoint;
            [objectsToAdd addObject:intersectionPoint];
        }
    }
    // If still no point, see if there is a point close to the circle and snap to it
    if (!point) {
        DHCircle* tempCircle = [[DHCircle alloc] init];
        tempCircle.center = self.center;
        tempCircle.pointOnRadius = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        point = FindPointClosestToCircle(tempCircle, self.delegate.geometryObjects, 8/geoViewScale);
    }
    
    if(!point && DistanceBetweenPoints(_touchPointInViewStart, touchPointInView) > kClosestTapLimit) {
        [self reset];
    }
    
    if (self.center && point && point != self.center) {
        DHCircle* circle = [[DHCircle alloc] init];
        circle.center = self.center;
        circle.pointOnRadius = point;
        
        [objectsToAdd addObject:circle];
        
        self.center.highlighted = false;
        self.center = nil;
        
        [self.delegate addGeometricObjects:objectsToAdd];
        [objectsToAdd removeAllObjects];
        [self.delegate toolTipDidChange:self.initialToolTip];
    }
    if (objectsToAdd.count > 0) {
        [self.delegate addGeometricObjects:objectsToAdd];
    }
    if (self.center) {
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
    if (_temporaryCenter) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCenter]];
        _temporaryCenter = nil;
    }
    if (_temporaryCircle) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCircle]];
        _temporaryCircle = nil;
    }
    
    self.center.highlighted = NO;
    self.center = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)dealloc
{
    if (_temporaryCenter) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCenter]];
        _temporaryCenter = nil;
    }
    if (_temporaryCircle) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCircle]];
        _temporaryCircle = nil;
    }
    
    self.center.highlighted = NO;
}
@end
