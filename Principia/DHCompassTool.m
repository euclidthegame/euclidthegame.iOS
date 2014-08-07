//
//  DHCompassTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHMath.h"


@implementation DHCompassTool {
    CGPoint _touchPointInViewStart;
    DHTranslatedPoint* _tempTransPoint;
    DHCircle* _tempCircle;
    DHPoint* _tempIntersectionPoint;
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
        _toolTipPartialOnePoint = @"Tap a second point to define the radius of the circle";
    }
    return self;
}
- (NSString*)initialToolTip
{
    return @"Tap two points or a line segment to define the radius, followed by a third point to mark the center";
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
        if (point && self.firstPoint == nil) {
            self.firstPoint = point;
            self.firstPoint.highlighted = YES;
            [self.delegate toolTipDidChange:_toolTipPartialOnePoint];
        } else if (point && self.secondPoint == nil) {
            self.secondPoint = point;
            self.secondPoint.highlighted = YES;
            [self.delegate toolTipDidChange:_toolTipPartial];
            endDefinedThisInteraction = YES;
        } else if (self.firstPoint == nil) {
            DHLineSegment* line = FindLineSegmentClosestToPoint(touchPoint, geoObjects, tapLimitInGeo);
            if (line) {
                self.radiusSegment = line;
                self.firstPoint = line.start;
                self.secondPoint = line.end;
                self.radiusSegment.highlighted = YES;
                [self.delegate toolTipDidChange:_toolTipPartial];
                endDefinedThisInteraction = YES;
            }
        }
    }
    
    if (self.firstPoint && self.secondPoint) {
        _tempCenter = [[DHPoint alloc] initWithPosition:touchPoint];
        _tempTransPoint = [[DHTranslatedPoint alloc] initWithPoint1:self.firstPoint
                                                          andPoint2:self.secondPoint andOrigin:_tempCenter];
        _tempCircle = [[DHCircle alloc] initWithCenter:_tempCenter  andPointOnRadius:_tempTransPoint];
        _tempCircle.temporary = YES;
        [self.delegate addTemporaryGeometricObjects:@[_tempCircle]];
        [self.delegate toolTipDidChange:_tooltipTempUnfinished];
        
        if(!endDefinedThisInteraction) {
            DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, tapLimitInGeo);
            if (!point) {
                point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects,geoViewScale);
                if (point && point.label.length == 0) {
                    _tempIntersectionPoint = point;
                    [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionPoint]];
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
    
    if (_tempIntersectionPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionPoint]];
        _tempIntersectionPoint = nil;
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
                _tempIntersectionPoint = point;
                [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionPoint]];
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
            if (_tempIntersectionPoint) [objectsToAdd addObject:_tempIntersectionPoint];
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
    self.radiusSegment.highlighted = NO;
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
    if (_tempIntersectionPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionPoint]];
        _tempIntersectionPoint = nil;
    }
}
- (void)dealloc
{
    [self resetTemporaryObjects];
    self.radiusSegment.highlighted = NO;
    self.firstPoint.highlighted = NO;
    self.secondPoint.highlighted = NO;
}
@end


#if 0
@implementation DHCompassTool
- (NSString*)initialToolTip
{
    return @"Tap two points or a line segment to define the radius, followed by a third point to mark the center";
}
- (void)touchBegan:(UITouch*)touch
{
    
}
- (void)touchMoved:(UITouch*)touch
{
    
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    NSArray* geoObjects = self.delegate.geometryObjects;
    
    DHPoint* point= FindPointClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
    DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects, geoViewScale);
    
    // Prefers normal point selection above automatic intersection
    if (intersectionPoint && !(point)) {
        [self.delegate addGeometricObject:intersectionPoint];
        point = intersectionPoint;
    }
    
    if (point) {
        if (self.firstPoint) {
            if (self.secondPoint) {
                DHTranslatedPoint* pointOnRadius = [[DHTranslatedPoint alloc] init];
                pointOnRadius.startOfTranslation = point;
                pointOnRadius.translationStart = self.firstPoint;
                pointOnRadius.translationEnd = self.secondPoint;
                
                DHCircle* circle = [[DHCircle alloc] initWithCenter:point andPointOnRadius:pointOnRadius];
                [self.delegate addGeometricObject:circle];
                
                [self reset];
            } else if (point != self.firstPoint) {
                self.secondPoint = point;
                point.highlighted = YES;
                [self.delegate toolTipDidChange:@"Tap on a third point to mark the center of the circle"];
                [touch.view setNeedsDisplay];
            }
        } else {
            self.firstPoint = point;
            point.highlighted = YES;
            [self.delegate toolTipDidChange:@"Tap on a second point to mark the radius of the circle"];
            [touch.view setNeedsDisplay];
        }
    } else if (self.firstPoint == nil) {
        DHLineSegment* segment = FindLineSegmentClosestToPoint(touchPoint, self.delegate.geometryObjects,
                                                               kClosestTapLimit / geoViewScale);
        if (segment) {
            self.firstPoint = segment.start;
            self.secondPoint = segment.end;
            self.radiusSegment = segment;
            segment.highlighted = YES;
            [self.delegate toolTipDidChange:@"Tap on a point to mark the center of the circle"];
            [touch.view setNeedsDisplay];
        }
    }
}
- (BOOL)active
{
    if (self.firstPoint || self.secondPoint || self.radiusSegment) {
        return YES;
    }
    
    return NO;
}
- (void)reset
{
    self.firstPoint.highlighted = NO;
    self.secondPoint.highlighted = NO;
    self.radiusSegment.highlighted = NO;
    self.firstPoint = nil;
    self.secondPoint = nil;
    self.radiusSegment = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)dealloc
{
    self.firstPoint.highlighted = NO;
    self.secondPoint.highlighted = NO;
    self.radiusSegment.highlighted = NO;
}
@end
#endif