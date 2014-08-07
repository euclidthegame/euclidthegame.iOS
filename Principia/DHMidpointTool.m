//
//  DHMidpointTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHMidPointTool {
    CGPoint _touchPointInViewStart;
    DHPoint* _temporaryInitialStartingPoint;
    DHMidPoint* _temporaryMidPoint;
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
    return @"Tap a line segment or two points two create a midpoint";
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
            if (!self.startPoint) _temporaryInitialStartingPoint = intersectionPoint;
            point = intersectionPoint;
        }
    }
    
    if (!self.startPoint && point) {
        // If no current starting point but a point was found, use that as a temporary starting point
        self.startPoint = point;
        point.highlighted = true;
        [self.delegate toolTipDidChange:_temporaryTooltipUnfinished];
        
        if (_temporaryInitialStartingPoint) {
            [self.delegate addTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        }
        [touch.view setNeedsDisplay];
    } else if (self.startPoint) {
        // If there already is a startpoint use current point/touch point as temporary end point
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryMidPoint = [[DHMidPoint alloc] initWithPoint1:self.startPoint andPoint2:endPoint];
        if (point && point != self.startPoint) {
            _temporaryMidPoint.end.position = point.position;
            [self.delegate toolTipDidChange:_temporaryTooltipFinished];
        } else {
            _temporaryMidPoint.end.position = touchPoint;
            //_temporaryMidPoint.temporary = YES;
            [self.delegate toolTipDidChange:_temporaryTooltipUnfinished];
        }
        [self.delegate addTemporaryGeometricObjects:@[_temporaryMidPoint]];
        [touch.view setNeedsDisplay];
    } else if (!self.startPoint && !point) {
        // If no starting point and no point was close, check if a line segment was tapped
        DHLineSegment* segment = FindLineSegmentClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        if (segment) {
            _temporarySegment = segment;
            segment.highlighted = YES;
            _temporaryMidPoint = [[DHMidPoint alloc] initWithPoint1:segment.start andPoint2:segment.end];
            [self.delegate addTemporaryGeometricObjects:@[_temporaryMidPoint]];
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
    
    if (!_temporaryMidPoint && self.startPoint) {
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryMidPoint = [[DHMidPoint alloc] initWithPoint1:self.startPoint andPoint2:endPoint];
        [self.delegate addTemporaryGeometricObjects:@[_temporaryMidPoint]];
        [touch.view setNeedsDisplay];
    }
    
    if (_temporaryMidPoint) {
        CGPoint endPoint = touchPoint;
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects, geoViewScale);
        }
        
        if (point && point != self.startPoint) {
            endPoint = point.position;
            [self.delegate toolTipDidChange:_temporaryTooltipFinished];
            //_temporaryMidPoint.temporary = NO;
        } else {
            [self.delegate toolTipDidChange:_temporaryTooltipUnfinished];
            //_temporaryMidPoint.temporary = YES;
        }
        _temporaryMidPoint.end.position = endPoint;
        [touch.view setNeedsDisplay];
    }
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    // If we already have  a temporary segment defining the midpoint, use that end exit early
    if (_temporarySegment) {
        DHMidPoint* midPoint = [[DHMidPoint alloc] initWithPoint1:_temporarySegment.start
                                                        andPoint2:_temporarySegment.end];
        [self.delegate addGeometricObjects:@[midPoint]];
        [self reset];
        return;
    }
    if (self.circle) {
        [self.delegate addGeometricObjects:@[self.circle.center]];
        [self reset];
        return;
    }
    
    // Do nothing if no start point
    if (!self.startPoint) {
        return;
    }
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:3];
    
    if (_temporaryMidPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryMidPoint]];
        _temporaryMidPoint = nil;
        [self.delegate toolTipDidChange:_partialTooltip];
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
    
    if(!point && DistanceBetweenPoints(_touchPointInViewStart, touchPointInView) > kClosestTapLimit) {
        [self reset];
    }
    
    if (self.startPoint && point && point != self.startPoint) {
        DHMidPoint* midPoint = [[DHMidPoint alloc] initWithPoint1:self.startPoint andPoint2:point];
        [objectsToAdd addObject:midPoint];
        
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
    if (_temporaryMidPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryMidPoint]];
        _temporaryMidPoint = nil;
    }
    if (_temporaryInitialStartingPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        _temporaryInitialStartingPoint = nil;
    }
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
    if (_temporaryMidPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryMidPoint]];
        _temporaryMidPoint = nil;
    }
    if (_temporaryInitialStartingPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        _temporaryInitialStartingPoint = nil;
    }
}
@end