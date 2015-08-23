//
//  DHTriangleTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHTriangleTool {
    CGPoint _touchPointInViewStart;
    DHPoint* _tempEndPoint;
    DHPoint* _tempIntersectionStart;
    DHPoint* _tempIntersectionEnd;
    DHTrianglePoint* _tempTrianglePoint;
    DHLineSegment* _temporarySegment1;
    DHLineSegment* _temporarySegment2;
    NSString* _temporaryTooltipUnfinished;
    NSString* _temporaryTooltipFinished;
    NSString* _partialTooltip;
}
- (id)init
{
    self = [super init];
    if (self) {
        _temporaryTooltipUnfinished = @"Drag to a second point defining the second corner of the triangle";
        _temporaryTooltipFinished = @"Release to create triangle";
        _partialTooltip = @"Tap on a second point defining the second corner of the triangle";
    }
    return self;
}
- (NSString*)initialToolTip
{
    return @"Tap a point that will form one of the corners in the triangle (counter-clockwise order)";
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
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects,geoViewScale);
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
        
        if (_tempIntersectionStart) [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionStart]];
        [touch.view setNeedsDisplay];
    } else if (self.startPoint) {
        // If there already is a startpoint use current point/touch point as temporary end point
        _tempEndPoint = [[DHPoint alloc] initWithPosition:touchPoint];
        _tempTrianglePoint = [[DHTrianglePoint alloc] initWithPoint1:self.startPoint andPoint2:_tempEndPoint];
        _temporarySegment1 = [[DHLineSegment alloc] initWithStart:self.startPoint andEnd:_tempTrianglePoint];
        _temporarySegment2 = [[DHLineSegment alloc] initWithStart:_tempTrianglePoint andEnd:_tempEndPoint];
        if (point && point != self.startPoint) {
            _tempTrianglePoint.end = point;
            _temporarySegment2.end = point;
            point.highlighted = YES;
            [self.delegate toolTipDidChange:_temporaryTooltipFinished];
        } else {
            _tempTrianglePoint.end.position = touchPoint;
            _temporarySegment1.temporary = YES;
            _temporarySegment2.temporary = YES;
            [self.delegate toolTipDidChange:_temporaryTooltipUnfinished];
        }
        [self.delegate addTemporaryGeometricObjects:@[_tempTrianglePoint, _temporarySegment1, _temporarySegment2]];
        if (_tempIntersectionEnd) [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionEnd]];
        
        [touch.view setNeedsDisplay];
    }
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    NSArray* geoObjects = self.delegate.geometryObjects;
    
    if (!_tempTrianglePoint && self.startPoint) {
        _tempEndPoint = [[DHPoint alloc] initWithPosition:touchPoint];
        _tempTrianglePoint = [[DHTrianglePoint alloc] initWithPoint1:self.startPoint andPoint2:_tempEndPoint];
        _temporarySegment1 = [[DHLineSegment alloc] initWithStart:self.startPoint andEnd:_tempTrianglePoint];
        _temporarySegment2 = [[DHLineSegment alloc] initWithStart:_tempTrianglePoint andEnd:_tempEndPoint];
        _temporarySegment1.temporary = YES;
        _temporarySegment2.temporary = YES;
        
        [self.delegate addTemporaryGeometricObjects:@[_tempTrianglePoint, _temporarySegment1, _temporarySegment2]];
        [touch.view setNeedsDisplay];
    }
    DHToolTempObjectCleanup(_tempIntersectionEnd);
    
    if (_tempTrianglePoint) {
        _temporarySegment2.end.highlighted = NO;
        _tempEndPoint.position = touchPoint;
        _tempTrianglePoint.end = _tempEndPoint;
        _temporarySegment2.end = _tempEndPoint;
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects, geoViewScale);
            if (point) _tempIntersectionEnd = point;
        }
        
        if (point && point != self.startPoint) {
            _tempTrianglePoint.end = point;
            _temporarySegment2.end = point;
            [self.delegate toolTipDidChange:_temporaryTooltipFinished];
            _temporarySegment1.temporary = NO;
            _temporarySegment2.temporary = NO;
            _temporarySegment2.end.highlighted = YES;
            
            if (_tempIntersectionEnd) {
                [self.delegate addTemporaryGeometricObjects:@[_tempIntersectionEnd]];
            }
            
        } else {
            [self.delegate toolTipDidChange:_temporaryTooltipUnfinished];
            _temporarySegment1.temporary = YES;
            _temporarySegment2.temporary = YES;
        }
        [touch.view setNeedsDisplay];
    }
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    
    // Do nothing if no start point
    if (!self.startPoint) {
        return;
    }
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:5];
    
    if (_tempTrianglePoint) {
        _temporarySegment2.end.highlighted = NO;
        [self.delegate removeTemporaryGeometricObjects:@[_tempTrianglePoint,
                                                         _temporarySegment1,
                                                         _temporarySegment2]];
        if (_temporarySegment2.end != _tempEndPoint) {
            _temporarySegment1.temporary = NO;
            _temporarySegment2.temporary = NO;

            if (_tempIntersectionStart) [objectsToAdd addObject:_tempIntersectionStart];
            if (_tempIntersectionEnd) [objectsToAdd addObject:_tempIntersectionEnd];            
            [objectsToAdd addObjectsFromArray:@[_tempTrianglePoint, _temporarySegment1, _temporarySegment2]];
            
            [self.delegate addGeometricObjects:objectsToAdd];
            
            [self reset];
        } else {
            
            if(DistanceBetweenPoints(_touchPointInViewStart, touchPointInView) > kClosestTapLimit ) {
                [self reset];
            } else {
                _tempTrianglePoint = nil;
                _temporarySegment1 = nil;
                _temporarySegment2 = nil;
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
    if (self.startPoint) {
        return YES;
    }
    return NO;
}
- (void)reset
{
    if (_tempTrianglePoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempTrianglePoint,
                                                         _temporarySegment1,
                                                         _temporarySegment2]];
        _tempTrianglePoint = nil;
        _temporarySegment1 = nil;
        _temporarySegment2 = nil;
    }
    DHToolTempObjectCleanup(_tempIntersectionStart);
    DHToolTempObjectCleanup(_tempIntersectionEnd);
    
    self.startPoint.highlighted = NO;
    self.startPoint = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}

- (void)dealloc
{
    if (_tempTrianglePoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_tempTrianglePoint,
                                                         _temporarySegment1,
                                                         _temporarySegment2]];
    }
    DHToolTempObjectCleanup(_tempIntersectionStart);
    DHToolTempObjectCleanup(_tempIntersectionEnd);
    self.startPoint.highlighted = false;
}
@end