//
//  DHPerpendicularTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHPerpendicularTool {
    CGPoint _touchPointInViewStart;
    DHPerpendicularLine* _tempPerpLine;
    DHPoint* _tempPoint;
    DHPoint* _tempIntersectionPoint;
}
- (NSString*)initialToolTip
{
    return @"Tap a line (segment) you wish to make a line perpendicular to";
}
- (void)touchBegan:(UITouch*)touch
{
    _touchPointInViewStart = [touch locationInView:touch.view];
    
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    NSArray *geoObjects = self.delegate.geometryObjects;
    
    if (self.line == nil) {
        DHLineObject* line = FindLineClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        if (line) {
            self.line = line;
            line.highlighted = true;
            [self.delegate toolTipDidChange:@"Swipe to a point that the perpendicular line should pass through"];
            _tempPoint = [[DHPoint alloc] initWithPosition:touchPoint];
            _tempPerpLine = [[DHPerpendicularLine alloc] initWithLine:self.line andPoint:_tempPoint];
            _tempPerpLine.temporary = YES;
            [self.delegate addTemporaryGeometricObjects:@[_tempPerpLine]];
            [touch.view setNeedsDisplay];
        }
    } else {
        _tempPoint = [[DHPoint alloc] initWithPosition:touchPoint];
        _tempPerpLine = [[DHPerpendicularLine alloc] initWithLine:self.line andPoint:_tempPoint];
        _tempPerpLine.temporary = YES;
        [self.delegate addTemporaryGeometricObjects:@[_tempPerpLine]];
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects,geoViewScale);
            if (point && point.label.length == 0) {
                _tempIntersectionPoint = point;
                [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionPoint]];
            }
        }
        if (point) {
            _tempPerpLine.temporary = NO;
            _tempPerpLine.point = point;
            [self.delegate toolTipDidChange:@"Release to create perpendicular line"];
        } else {
            [self.delegate toolTipDidChange:@"Swipe to a point that the perpendicular line should pass through"];
        }
        
        [touch.view setNeedsDisplay];
    }
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    NSArray *geoObjects = self.delegate.geometryObjects;
    
    if (_tempIntersectionPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionPoint]];
        _tempIntersectionPoint = nil;
    }
    if (_tempPerpLine) {
        DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects,geoViewScale);
            if (point && point.label.length == 0) {
                _tempIntersectionPoint = point;
                [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionPoint]];
            }
        }
        if (point) {
            _tempPerpLine.temporary = NO;
            _tempPerpLine.point = point;
            [self.delegate toolTipDidChange:@"Release to create perpendicular line"];
        } else {
            _tempPerpLine.temporary = YES;
            _tempPoint.position = touchPoint;
            _tempPerpLine.point = _tempPoint;
            [self.delegate toolTipDidChange:@"Swipe to a point that the perpendicular line should pass through"];
        }
        [touch.view setNeedsDisplay];
    }
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:2];
    
    if (_tempPerpLine) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempPerpLine]];
        
        if (_tempPerpLine.point == _tempPoint) {
            if(DistanceBetweenPoints(_touchPointInViewStart, touchPointInView) > kClosestTapLimit) {
                [self reset];
            } else {
                [self.delegate toolTipDidChange:@"Tap a point that the perpendicular line should pass through"];
            }
        } else {
            [objectsToAdd addObject:_tempPerpLine];
            if (_tempIntersectionPoint) {
                [objectsToAdd addObject:_tempIntersectionPoint];
            }
            [self reset];
        }
        
        _tempPerpLine = nil;
        _tempPoint = nil;
    }
    if (_tempIntersectionPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionPoint]];
        _tempIntersectionPoint = nil;
    }
    
    if (objectsToAdd.count > 0) {
        [self.delegate addGeometricObjects:objectsToAdd];
    }
    [touch.view setNeedsDisplay];

}
- (BOOL)active
{
    if (self.line) {
        return YES;
    }
    
    return NO;
}
- (void)reset
{
    if (_tempIntersectionPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionPoint]];
        _tempIntersectionPoint = nil;
    }
    if (_tempPerpLine) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempPerpLine]];
        _tempPerpLine = nil;
        _tempPoint = nil;
    }
 
    self.line.highlighted = NO;
    self.line = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)dealloc
{
    if (_tempIntersectionPoint) [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionPoint]];
    if (_tempPerpLine) [self.delegate removeTemporaryGeometricObjects:@[_tempPerpLine]];
    
    self.line.highlighted = NO;
}
@end