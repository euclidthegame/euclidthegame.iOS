//
//  DHBisectTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHBisectTool {
    __weak DHPoint** _selectedPoint;
    __weak DHLineObject** _selectedLine;
    DHPoint* _tempIntersectionPoint2;
    DHPoint* _tempIntersectionPoint3;
}
- (NSString*)initialToolTip
{
    return @"Tap two lines, rays or line segments (or three points) that define an angle to create its bisector";
}
- (void)touchBegan:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    NSArray* geoObjects = self.delegate.geometryObjects;
    
    // If no first point has been tapped, look for closest line or point
    if (self.firstPoint == nil) {
        DHLineObject* line = FindLineClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        
        if (point && self.firstLine == nil) {
            self.firstPoint = point;
            point.highlighted = YES;
            _selectedPoint = &_firstPoint;
        } else if (line) {
            if (self.firstLine == nil) {
                self.firstLine = line;
                line.highlighted = true;
                _selectedLine = &_firstLine;
            } else if (self.firstLine && line != self.firstLine) {
                self.secondLine = line;
                line.highlighted = YES;
                _selectedLine = &_secondLine;
                [self.delegate toolTipDidChange:@"Release to create bisector"];
            }
        }
    } else {
        DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        BOOL tempIntersection = NO;
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects, geoViewScale);
            tempIntersection = YES;
        }
        if (point) {
            if (point == self.firstPoint || point == self.secondPoint) {
                return;
            }
            if (self.secondPoint == nil) {
                self.secondPoint = point;
                point.highlighted = YES;
                _selectedPoint = &_secondPoint;
                if (tempIntersection) {
                    _tempIntersectionPoint2 = point;
                    [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionPoint2]];
                }
            } else {
                self.thirdPoint = point;
                point.highlighted = YES;
                _selectedPoint = &_thirdPoint;
                if (tempIntersection) {
                    _tempIntersectionPoint3 = point;
                    [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionPoint3]];
                }
                
                [self.delegate toolTipDidChange:@"Release to create bisector"];
            }
        }
    }
    [touch.view setNeedsDisplay];
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];

    if (_selectedPoint) {
        if (DistanceBetweenPoints((*_selectedPoint).position, touchPoint) > 2*kClosestTapLimit / geoViewScale) {
            (*_selectedPoint).highlighted = NO;
            (*_selectedPoint) = nil;
            _selectedPoint = nil;
            
            if (self.firstPoint && self.secondPoint == nil) {
                [self.delegate toolTipDidChange:@"Tap a second point to mark the corner of the angle"];
            }
            if (self.firstPoint && self.secondPoint) {
                [self.delegate toolTipDidChange:@"Tap a third point to define the angle and create the bisector"];
            }
        }
    }
    
    if (_selectedLine) {
        if (DistanceFromPositionToLine(touchPoint, *_selectedLine) > 2*kClosestTapLimit / geoViewScale) {
            (*_selectedLine).highlighted = NO;
            (*_selectedLine) = nil;
            _selectedLine = nil;
            
            if (self.firstLine && self.secondLine == nil) {
                [self.delegate toolTipDidChange:@"Tap a second line intersecting/connected to the first to create the bisector"];
            }
        }
    }
    
    [touch.view setNeedsDisplay];
}
- (void)touchEnded:(UITouch*)touch
{
    _selectedPoint = nil;
    _selectedLine = nil;
    
    CGPoint touchPointInView = [touch locationInView:touch.view];
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:3];
    
    if (self.secondLine) {
        if (IntersectionTestLineLine(self.firstLine, self.secondLine).intersect == NO) {
            self.secondLine.highlighted = NO;
            self.secondLine = nil;
            [self.delegate showTemporaryMessage:@"The lines must intersect or be connected to define an angle"
                                        atPoint:touchPointInView withColor:[UIColor redColor]];
        } else if (EqualDirection(self.firstLine, self.secondLine)) {
            self.secondLine.highlighted = NO;
            self.secondLine = nil;
            [self.delegate showTemporaryMessage:@"The lines can not be parallel to define an angle"
                                        atPoint:touchPointInView withColor:[UIColor redColor]];
        } else {
            BOOL createPerpendicular = YES;
            
            // Check if two line segments sharing an end point are selected, then only create inner bisector
            if ([_firstLine isKindOfClass:[DHLineSegment class]] && [_secondLine isKindOfClass:[DHLineSegment class]])
            {
                if (_firstLine.start == _secondLine.start || _firstLine.start == _secondLine.end ||
                    _firstLine.end == _secondLine.start || _firstLine.end == _secondLine.end)
                {
                    createPerpendicular = NO;
                }
            }
            if ([_firstLine isKindOfClass:[DHRay class]] && [_secondLine isKindOfClass:[DHRay class]])
            {
                if (_firstLine.start == _secondLine.start)
                {
                    createPerpendicular = NO;
                }
            }
            
            DHBisectLine* bl = [[DHBisectLine alloc] initWithLine:self.firstLine andLine:self.secondLine];
            
            if (createPerpendicular) {
                DHPerpendicularLine* perpLine = [[DHPerpendicularLine alloc] initWithLine:bl andPoint:bl.start];
                [self.delegate addGeometricObjects:@[bl, perpLine]];
            } else {
                [self.delegate addGeometricObjects:@[bl]];
            }
            [self reset];
        }
    }
    if (self.thirdPoint) {
        // Ensure the lines define an angle
        CGVector v1 = CGVectorBetweenPoints(self.secondPoint.position, self.firstPoint.position);
        CGVector v2 = CGVectorBetweenPoints(self.secondPoint.position, self.thirdPoint.position);
        CGFloat angle = CGVectorAngleBetween(v1, v2);
        if (angle < 0.0001 || fabs(angle - M_PI) < 0.001) {
            
            if (_tempIntersectionPoint3) DHToolTempObjectCleanup(_tempIntersectionPoint3);
            
            self.thirdPoint.highlighted = NO;
            self.thirdPoint = nil;
            [self.delegate showTemporaryMessage:@"The points can not all lie on a line to define an angle"
                                        atPoint:touchPointInView withColor:[UIColor redColor]];
        } else {
            DHBisectLine* bl = [[DHBisectLine alloc] init];
            bl.line1 = [[DHLineSegment alloc] initWithStart:self.secondPoint andEnd:self.firstPoint];
            bl.line2 = [[DHLineSegment alloc] initWithStart:self.secondPoint andEnd:self.thirdPoint];
            
            if (_tempIntersectionPoint2) [objectsToAdd addObject:_tempIntersectionPoint2];
            if (_tempIntersectionPoint3) [objectsToAdd addObject:_tempIntersectionPoint3];
            [objectsToAdd addObjectsFromArray:@[bl]];
            
            [self.delegate addGeometricObjects:objectsToAdd];
            
            [self reset];
        }
    }
    
    if (self.firstLine && self.secondLine == nil) {
        [self.delegate toolTipDidChange:@"Tap a second line intersecting/connected to the first to create the bisector"];
    }
    if (self.firstPoint && self.secondPoint == nil) {
        [self.delegate toolTipDidChange:@"Tap a second point to mark the corner of the angle"];
    }
    if (self.firstPoint && self.secondPoint) {
        [self.delegate toolTipDidChange:@"Tap a third point to define the angle and create the bisector"];
    }
    
    [touch.view setNeedsDisplay];
}
- (BOOL)active
{
    if (self.firstLine || self.firstPoint || self.secondPoint) {
        return YES;
    }
    return false;
}
- (void)reset
{
    DHToolTempObjectCleanup(_tempIntersectionPoint2);
    DHToolTempObjectCleanup(_tempIntersectionPoint3);
    
    _selectedPoint = nil;
    _selectedLine = nil;

    self.firstLine.highlighted = NO;
    self.secondLine.highlighted = NO;
    self.firstPoint.highlighted = NO;
    self.secondPoint.highlighted = NO;
    self.thirdPoint.highlighted = NO;
    self.firstLine = nil;
    self.secondLine = nil;
    self.firstPoint = nil;
    self.secondPoint = nil;
    self.thirdPoint = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)dealloc
{
    DHToolTempObjectCleanup(_tempIntersectionPoint2);
    DHToolTempObjectCleanup(_tempIntersectionPoint3);
    
    self.firstLine.highlighted = NO;
    self.secondLine.highlighted = NO;
    self.firstPoint.highlighted = NO;
    self.secondPoint.highlighted = NO;
    self.thirdPoint.highlighted = NO;
}
@end
