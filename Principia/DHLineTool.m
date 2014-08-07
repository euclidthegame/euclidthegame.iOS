//
//  DHLineTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHLineTool {
    CGPoint _touchPointInViewStart;
    DHPoint* _temporaryInitialStartingPoint;
    DHLine* _temporaryLine;
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
            if (!self.startPoint) _temporaryInitialStartingPoint = intersectionPoint;
            point = intersectionPoint;
        }
    }
    
    
    if (!self.startPoint && point) {
        self.startPoint = point;
        point.highlighted = true;
        [self.delegate toolTipDidChange:@"Drag to a second point that the line will pass through"];
        
        if (_temporaryInitialStartingPoint) {
            [self.delegate addTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        }
        [touch.view setNeedsDisplay];
    } else if (self.startPoint) {
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryLine = [[DHLine alloc] initWithStart:self.startPoint andEnd:endPoint];
        if (point && point != self.startPoint) {
            _temporaryLine.end.position = point.position;
            [self.delegate toolTipDidChange:@"Release to create line"];
        } else {
            _temporaryLine.end.position = touchPoint;
            _temporaryLine.temporary = YES;
            [self.delegate toolTipDidChange:@"Drag to a second point that the line will pass through"];
        }
        [self.delegate addTemporaryGeometricObjects:@[_temporaryLine]];
        [touch.view setNeedsDisplay];
    }
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    if (!_temporaryLine && self.startPoint) {
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryLine = [[DHLine alloc] initWithStart:self.startPoint andEnd:endPoint];
        [self.delegate addTemporaryGeometricObjects:@[_temporaryLine]];
        [touch.view setNeedsDisplay];
    }
    
    if (_temporaryLine) {
        CGPoint endPoint = touchPoint;
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects, geoViewScale);
        }
        
        //if still no point, see if there is a point close to the line and snap to it
        if (!point) {
            _temporaryLine.end.position = touchPoint;
            point = FindPointClosestToLine(_temporaryLine, self.startPoint, self.delegate.geometryObjects, 8/geoViewScale);
        }
        
        if (point && point != self.startPoint) {
            endPoint = point.position;
            [self.delegate toolTipDidChange:@"Release to create line"];
            _temporaryLine.temporary = NO;
        } else {
            [self.delegate toolTipDidChange:@"Drag to a second point that the line will pass through"];
            _temporaryLine.temporary = YES;
        }
        _temporaryLine.end.position = endPoint;
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
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    if (_temporaryLine) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryLine]];
        _temporaryLine = nil;
        [self.delegate toolTipDidChange:@"Tap on a second point that the line will pass through"];
        [touch.view setNeedsDisplay];
    }
    if (_temporaryInitialStartingPoint) {
        [objectsToAdd addObject:_temporaryInitialStartingPoint];
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        _temporaryInitialStartingPoint = nil;
        [touch.view setNeedsDisplay];
    }
    
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
    // Prefer normal point selection above automatic intersection
    if (!point) {
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        if (intersectionPoint && !CGPointEqualToPoint(intersectionPoint.position, self.startPoint.position)) {
            point = intersectionPoint;
            [objectsToAdd addObject:intersectionPoint];
        }
    }
    //if still no point, see if there is a point close to the line and snap to it
    if (!point) {
        DHLine* tempLine = [[DHLine alloc]initWithStart:self.startPoint andEnd:[[DHPoint alloc]initWithPositionX:touchPoint.x andY:touchPoint.y]];
        point = FindPointClosestToLine(tempLine, self.startPoint, self.delegate.geometryObjects, 8/geoViewScale);
    }
    
    if(!point && DistanceBetweenPoints(_touchPointInViewStart, touchPointInView) > kClosestTapLimit) {
        [self reset];
    }
    
    if (self.startPoint && point && point != self.startPoint) {
        DHLine* line = [[DHLine alloc] init];
        line.start = self.startPoint;
        line.end = point;
        
        [objectsToAdd addObject:line];
        
        self.startPoint.highlighted = false;
        self.startPoint = nil;
        
        [self.delegate addGeometricObjects:objectsToAdd];
        [objectsToAdd removeAllObjects];
        [self.delegate toolTipDidChange:self.initialToolTip];
    }
    if (objectsToAdd.count > 0) {
        [self.delegate addGeometricObjects:objectsToAdd];
    }
    if (self.startPoint) {
        [self.delegate toolTipDidChange:@"Tap on a second point that the line will pass through"];
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
    if (_temporaryLine) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryLine]];
        _temporaryLine = nil;
    }
    if (_temporaryInitialStartingPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        _temporaryInitialStartingPoint = nil;
    }
    
    self.startPoint.highlighted = NO;
    self.startPoint = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}

- (void)dealloc
{
    if (_temporaryLine) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryLine]];
        _temporaryLine = nil;
    }
    if (_temporaryInitialStartingPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        _temporaryInitialStartingPoint = nil;
    }
    self.startPoint.highlighted = NO;
}
@end