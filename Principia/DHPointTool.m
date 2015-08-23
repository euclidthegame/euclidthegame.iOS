//
//  DHPointTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHPointTool {
    DHPoint* _temporaryPoint;
    DHGeometricObject* _temporarySnapTo;
}
- (NSString*)initialToolTip
{
    return @"Tap anywhere to create a new point, or hold down on an existing free (gray) point to move it";
}
- (void)touchBegan:(UITouch*)touch
{
    if (self.point) {
        return;
    }
    
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    self.touchStart = touchPoint;

    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
    if (point && ([point class] == [DHPoint class] ||
                  [point class] == [DHPointOnLine class] ||
                  [point class] == [DHPointOnCircle class] ||
                  [point class] == [DHPointWithBlockConstraint class]) ) {
        self.point = point;
        self.point.highlighted = YES;
        [self.delegate toolTipDidChange:@"Move the point to the desired location and release"];
        [touch.view setNeedsDisplay];
    } else {
        // No moveable point found near touch point, create a new temporary point

        // Check if there are any objects to snap to nearby
        id closestObject = FindClosestIntersectableNearPoint(touchPoint, self.delegate.geometryObjects,
                                                             kClosestTapLimit / geoViewScale);
        
        // If a close object to snap to was found, create a point fixed to the object, else a free point
        if (closestObject != nil) {
            _temporarySnapTo = closestObject;
            _temporarySnapTo.highlighted = YES;
            if ([[closestObject class] isSubclassOfClass:[DHLineObject class]]) {
                DHLineObject* line = closestObject;
                
                CGPoint closestPointOnLine = ClosestPointOnLineFromPosition(touchPoint, line);
                CGFloat tValue = CGVectorDotProduct(line.vector,
                                                    CGVectorBetweenPoints(line.start.position,closestPointOnLine))/CGVectorDotProduct(line.vector, line.vector);
                
                _temporaryPoint = [[DHPointOnLine alloc] initWithLine:line andTValue:tValue];
            }
            if ([[closestObject class] isSubclassOfClass:[DHCircle class]]) {
                DHCircle* circle = closestObject;
                
                CGVector vCenterTouchPoint = CGVectorBetweenPoints(circle.center.position, touchPoint);
                CGFloat angle = CGVectorAngleBetween(vCenterTouchPoint, CGVectorMake(1, 0));
                
                if (touchPoint.y < circle.center.position.y) {
                    angle = 2*M_PI - angle;
                }
                
                _temporaryPoint = [[DHPointOnCircle alloc] initWithCircle:circle andAngle:angle];
            }
        } else {
            _temporaryPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        }
        
        if (_temporaryPoint) {
            self.point = _temporaryPoint;
            [self.delegate addTemporaryGeometricObjects:@[_temporaryPoint]];
            [self.delegate toolTipDidChange:@"Move the point to the desired location and release"];
            [touch.view setNeedsDisplay];
        }
    }
}
- (void)touchMoved:(UITouch*)touch
{
    if (self.point &&
        ([self.point class] == [DHPoint class] || [self.point class] == [DHPointWithBlockConstraint class]))
    {
        CGPoint touchPointInView = [touch locationInView:touch.view];
        CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
        
        CGPoint previousPosition = self.point.position;
        previousPosition.x = previousPosition.x + touchPoint.x - self.touchStart.x;
        previousPosition.y = previousPosition.y + touchPoint.y - self.touchStart.y;
        self.point.position = previousPosition;
        self.touchStart = touchPoint;
        
        // Update position of all other objects & redraw
        [self.delegate updateAllPositions];
        [touch.view setNeedsDisplay];
    }
    if (self.point && [self.point class] == [DHPointOnLine class]) {
        CGPoint touchPointInView = [touch locationInView:touch.view];
        CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
        DHPointOnLine* pLine = (DHPointOnLine*)self.point;
        CGPoint closestPointOnLine = ClosestPointOnLineFromPosition(touchPoint, pLine.line);
        CGFloat tValue = CGVectorDotProduct(pLine.line.vector, CGVectorBetweenPoints(pLine.line.start.position, closestPointOnLine))/CGVectorDotProduct(pLine.line.vector, pLine.line.vector);
        
        pLine.tValue = tValue;
        
        // Update position of all other objects & redraw
        [self.delegate updateAllPositions];
        [touch.view setNeedsDisplay];
    }
    if (self.point && [self.point class] == [DHPointOnCircle class]) {
        CGPoint touchPointInView = [touch locationInView:touch.view];
        CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
        
        DHPointOnCircle* pCircle = (DHPointOnCircle*)self.point;
        DHCircle* circle = pCircle.circle;
        
        CGVector vCenterTouchPoint = CGVectorBetweenPoints(circle.center.position, touchPoint);
        CGFloat angle = CGVectorAngleBetween(vCenterTouchPoint, CGVectorMake(1, 0));
        
        if (touchPoint.y < circle.center.position.y) {
            angle = 2*M_PI - angle;
        }
        
        pCircle.angle = angle;
        
        // Update position of all other objects & redraw
        [self.delegate updateAllPositions];
        [touch.view setNeedsDisplay];
    }
    
}
- (void)touchEnded:(UITouch*)touch
{
    if (_temporaryPoint) {
        [self.delegate addGeometricObject:_temporaryPoint];
        [self reset];
        return;
    }

    if (self.point) {
        // If a point is being moved, simply reset and exit early
        [self reset];
        [touch.view setNeedsDisplay];
        return;
    }
}
- (BOOL)active
{
    return NO;
}
- (void)reset
{
    DHToolTempObjectCleanup(_temporaryPoint);
    
    _temporarySnapTo.highlighted = NO;
    self.point.highlighted = NO;
    self.point = nil;
    self.associatedTouch = 0;
    [self.delegate toolTipDidChange:self.initialToolTip];
}

- (void)dealloc
{
    DHToolTempObjectCleanup(_temporaryPoint);

    _temporarySnapTo.highlighted = NO;
    self.point.highlighted = NO;
}
@end
