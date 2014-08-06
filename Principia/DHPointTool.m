//
//  DHPointTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHPointTool
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
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
    if (point && ([point class] == [DHPoint class] ||
                  [point class] == [DHPointOnLine class] ||
                  [point class] == [DHPointOnCircle class] ||
                  [point class] == [DHPointWithBlockConstraint class]) ) {
        self.point = point;
        self.point.highlighted = YES;
        self.touchStart = touchPoint;
        [self.delegate toolTipDidChange:@"Move the point to the desired location and release"];
        [touch.view setNeedsDisplay];
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
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    if (self.point) {
        self.point.highlighted = NO;
        self.point = nil;
        [self.delegate toolTipDidChange:self.initialToolTip];
        [touch.view setNeedsDisplay];
    } else {
        CGPoint touchPointInView = [touch locationInView:touch.view];
        CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
        
        // Check if there are any objects to snap to nearby
        NSArray* nearObjects = FindIntersectablesNearPoint(touchPoint, self.delegate.geometryObjects,
                                                           kClosestTapLimit / geoViewScale);
        id<DHGeometricObject> closestObject = nil;
        CGFloat closestDistance = kClosestTapLimit / geoViewScale;
        
        if (nearObjects.count > 0) {
            for (id object in nearObjects) {
                if ([[object class] isSubclassOfClass:[DHLineObject class]]) {
                    CGFloat dist = DistanceFromPositionToLine(touchPoint, object);
                    if (dist < closestDistance) {
                        closestDistance = dist;
                        closestObject = object;
                    }
                }
                if ([[object class] isSubclassOfClass:[DHCircle class]]) {
                    CGFloat dist = DistanceFromPositionToCircle(touchPoint, object);
                    if (dist < closestDistance) {
                        closestDistance = dist;
                        closestObject = object;
                    }
                }
            }
        }
        
        // If a close object to snap to was found, create a point fixed to the object, else a free point
        if (closestObject != nil) {
            if ([[closestObject class] isSubclassOfClass:[DHLineObject class]]) {
                DHLineObject* line = closestObject;
                
                CGPoint closestPointOnLine = ClosestPointOnLineFromPosition(touchPoint, line);
                CGFloat tValue = CGVectorDotProduct(line.vector, CGVectorBetweenPoints(line.start.position, closestPointOnLine))/CGVectorDotProduct(line.vector, line.vector);
                
                DHPointOnLine* point = [[DHPointOnLine alloc] init];
                point.line = line;
                point.tValue = tValue;
                [self.delegate addGeometricObject:point];
            }
            if ([[closestObject class] isSubclassOfClass:[DHCircle class]]) {
                DHCircle* circle = closestObject;
                
                CGVector vCenterTouchPoint = CGVectorBetweenPoints(circle.center.position, touchPoint);
                CGFloat angle = CGVectorAngleBetween(vCenterTouchPoint, CGVectorMake(1, 0));
                
                if (touchPoint.y < circle.center.position.y) {
                    angle = 2*M_PI - angle;
                }
                
                DHPointOnCircle* point = [[DHPointOnCircle alloc] init];
                point.circle = circle;
                point.angle = angle;
                [self.delegate addGeometricObject:point];
                
            }
        } else {
            DHPoint* point = [[DHPoint alloc] init];
            point.position = touchPoint;
            [self.delegate addGeometricObject:point];
        }
    }
}
- (BOOL)active
{
    return false;
}
- (void)reset
{
    self.associatedTouch = 0;
}

- (void)dealloc
{
    if (self.point) {
        self.point.highlighted = NO;
    }
}
@end
