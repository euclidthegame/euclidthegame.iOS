//
//  DHTriangleTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHTriangleTool {
    CGPoint _touchPointInViewStart;
    DHPoint* _temporaryInitialStartingPoint;
    DHTrianglePoint* _temporaryTrianglePoint;
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
    
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
    if (!point) {
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
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
        _temporaryTrianglePoint = [[DHTrianglePoint alloc] initWithPoint1:self.startPoint andPoint2:endPoint];
        _temporarySegment1 = [[DHLineSegment alloc] initWithStart:self.startPoint andEnd:_temporaryTrianglePoint];
        _temporarySegment2 = [[DHLineSegment alloc] initWithStart:_temporaryTrianglePoint andEnd:endPoint];
        if (point && point != self.startPoint) {
            _temporaryTrianglePoint.end.position = point.position;
            [self.delegate toolTipDidChange:_temporaryTooltipFinished];
        } else {
            _temporaryTrianglePoint.end.position = touchPoint;
            _temporarySegment1.temporary = YES;
            _temporarySegment2.temporary = YES;
            [self.delegate toolTipDidChange:_temporaryTooltipUnfinished];
        }
        [self.delegate addTemporaryGeometricObjects:@[_temporaryTrianglePoint, _temporarySegment1, _temporarySegment2]];
        [touch.view setNeedsDisplay];
    }
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    if (!_temporaryTrianglePoint && self.startPoint) {
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryTrianglePoint = [[DHTrianglePoint alloc] initWithPoint1:self.startPoint andPoint2:endPoint];
        _temporarySegment1 = [[DHLineSegment alloc] initWithStart:self.startPoint andEnd:_temporaryTrianglePoint];
        _temporarySegment2 = [[DHLineSegment alloc] initWithStart:_temporaryTrianglePoint andEnd:endPoint];
        _temporarySegment1.temporary = YES;
        _temporarySegment2.temporary = YES;
        
        [self.delegate addTemporaryGeometricObjects:@[_temporaryTrianglePoint, _temporarySegment1, _temporarySegment2]];
        [touch.view setNeedsDisplay];
    }
    
    if (_temporaryTrianglePoint) {
        CGPoint endPoint = touchPoint;
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects, geoViewScale);
        }
        
        if (point && point != self.startPoint) {
            endPoint = point.position;
            [self.delegate toolTipDidChange:_temporaryTooltipFinished];
            _temporarySegment1.temporary = NO;
            _temporarySegment2.temporary = NO;
        } else {
            [self.delegate toolTipDidChange:_temporaryTooltipUnfinished];
            _temporarySegment1.temporary = YES;
            _temporarySegment2.temporary = YES;
        }
        _temporaryTrianglePoint.end.position = endPoint;
        [touch.view setNeedsDisplay];
    }
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    // Do nothing if no start point
    if (!self.startPoint) {
        return;
    }
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:3];
    
    if (_temporaryTrianglePoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryTrianglePoint,
                                                         _temporarySegment1,
                                                         _temporarySegment2]];
        _temporaryTrianglePoint = nil;
        _temporarySegment1 = nil;
        _temporarySegment2 = nil;
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
        DHTrianglePoint* triPoint = [[DHTrianglePoint alloc] initWithPoint1:self.startPoint andPoint2:point];
        DHLineSegment* side1 = [[DHLineSegment alloc] initWithStart:self.startPoint andEnd:triPoint];
        DHLineSegment* side2 = [[DHLineSegment alloc] initWithStart:triPoint andEnd:point];
        [objectsToAdd addObjectsFromArray:@[triPoint, side1, side2]];
        
        [self reset];
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
    if (self.startPoint) {
        return YES;
    }
    return NO;
}
- (void)reset
{
    if (_temporaryTrianglePoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryTrianglePoint,
                                                         _temporarySegment1,
                                                         _temporarySegment2]];
        _temporaryTrianglePoint = nil;
        _temporarySegment1 = nil;
        _temporarySegment2 = nil;
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
    if (_temporaryTrianglePoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryTrianglePoint,
                                                         _temporarySegment1,
                                                         _temporarySegment2]];
    }
    if (_temporaryInitialStartingPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
    }
    self.startPoint.highlighted = false;
}
@end