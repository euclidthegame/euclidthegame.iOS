//
//  DHLineSegmentTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHLineSegmentTool {
    CGPoint _touchPointInViewStart;
    DHPoint* _temporaryInitialStartingPoint;
    DHLineSegment* _temporaryLine;
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
            if (!self.startPoint) _temporaryInitialStartingPoint = intersectionPoint;
            point = intersectionPoint;
        }
    }
    
    if (!self.startPoint && point) {
        // If no starting yet and point was found, use as starting point and highlight it
        self.startPoint = point;
        point.highlighted = true;
        [self.delegate toolTipDidChange:@"Drag to a point defining the end point of the segment"];
        
        if (_temporaryInitialStartingPoint) {
            [self.delegate addTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        }
        [touch.view setNeedsDisplay];
    } else if (self.startPoint) {
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryLine = [[DHLineSegment alloc] initWithStart:self.startPoint andEnd:endPoint];
        if (point && point != self.startPoint) {
            _temporaryLine.end.position = point.position;
            [self.delegate toolTipDidChange:@"Release to create line segment"];
            
        } else {
            _temporaryLine.end.position = touchPoint;
            _temporaryLine.temporary = YES;
            [self.delegate toolTipDidChange:@"Drag to a point defining the end point of the segment"];
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
        _temporaryLine = [[DHLineSegment alloc] initWithStart:self.startPoint andEnd:endPoint];
        [self.delegate addTemporaryGeometricObjects:@[_temporaryLine]];
        [touch.view setNeedsDisplay];
    }
    
    if (_temporaryLine) {
        CGPoint endPoint = touchPoint;
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects, geoViewScale);
        }
        if (point && point != self.startPoint) {
            endPoint = point.position;
            [self.delegate toolTipDidChange:@"Release to create line segment"];
            _temporaryLine.temporary = NO;
            [touch.view setNeedsDisplay];
        } else {
            [self.delegate toolTipDidChange:@"Drag to a point defining the end point of the segment"];
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
        [self.delegate toolTipDidChange:@"Tap on a second point to mark the end the line segment"];
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
    
    if(!point && DistanceBetweenPoints(_touchPointInViewStart, touchPointInView) > kClosestTapLimit ) {
        [self reset];
    }
    
    if (self.startPoint && point && point != self.startPoint) {
        DHLineSegment* line = [[DHLineSegment alloc] init];
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
