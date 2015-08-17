//
//  DHMidpointTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHMidPointTool {
    CGPoint _touchPointInViewStart;
    DHPoint* _tempIntersectionStart;
    DHPoint* _tempIntersectionEnd;
    DHPoint* _tempEndPoint;    
    DHMidPoint* _tempMidPoint;
    DHLineSegment* _temporarySegment;
    NSString* _temporaryTooltipUnfinished;
    NSString* _temporaryTooltipFinished;
    NSString* _partialTooltip;
}
- (id)init
{
    self = [super init];
    if (self) {
        _temporaryTooltipUnfinished = @"Drag to a second point between which to create the midpoint";
        _temporaryTooltipFinished = @"Release to create midpoint";
        _partialTooltip = @"Tap on a second point, between which to create the midpoint";
    }
    return self;
}
- (NSString*)initialToolTip
{
    if (self.disableCircles) {
        return @"Tap a line segment or two points two create a midpoint";
    }
    
    return @"Tap a line segment or two points two create a midpoint, or a circle to create a point at its center";
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
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects, geoViewScale);
        if (intersectionPoint) {
            if (!self.startPoint) _tempIntersectionStart = intersectionPoint;
            else _tempIntersectionEnd = intersectionPoint;
            point = intersectionPoint;
        }
    }
    
    if (!self.startPoint && point) {
        // If no current starting point but a point was found, use that as a temporary starting point
        self.startPoint = point;
        point.highlighted = true;
        [self.delegate toolTipDidChange:_temporaryTooltipUnfinished];
        
        if (_tempIntersectionStart) {
            [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionStart]];
        }
        [touch.view setNeedsDisplay];
    } else if (self.startPoint) {
        // If there already is a startpoint use current point/touch point as temporary end point
        _tempEndPoint = [[DHPoint alloc] initWithPosition:touchPoint];
        _tempMidPoint = [[DHMidPoint alloc] initWithPoint1:self.startPoint andPoint2:_tempEndPoint];
        if (point && point != self.startPoint) {
            if (_tempIntersectionEnd) {
                [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionEnd]];
            }
            _tempMidPoint.end = point;
            _tempMidPoint.end.highlighted = YES;
            [self.delegate toolTipDidChange:_temporaryTooltipFinished];
        } else {
            _tempMidPoint.end.position = touchPoint;
            //_temporaryMidPoint.temporary = YES;
            [self.delegate toolTipDidChange:_temporaryTooltipUnfinished];
        }
        [self.delegate addTemporaryGeometricObjects:@[_tempMidPoint]];
        [touch.view setNeedsDisplay];
    } else if (!self.startPoint && !point) {
        // If no starting point and no point was close, check if a line segment was tapped
        DHLineSegment* segment = FindLineSegmentClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        if (segment) {
            _temporarySegment = segment;
            segment.highlighted = YES;
            _tempMidPoint = [[DHMidPoint alloc] initWithPoint1:segment.start andPoint2:segment.end];
            [self.delegate addTemporaryGeometricObjects:@[_tempMidPoint]];
            [self.delegate toolTipDidChange:_temporaryTooltipFinished];
            [touch.view setNeedsDisplay];
        } else if(!self.disableCircles) {
            // Finally, if no line was found check if a circle was tapped
            DHCircle* circle = FindCircleClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
            if (circle) {
                self.circle = circle;
                circle.highlighted = YES;
                if (circle.center.label.length == 0) {
                    [self.delegate addTemporaryGeometricObjects:@[self.circle.center]];
                }
                [self.delegate toolTipDidChange:_temporaryTooltipFinished];
                [touch.view setNeedsDisplay];
            }
        }
    }
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];

    if (_tempIntersectionEnd) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionEnd]];
        _tempIntersectionEnd = nil;
    }
    if (_temporarySegment) {
        if (DistanceFromPositionToLine(touchPoint, _temporarySegment) > kClosestTapLimit / geoViewScale) {
            [self reset];
            [touch.view setNeedsDisplay];
        }
        return;
    }
    if (self.circle) {
        if (DistanceFromPositionToCircle(touchPoint, self.circle) > kClosestTapLimit / geoViewScale) {
            [self reset];
            [touch.view setNeedsDisplay];
        }
        return;
    }
    
    if (!_tempMidPoint && self.startPoint) {
        _tempEndPoint = [[DHPoint alloc] initWithPosition:touchPoint];
        _tempMidPoint = [[DHMidPoint alloc] initWithPoint1:self.startPoint andPoint2:_tempEndPoint];
        [self.delegate addTemporaryGeometricObjects:@[_tempMidPoint]];
        [touch.view setNeedsDisplay];
    }
    
    if (_tempMidPoint) {
        _tempMidPoint.end.highlighted = NO;
        _tempEndPoint.position = touchPoint;
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects, geoViewScale);
            if (point) _tempIntersectionEnd = point;            
        }
        
        if (point && point != self.startPoint) {
            _tempMidPoint.end = point;
            _tempMidPoint.end.highlighted = YES;
            
            if (_tempIntersectionEnd) {
                [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionEnd]];
            }            [self.delegate toolTipDidChange:_temporaryTooltipFinished];
        } else {
            _tempMidPoint.end = _tempEndPoint;
            [self.delegate toolTipDidChange:_temporaryTooltipUnfinished];
        }
        [touch.view setNeedsDisplay];
    }
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:3];

    // If we already have  a temporary segment defining the midpoint, use that end exit early
    if (_temporarySegment) {
        DHMidPoint* midPoint = [[DHMidPoint alloc] initWithPoint1:_temporarySegment.start
                                                        andPoint2:_temporarySegment.end];
        [self.delegate addGeometricObjects:@[midPoint]];
        [self reset];
        return;
    }
    if (self.circle) {
        DHMidPoint* midPoint = [[DHMidPoint alloc] initWithPoint1:self.circle.center
                                                        andPoint2:self.circle.center];
        [self.delegate addGeometricObjects:@[midPoint]];
        [self reset];
        return;
    }
    
    // Do nothing if no start point
    if (!self.startPoint) {
        return;
    }
    
    if (_tempMidPoint) {
        _tempMidPoint.end.highlighted = NO;
        [self.delegate removeTemporaryGeometricObjects:@[_tempMidPoint]];
        
        if (_tempMidPoint.end != _tempEndPoint) {
            if (_tempIntersectionStart) [objectsToAdd addObject:_tempIntersectionStart];
            if (_tempIntersectionEnd) [objectsToAdd addObject:_tempIntersectionEnd];
            [objectsToAdd addObject:_tempMidPoint];
            
            [self.delegate addGeometricObjects:objectsToAdd];
            
            [self reset];
        } else {
            if(DistanceBetweenPoints(_touchPointInViewStart, touchPointInView) > kClosestTapLimit ) {
                [self reset];
            } else {
                _tempMidPoint = nil;
                _tempEndPoint = nil;
                [self.delegate toolTipDidChange:_partialTooltip];
            }
        }
    } else if (self.startPoint) {
        [self.delegate toolTipDidChange:_partialTooltip];
    }
    
    [touch.view setNeedsDisplay];
}
- (BOOL)active
{
    if (self.startPoint || self.circle) {
        return YES;
    }
    return NO;
}

- (void)reset {
    DHToolTempObjectCleanup(_tempMidPoint);
    DHToolTempObjectCleanup(_tempIntersectionStart);
    DHToolTempObjectCleanup(_tempIntersectionEnd);

    if (self.circle) {
        [self.delegate removeTemporaryGeometricObjects:@[self.circle.center]];
        self.circle.highlighted = NO;
        self.circle = nil;
    }
    
    _temporarySegment.highlighted = NO;
    _temporarySegment = nil;
    
    self.startPoint.highlighted = NO;
    self.startPoint = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    
    self.associatedTouch = 0;
}
- (void)dealloc
{
    _temporarySegment.highlighted = NO;
    self.startPoint.highlighted = NO;
    
    if (self.circle) {
        [self.delegate removeTemporaryGeometricObjects:@[self.circle.center]];
        self.circle.highlighted = NO;
        self.circle = nil;
    }
    DHToolTempObjectCleanup(_tempMidPoint);
    DHToolTempObjectCleanup(_tempIntersectionStart);
    DHToolTempObjectCleanup(_tempIntersectionEnd);
}
@end