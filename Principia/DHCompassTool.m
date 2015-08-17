//
//  DHCompassTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGeometricTools.h"
#import "DHMath.h"


@implementation DHCompassTool {
    CGPoint _touchPointInViewStart;
    DHTranslatedPoint* _tempTransPoint;
    DHCircle* _tempCircle;
    DHPoint* _tempIntersectionCenter;
    DHPoint* _tempIntersectionPoint1;
    DHPoint* _tempIntersectionPoint2;
    DHPoint* _tempCenter;
    NSString* _tooltipTempUnfinished;
    NSString* _tooltipTempFinished;
    NSString* _toolTipPartial;
    NSString* _toolTipPartialOnePoint;
}
- (id)init
{
    self = [super init];
    if (self) {
        _tooltipTempUnfinished = @"Drag to a point that should be the center of the circle";
        _tooltipTempFinished = @"Release to create circle";
        _toolTipPartial = @"Tap a point to mark the center of the circle";
        _toolTipPartialOnePoint = @"Tap a second point to define the radius";
    }
    return self;
}
- (NSString*)initialToolTip
{
    return @"Tap two points, a segment or a circle to define the radius";
}
- (void)touchBegan:(UITouch*)touch
{
    _touchPointInViewStart = [touch locationInView:touch.view];
    
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    NSArray *geoObjects = self.delegate.geometryObjects;
    const CGFloat tapLimitInGeo = kClosestTapLimit / geoViewScale;
    BOOL endDefinedThisInteraction = NO;
    
    if (self.firstPoint == nil || self.secondPoint == nil) {
        DHPoint* point= FindPointClosestToPoint(touchPoint, geoObjects, tapLimitInGeo);
        DHLineSegment* line = nil;
        
        // Prefer existing points first, line segment second, new intersections third, circle fourth
        if (!point) {
            line = FindLineSegmentClosestToPoint(touchPoint, geoObjects, tapLimitInGeo);
        }
        if (!point && !line) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects,geoViewScale);
            if (point && !self.firstPoint) {
                _tempIntersectionPoint1 = point;
                [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionPoint1]];
            } else if (point && !self.secondPoint) {
                _tempIntersectionPoint2 = point;
                [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionPoint2]];
            }
        }
        if (!point && !line) {
            DHCircle* circle = FindCircleClosestToPoint(touchPoint, geoObjects, tapLimitInGeo);
            if (circle) {
                self.radiusCircle = circle;
                self.radiusCircle.highlighted = YES;
                line = [[DHLineSegment alloc]initWithStart:circle.center andEnd:circle.pointOnRadius];
            }
        }
        
        if (point && self.firstPoint == nil) {
            self.firstPoint = point;
            self.firstPoint.highlighted = YES;
            [self.delegate toolTipDidChange:_toolTipPartialOnePoint];
        } else if (point && self.secondPoint == nil) {
            self.secondPoint = point;
            self.secondPoint.highlighted = YES;
            [self.delegate toolTipDidChange:_toolTipPartial];
            endDefinedThisInteraction = YES;
        } else if (self.firstPoint == nil && line) {
            self.radiusSegment = line;
            self.firstPoint = line.start;
            self.secondPoint = line.end;
            self.radiusSegment.highlighted = YES;
            [self.delegate toolTipDidChange:_toolTipPartial];
            endDefinedThisInteraction = YES;
        }
    }
    
    if (self.firstPoint && self.secondPoint && !endDefinedThisInteraction) {
        _tempCenter = [[DHPoint alloc] initWithPosition:touchPoint];
        _tempTransPoint = [[DHTranslatedPoint alloc] initWithPoint1:self.firstPoint
                                                          andPoint2:self.secondPoint andOrigin:_tempCenter];
        _tempCircle = [[DHCircle alloc] initWithCenter:_tempCenter  andPointOnRadius:_tempTransPoint];
        _tempCircle.temporary = YES;
        [self.delegate addTemporaryGeometricObjects:@[_tempCircle]];
        [self.delegate toolTipDidChange:_tooltipTempUnfinished];
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, tapLimitInGeo);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects,geoViewScale);
            if (point) {
                _tempIntersectionCenter = point;
                [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionCenter]];
            }
        }
        if (point) {
            _tempCircle.temporary = NO;
            _tempCircle.center = point;
            _tempTransPoint.startOfTranslation = point;
            point.highlighted = YES;
            [self.delegate toolTipDidChange:_tooltipTempFinished];
        }
    }
    
    [touch.view setNeedsDisplay];
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    NSArray *geoObjects = self.delegate.geometryObjects;
    const CGFloat tapLimitInGeo = kClosestTapLimit / geoViewScale;
    
    if (_tempIntersectionCenter) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionCenter]];
        _tempIntersectionCenter = nil;
    }
    
    if (self.firstPoint && self.secondPoint && !_tempCircle) {
        _tempCenter = [[DHPoint alloc] initWithPosition:touchPoint];
        _tempTransPoint = [[DHTranslatedPoint alloc] initWithPoint1:self.firstPoint
                                                          andPoint2:self.secondPoint andOrigin:_tempCenter];
        _tempCircle = [[DHCircle alloc] initWithCenter:_tempCenter  andPointOnRadius:_tempTransPoint];
        _tempCircle.temporary = YES;
        [self.delegate addTemporaryGeometricObjects:@[_tempCircle]];
        [self.delegate toolTipDidChange:_tooltipTempUnfinished];
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, tapLimitInGeo);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects,geoViewScale);
            if (point) {
                _tempIntersectionCenter = point;
                [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionCenter]];
            }
        }
        if (point) {
            _tempCircle.temporary = NO;
            _tempCircle.center = point;
            _tempTransPoint.startOfTranslation = point;
            point.highlighted = YES;
            [self.delegate toolTipDidChange:_tooltipTempFinished];
        }
    }
    
    
    if (_tempCircle) {
        if (self.radiusSegment || (_tempCircle.center != self.firstPoint && _tempCircle.center != self.secondPoint)) {
            _tempCircle.center.highlighted = NO;
        }
        _tempCircle.center = _tempCenter;
        _tempTransPoint.startOfTranslation = _tempCenter;
        _tempCenter.position = touchPoint;
        _tempCircle.temporary = YES;
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, tapLimitInGeo);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects,geoViewScale);
            if (point && point.label.length == 0) {
                _tempIntersectionCenter = point;
                [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionCenter]];
            }
        }
        if (point) {
            _tempCircle.temporary = NO;
            _tempCircle.center = point;
            _tempTransPoint.startOfTranslation = point;
            point.highlighted = YES;
            [self.delegate toolTipDidChange:_tooltipTempFinished];
        } else {
            [self.delegate toolTipDidChange:_tooltipTempUnfinished];
        }
        
        [touch.view setNeedsDisplay];
    }
}
- (void)touchEnded:(UITouch*)touch
{
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:3];
    
    if (_tempCircle) {
        if (self.radiusSegment || (_tempCircle.center != self.firstPoint && _tempCircle.center != self.secondPoint)) {
            _tempCircle.center.highlighted = NO;
        }
        
        if (_tempCircle.center != _tempCenter) {
            if (_tempIntersectionCenter) [objectsToAdd addObject:_tempIntersectionCenter];
            [objectsToAdd addObject:_tempCircle];
            [self.delegate addGeometricObjects:objectsToAdd];
            [self reset];
        } else {
            [self.delegate toolTipDidChange:_toolTipPartial];
            [self resetTemporaryObjects];
        }
    }
    
    [touch.view setNeedsDisplay];
}
- (BOOL)active
{
    if (self.radiusSegment || self.firstPoint || self.secondPoint) {
        return YES;
    }
    
    return NO;
}
- (void)reset
{
    [self resetTemporaryObjects];
    
    if (_tempIntersectionPoint1) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionPoint1]];
        _tempIntersectionPoint1 = nil;
    }
    if (_tempIntersectionPoint2) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionPoint2]];
        _tempIntersectionPoint2 = nil;
    }
    
    self.radiusSegment.highlighted = NO;
    self.radiusCircle.highlighted = NO;
    self.firstPoint.highlighted = NO;
    self.secondPoint.highlighted = NO;
    self.radiusSegment = nil;
    self.firstPoint = nil;
    self.secondPoint = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)resetTemporaryObjects
{
    _tempTransPoint = nil;
    if (_tempCircle) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempCircle]];
        _tempCircle = nil;
    }
    if (_tempCircle) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempCircle]];
        _tempCircle = nil;
    }
    if (_tempIntersectionCenter) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionCenter]];
        _tempIntersectionCenter = nil;
    }
}
- (void)dealloc
{
    [self resetTemporaryObjects];
    
    if (_tempIntersectionPoint1) [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionPoint1]];
    if (_tempIntersectionPoint2) [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionPoint2]];

    self.radiusCircle.highlighted = NO;
    self.radiusSegment.highlighted = NO;
    self.firstPoint.highlighted = NO;
    self.secondPoint.highlighted = NO;
}
@end
