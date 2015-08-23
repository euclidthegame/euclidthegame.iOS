//
//  DHLineSegmentTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHLineSegmentTool {
    CGPoint _touchPointInViewStart;
    DHPoint* _tempIntersectionStart;
    DHPoint* _tempIntersectionEnd;
    DHPoint* _tempEndPoint;
    DHLineSegment* _tempSegment;
}
- (NSString*)initialToolTip
{
    return @"Tap on a point to mark the start of a new line segment";
}
- (void)touchBegan:(UITouch*)touch
{
    _touchPointInViewStart = [touch locationInView:touch.view];
    
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    // Find closest point, or intersection point
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
    if (!point) {
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,
                                                                        geoViewScale);
        if (intersectionPoint) {
            if (!self.startPoint) _tempIntersectionStart = intersectionPoint;
            else _tempIntersectionEnd = intersectionPoint;
            point = intersectionPoint;
        }
    }
    
    if (!self.startPoint && point) {
        // If no starting yet and point was found, use as starting point and highlight it
        self.startPoint = point;
        point.highlighted = YES;
        [self.delegate toolTipDidChange:@"Drag to a point defining the end point of the segment"];
        
        if (_tempIntersectionStart) {
            [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionStart]];
        }
        [touch.view setNeedsDisplay];
    } else if (self.startPoint) {
        _tempEndPoint = [[DHPoint alloc] initWithPosition:touchPoint];
        _tempSegment = [[DHLineSegment alloc] initWithStart:self.startPoint andEnd:_tempEndPoint];
        if (point && point != self.startPoint) {
            if (_tempIntersectionEnd) {
                [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionEnd]];
            }
            _tempSegment.end = point;
            _tempSegment.end.highlighted = YES;
            [self.delegate toolTipDidChange:@"Release to create line segment"];
            
        } else {
            _tempSegment.temporary = YES;
            [self.delegate toolTipDidChange:@"Drag to a point defining the end point of the segment"];
        }
        [self.delegate addTemporaryGeometricObjects:@[_tempSegment]];
        [touch.view setNeedsDisplay];
    }
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    NSArray* geoObjects = self.delegate.geometryObjects;
    
    if (_tempIntersectionEnd) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionEnd]];
        _tempIntersectionEnd = nil;
    }
    
    if (!_tempSegment && self.startPoint) {
        _tempEndPoint = [[DHPoint alloc] initWithPosition:touchPoint];
        _tempSegment = [[DHLineSegment alloc] initWithStart:self.startPoint andEnd:_tempEndPoint];
        [self.delegate addTemporaryGeometricObjects:@[_tempSegment]];
    }
    
    if (_tempSegment) {
        _tempSegment.end.highlighted = NO;
        _tempEndPoint.position = touchPoint;
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects, geoViewScale);
            if (point) _tempIntersectionEnd = point;
        }
        if (point && point != self.startPoint) {
            _tempSegment.end = point;
            _tempSegment.temporary = NO;
            _tempSegment.end.highlighted = YES;

            if (_tempIntersectionEnd) {
                [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionEnd]];
            }
            
            [self.delegate toolTipDidChange:@"Release to create line segment"];
        } else {
            _tempSegment.temporary = YES;
            _tempSegment.end = _tempEndPoint;
            [self.delegate toolTipDidChange:@"Drag to a point defining the end point of the segment"];
        }
    }
    [touch.view setNeedsDisplay];
}
- (void)touchEnded:(UITouch*)touch
{
    // Do nothing if no start point
    if (!self.startPoint) {
        return;
    }
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:3];
    CGPoint touchPointInView = [touch locationInView:touch.view];
    
    if (_tempSegment) {
        _tempSegment.end.highlighted = NO;
        [self.delegate removeTemporaryGeometricObjects:@[_tempSegment]];
        
        if (_tempSegment.end != _tempEndPoint) {
            _tempSegment.temporary = NO;
            if (_tempIntersectionStart) [objectsToAdd addObject:_tempIntersectionStart];
            if (_tempIntersectionEnd) [objectsToAdd addObject:_tempIntersectionEnd];
            [objectsToAdd addObject:_tempSegment];
            
            [self.delegate addGeometricObjects:objectsToAdd];
            
            [self reset];
        } else {
            
            if(DistanceBetweenPoints(_touchPointInViewStart, touchPointInView) > kClosestTapLimit ) {
                [self reset];
            } else {
                _tempSegment = nil;
                _tempEndPoint = nil;
                [self.delegate toolTipDidChange:@"Tap on a second point to mark the end the line segment"];
            }
        }
    } else if (self.startPoint) {
        [self.delegate toolTipDidChange:@"Tap on a second point to mark the end the line segment"];
    }
    
    [touch.view setNeedsDisplay];
}
- (BOOL)active
{
    if (self.startPoint) {
        return YES;
    }
    
    return NO;
}
- (void)reset
{
    _tempEndPoint = nil;
    DHToolTempObjectCleanup(_tempSegment);
    DHToolTempObjectCleanup(_tempIntersectionStart);
    DHToolTempObjectCleanup(_tempIntersectionEnd);
    
    self.startPoint.highlighted = NO;
    self.startPoint = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}

- (void)dealloc
{
    DHToolTempObjectCleanup(_tempSegment);
    DHToolTempObjectCleanup(_tempIntersectionStart);
    DHToolTempObjectCleanup(_tempIntersectionEnd);
    self.startPoint.highlighted = NO;
}
@end
