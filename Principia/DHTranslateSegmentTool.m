//
//  DHTranslateSegmentTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHTranslateSegmentTool {
    CGPoint _touchPointInViewStart;
    DHTranslatedPoint* _tempTransPoint;
    DHLineSegment* _tempTransSegment;
    DHPoint* _tempIntersectionPoint;
    DHPoint* _tempStart;
    NSString* _tooltipTempUnfinished;
    NSString* _tooltipTempFinished;
    NSString* _toolTipPartial;
    NSString* _toolTipPartialOnePoint;
}
- (id)init
{
    self = [super init];
    if (self) {
        _tooltipTempUnfinished = @"Drag to a point that should be the start of the translated segment";
        _tooltipTempFinished = @"Release to create translated segment";
        _toolTipPartial = @"Tap on a point to define the starting point of the translated segment";
        _toolTipPartialOnePoint = @"Tap on a second point to define the line segment to be translated";
    }
    return self;
}
- (NSString*)initialToolTip
{
    return @"Tap two points or a line segment you wish to translate";
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
 
    if (self.start == nil || self.end == nil) {
        DHPoint* point= FindPointClosestToPoint(touchPoint, geoObjects, tapLimitInGeo);
        if (point && self.start == nil) {
            self.start = point;
            self.start.highlighted = YES;
            [self.delegate toolTipDidChange:_toolTipPartialOnePoint];
        } else if (point && self.end == nil) {
            self.end = point;
            self.end.highlighted = YES;
            [self.delegate toolTipDidChange:_toolTipPartial];
            endDefinedThisInteraction = YES;
        } else {
            DHLineSegment* line = FindLineSegmentClosestToPoint(touchPoint, geoObjects, tapLimitInGeo);
            if (line) {
                self.segment = line;
                self.start = line.start;
                self.end = line.end;
                self.segment.highlighted = YES;
                [self.delegate toolTipDidChange:_toolTipPartial];
                endDefinedThisInteraction = YES;
            }
        }
    }
    
    if (self.start && self.end) {
        _tempStart = [[DHPoint alloc] initWithPosition:touchPoint];
        _tempTransPoint = [[DHTranslatedPoint alloc] initWithPoint1:self.start
                                                          andPoint2:self.end andOrigin:_tempStart];
        _tempTransSegment = [[DHLineSegment alloc] initWithStart:_tempStart andEnd:_tempTransPoint];
        _tempTransSegment.temporary = YES;
        [self.delegate addTemporaryGeometricObjects:@[_tempTransSegment, _tempTransPoint]];
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
                _tempTransSegment.temporary = NO;
                _tempTransSegment.start = point;
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
    if (_tempTransSegment) {
        _tempTransSegment.start.highlighted = NO;
        _tempTransSegment.start = _tempStart;
        _tempTransPoint.startOfTranslation = _tempStart;
        _tempStart.position = touchPoint;
        _tempTransSegment.temporary = YES;
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, tapLimitInGeo);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects,geoViewScale);
            if (point && point.label.length == 0) {
                _tempIntersectionPoint = point;
                [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionPoint]];
            }
        }
        if (point) {
            _tempTransSegment.temporary = NO;
            _tempTransSegment.start = point;
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
    CGPoint touchPointInView = [touch locationInView:touch.view];
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:3];
    
    if (_tempTransSegment) {
        _tempTransSegment.start.highlighted = NO;
        
        if (_tempTransSegment.start != _tempStart) {
            
            if (self.disableWhenOnSameLine) {
                // Check if point is on line and then do nothing
                DHLine* l = [[DHLine alloc] initWithStart:self.start andEnd:self.end];
                if (PointOnLine(_tempTransSegment.start, l)) {
                    [self.delegate showTemporaryMessage:@"Not allowed, point lies on same line as segment"
                                                atPoint:touchPointInView withColor:[UIColor redColor]];
                    [self reset];
                    [touch.view setNeedsDisplay];
                    return;
                }
            }
            
            if (_tempTransSegment.start.label.length == 0) [objectsToAdd addObject:_tempTransSegment.start];
            [objectsToAdd addObject:_tempTransSegment];
            [objectsToAdd addObject:_tempTransPoint];
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
    if (self.segment || self.start || self.end) {
        return YES;
    }
    
    return NO;
}
- (void)reset
{
    [self resetTemporaryObjects];
    self.segment.highlighted = NO;
    self.start.highlighted = NO;
    self.end.highlighted = NO;
    self.segment = nil;
    self.start = nil;
    self.end = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)resetTemporaryObjects
{
    if (_tempTransPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempTransPoint]];
        _tempTransPoint = nil;
    }
    if (_tempTransSegment) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempTransSegment]];
        _tempTransSegment = nil;
    }
    if (_tempIntersectionPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempIntersectionPoint]];
        _tempIntersectionPoint = nil;
    }
}
- (void)dealloc
{
    [self resetTemporaryObjects];
    self.segment.highlighted = NO;
    self.start.highlighted = NO;
    self.end.highlighted = NO;
}
@end


