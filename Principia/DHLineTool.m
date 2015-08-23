//
//  DHLineTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHLineTool {
    CGPoint _touchPointInViewStart;
    DHPoint* _tempIntersectionStart;
    DHPoint* _tempIntersectionEnd;
    DHPoint* _tempEndPoint;
    DHLine* _tempLine;
}
- (NSString*)initialToolTip
{
    return @"Tap on a point to mark the first of two points needed to define a line";
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
            if (!self.startPoint) _tempIntersectionStart = intersectionPoint;
            else _tempIntersectionEnd = intersectionPoint;
            point = intersectionPoint;
        }
    }
    
    if (!self.startPoint && point) {
        self.startPoint = point;
        point.highlighted = YES;
        [self.delegate toolTipDidChange:@"Drag to a second point that the line will pass through"];
        
        if (_tempIntersectionStart) {
            [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionStart]];
        }
        [touch.view setNeedsDisplay];
    } else if (self.startPoint) {
        _tempEndPoint = [[DHPoint alloc] initWithPosition:touchPoint];
        _tempLine = [[DHLine alloc] initWithStart:self.startPoint andEnd:_tempEndPoint];
        if (point && point != self.startPoint) {
            _tempLine.end = point;
            _tempLine.end.highlighted = YES;
            [self.delegate toolTipDidChange:@"Release to create line"];
        } else {
            _tempLine.end.position = touchPoint;
            _tempLine.temporary = YES;
            [self.delegate toolTipDidChange:@"Drag to a second point that the line will pass through"];
        }
        [self.delegate addTemporaryGeometricObjects:@[_tempLine]];
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
    
    if (!_tempLine && self.startPoint) {
        _tempEndPoint = [[DHPoint alloc] initWithPosition:touchPoint];
        _tempLine = [[DHLine alloc] initWithStart:self.startPoint andEnd:_tempEndPoint];
        [self.delegate addTemporaryGeometricObjects:@[_tempLine]];
        [touch.view setNeedsDisplay];
    }
    
    if (_tempLine) {
        _tempLine.end.highlighted = NO;
        _tempEndPoint.position = touchPoint;
        _tempLine.end = _tempEndPoint;
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects, geoViewScale);
            if (point) _tempIntersectionEnd = point;
        }
        
        //if still no point, see if there is a point close to the line and snap to it
        if (!point) {
            point = FindPointClosestToLine(_tempLine, self.startPoint, geoObjects, 8/geoViewScale);
        }
        
        if (point && point != self.startPoint) {
            _tempLine.end = point;
            _tempLine.temporary = NO;
            _tempLine.end.highlighted = YES;

            if (_tempIntersectionEnd) [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionEnd]];
            
            [self.delegate toolTipDidChange:@"Release to create line"];
        } else {
            [self.delegate toolTipDidChange:@"Drag to a second point that the line will pass through"];
            _tempLine.temporary = YES;
        }
        [touch.view setNeedsDisplay];
    }
}
- (void)touchEnded:(UITouch*)touch
{
    // Do nothing if no start point
    if (!self.startPoint) {
        return;
    }
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:3];
    CGPoint touchPointInView = [touch locationInView:touch.view];
    
    if (_tempLine) {
        _tempLine.end.highlighted = NO;
        [self.delegate removeTemporaryGeometricObjects:@[_tempLine]];
        
        if (_tempLine.end != _tempEndPoint) {
            _tempLine.temporary = NO;
            if (_tempIntersectionStart) [objectsToAdd addObject:_tempIntersectionStart];
            if (_tempIntersectionEnd) [objectsToAdd addObject:_tempIntersectionEnd];
            [objectsToAdd addObject:_tempLine];
            
            [self.delegate addGeometricObjects:objectsToAdd];
            
            [self reset];
        } else {
            
            if(DistanceBetweenPoints(_touchPointInViewStart, touchPointInView) > kClosestTapLimit ) {
                [self reset];
            } else {
                _tempLine = nil;
                _tempEndPoint = nil;
                [self.delegate toolTipDidChange:@"Tap on a second point that the line should pass through"];
            }
        }
    } else if (self.startPoint) {
        [self.delegate toolTipDidChange:@"Tap on a second point that the line should pass through"];
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
    if (_tempLine) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempLine]];
        _tempLine = nil;
    }
    if (_tempIntersectionStart) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionStart]];
        _tempIntersectionStart = nil;
    }
    if (_tempIntersectionEnd) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionEnd]];
        _tempIntersectionEnd = nil;
    }    
    
    self.startPoint.highlighted = NO;
    self.startPoint = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}

- (void)dealloc
{
    DHToolTempObjectCleanup(_tempLine);
    if (_tempIntersectionStart) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionStart]];
        _tempIntersectionStart = nil;
    }
    if (_tempIntersectionEnd) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionEnd]];
    }    
    self.startPoint.highlighted = NO;
}
@end