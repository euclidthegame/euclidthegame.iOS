//
//  DHGeometricTools.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHGeometricObjects.h"
#import "DHMath.h"

const CGFloat kClosestTapLimit = 25.0f;

@implementation DHGeometryTool
@end

@implementation DHZoomPanTool
- (NSString *)initialToolTip
{
    return @"Use two fingers to zoom in/out and pan the drawing area";
}
- (void)touchBegan:(UITouch *)touch
{
    
}
- (void)touchMoved:(UITouch *)touch
{
    
}
- (void)touchEnded:(UITouch *)touch
{
    
}
- (BOOL)active
{
    return false;
}
- (void)reset
{
    self.associatedTouch = 0;
}
@end

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


@implementation DHLineSegmentTool {
    CGPoint _touchPointInViewStart;
    DHPoint* _temporaryInitialStartingPoint;
    DHLineSegment* _temporaryLine;
}
- (NSString*)initialToolTip
{
    return @"Tap on a point to mark the start of a new line segment";
}
- (void)touchBegan:(UITouch*)touch
{
    _touchPointInViewStart = [touch locationInView:touch.view];

    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];

    // Find closest point, or intersection point
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
    if (!point) {
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        if (intersectionPoint) {
            if (!self.startPoint) _temporaryInitialStartingPoint = intersectionPoint;
            point = intersectionPoint;
        }
    }
    
    if (!self.startPoint && point) {
        // If no starting yet and point was found, use as starting point and highlight it
        self.startPoint = point;
        point.highlighted = true;
        [self.delegate toolTipDidChange:@"Drag to a point defining the end point of the segment"];
        
        if (_temporaryInitialStartingPoint) {
            [self.delegate addTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        }
        [touch.view setNeedsDisplay];
    } else if (self.startPoint) {
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryLine = [[DHLineSegment alloc] initWithStart:self.startPoint andEnd:endPoint];
        if (point && point != self.startPoint) {
            _temporaryLine.end.position = point.position;
            [self.delegate toolTipDidChange:@"Release to create line segment"];

        } else {
            _temporaryLine.end.position = touchPoint;
            _temporaryLine.temporary = YES;
            [self.delegate toolTipDidChange:@"Drag to a point defining the end point of the segment"];
        }
        [self.delegate addTemporaryGeometricObjects:@[_temporaryLine]];
        [touch.view setNeedsDisplay];
    }
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    if (!_temporaryLine && self.startPoint) {
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryLine = [[DHLineSegment alloc] initWithStart:self.startPoint andEnd:endPoint];
        [self.delegate addTemporaryGeometricObjects:@[_temporaryLine]];
        [touch.view setNeedsDisplay];
    }
    
    if (_temporaryLine) {
        CGPoint endPoint = touchPoint;
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects, geoViewScale);
        }
        if (point && point != self.startPoint) {
            endPoint = point.position;
            [self.delegate toolTipDidChange:@"Release to create line segment"];
            _temporaryLine.temporary = NO;
            [touch.view setNeedsDisplay];
        } else {
            [self.delegate toolTipDidChange:@"Drag to a point defining the end point of the segment"];
            _temporaryLine.temporary = YES;
        }
        _temporaryLine.end.position = endPoint;
        [touch.view setNeedsDisplay];
    }
}
- (void)touchEnded:(UITouch*)touch
{
    // Do nothing if no start point
    if (!self.startPoint) {
        return;
    }
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:3];
    
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    if (_temporaryLine) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryLine]];
        _temporaryLine = nil;
        [self.delegate toolTipDidChange:@"Tap on a second point to mark the end the line segment"];
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
    
    if(!point && DistanceBetweenPoints(_touchPointInViewStart, touchPointInView) > kClosestTapLimit ) {
        [self reset];
    }
   
    if (self.startPoint && point && point != self.startPoint) {
        DHLineSegment* line = [[DHLineSegment alloc] init];
        line.start = self.startPoint;
        line.end = point;
        
        [objectsToAdd addObject:line];
        
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
        [self.delegate toolTipDidChange:@"Tap on a second point to mark the end the line segment"];
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
    if (_temporaryLine) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryLine]];
        _temporaryLine = nil;
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
    if (_temporaryLine) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryLine]];
        _temporaryLine = nil;
    }
    if (_temporaryInitialStartingPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        _temporaryInitialStartingPoint = nil;
    }
    self.startPoint.highlighted = NO;
}
@end

@implementation DHLineTool {
    CGPoint _touchPointInViewStart;
    DHPoint* _temporaryInitialStartingPoint;
    DHLine* _temporaryLine;
}
- (NSString*)initialToolTip
{
    return @"Tap on a point to mark the first of two points needed to define a line";
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
        self.startPoint = point;
        point.highlighted = true;
        [self.delegate toolTipDidChange:@"Drag to a second point that the line will pass through"];
        
        if (_temporaryInitialStartingPoint) {
            [self.delegate addTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        }
        [touch.view setNeedsDisplay];
    } else if (self.startPoint) {
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryLine = [[DHLine alloc] initWithStart:self.startPoint andEnd:endPoint];
        if (point && point != self.startPoint) {
            _temporaryLine.end.position = point.position;
            [self.delegate toolTipDidChange:@"Release to create line"];
        } else {
            _temporaryLine.end.position = touchPoint;
            _temporaryLine.temporary = YES;
            [self.delegate toolTipDidChange:@"Drag to a second point that the line will pass through"];
        }
        [self.delegate addTemporaryGeometricObjects:@[_temporaryLine]];
        [touch.view setNeedsDisplay];
    }
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    if (!_temporaryLine && self.startPoint) {
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryLine = [[DHLine alloc] initWithStart:self.startPoint andEnd:endPoint];
        [self.delegate addTemporaryGeometricObjects:@[_temporaryLine]];
        [touch.view setNeedsDisplay];
    }
    
    if (_temporaryLine) {
        CGPoint endPoint = touchPoint;
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects, geoViewScale);
        }
        
        //if still no point, see if there is a point close to the line and snap to it
        if (!point) {
            _temporaryLine.end.position = touchPoint;
            point = FindPointClosestToLine(_temporaryLine, self.startPoint, self.delegate.geometryObjects, 8/geoViewScale);
        }
        
        if (point && point != self.startPoint) {
            endPoint = point.position;
            [self.delegate toolTipDidChange:@"Release to create line"];
            _temporaryLine.temporary = NO;
        } else {
            [self.delegate toolTipDidChange:@"Drag to a second point that the line will pass through"];
            _temporaryLine.temporary = YES;
        }
        _temporaryLine.end.position = endPoint;
        [touch.view setNeedsDisplay];
    }
}
- (void)touchEnded:(UITouch*)touch
{
    // Do nothing if no start point
    if (!self.startPoint) {
        return;
    }
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:3];
    
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    if (_temporaryLine) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryLine]];
        _temporaryLine = nil;
        [self.delegate toolTipDidChange:@"Tap on a second point that the line will pass through"];
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
    //if still no point, see if there is a point close to the line and snap to it
    if (!point) {
        DHLine* tempLine = [[DHLine alloc]initWithStart:self.startPoint andEnd:[[DHPoint alloc]initWithPositionX:touchPoint.x andY:touchPoint.y]];
        point = FindPointClosestToLine(tempLine, self.startPoint, self.delegate.geometryObjects, 8/geoViewScale);
    }
    
    if(!point && DistanceBetweenPoints(_touchPointInViewStart, touchPointInView) > kClosestTapLimit) {
        [self reset];
    }
    
    if (self.startPoint && point && point != self.startPoint) {
        DHLine* line = [[DHLine alloc] init];
        line.start = self.startPoint;
        line.end = point;
        
        [objectsToAdd addObject:line];
        
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
        [self.delegate toolTipDidChange:@"Tap on a second point that the line will pass through"];
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
    if (_temporaryLine) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryLine]];
        _temporaryLine = nil;
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
    if (_temporaryLine) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryLine]];
        _temporaryLine = nil;
    }
    if (_temporaryInitialStartingPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        _temporaryInitialStartingPoint = nil;
    }
    self.startPoint.highlighted = NO;
}
@end


@implementation DHCircleTool {
    CGPoint _touchPointInViewStart;
    DHPoint* _temporaryCenter;
    DHCircle* _temporaryCircle;
}
- (NSString*)initialToolTip
{
    return @"Tap on any point to mark the center of a new circle";
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
            if (!self.center) _temporaryCenter = intersectionPoint;
            point = intersectionPoint;
        }
    }
    
    if (!self.center && point) {
        self.center = point;
        point.highlighted = true;
        [self.delegate toolTipDidChange:@"Drag to a point that the circle will pass through"];
        
        if (_temporaryCenter) {
            [self.delegate addTemporaryGeometricObjects:@[_temporaryCenter]];
        }
        [touch.view setNeedsDisplay];
    } else if (self.center) {
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryCircle = [[DHCircle alloc] initWithCenter:self.center andPointOnRadius:endPoint];
        if (point && point != self.center) {
            _temporaryCircle.pointOnRadius.position = point.position;
            [self.delegate toolTipDidChange:@"Release to create circle"];
        } else {
            _temporaryCircle.pointOnRadius.position = touchPoint;
            _temporaryCircle.temporary = YES;
            [self.delegate toolTipDidChange:@"Drag to a point that the circle will pass through"];
        }
        [self.delegate addTemporaryGeometricObjects:@[_temporaryCircle]];
        [touch.view setNeedsDisplay];
    }
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    if (!_temporaryCircle && self.center) {
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryCircle = [[DHCircle alloc] initWithCenter:self.center andPointOnRadius:endPoint];
        [self.delegate addTemporaryGeometricObjects:@[_temporaryCircle]];
        [touch.view setNeedsDisplay];
    }
    
    if (_temporaryCircle) {
        CGPoint endPoint = touchPoint;
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects, geoViewScale);
        }
        if (!point) {
            _temporaryCircle.pointOnRadius.position = endPoint;
            point = FindPointClosestToCircle(_temporaryCircle, self.delegate.geometryObjects, 8/geoViewScale);
        }
        
        if (point && point != self.center) {
            endPoint = point.position;
            [self.delegate toolTipDidChange:@"Release to create circle"];
            _temporaryCircle.temporary = NO;
        } else {
            [self.delegate toolTipDidChange:@"Drag to a point that the circle will pass through"];
            _temporaryCircle.temporary = YES;
        }
        _temporaryCircle.pointOnRadius.position = endPoint;
        [touch.view setNeedsDisplay];
    }
}
- (void)touchEnded:(UITouch*)touch
{
    // Do nothing if no start point
    if (!self.center) {
        return;
    }
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:3];
    
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    if (_temporaryCircle) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCircle]];
        _temporaryCircle = nil;
        [self.delegate toolTipDidChange:@"Tap on a second point that the circle will pass through"];
        [touch.view setNeedsDisplay];
    }
    if (_temporaryCenter) {
        [objectsToAdd addObject:_temporaryCenter];
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCenter]];
        _temporaryCenter = nil;
        [touch.view setNeedsDisplay];
    }
    
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
    // Prefer normal point selection above automatic intersection
    if (!point) {
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        if (intersectionPoint && !CGPointEqualToPoint(intersectionPoint.position, self.center.position)) {
            point = intersectionPoint;
            [objectsToAdd addObject:intersectionPoint];
        }
    }
    // If still no point, see if there is a point close to the circle and snap to it
    if (!point) {
        DHCircle* tempCircle = [[DHCircle alloc] init];
        tempCircle.center = self.center;
        tempCircle.pointOnRadius = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        point = FindPointClosestToCircle(tempCircle, self.delegate.geometryObjects, 8/geoViewScale);
    }
    
    if(!point && DistanceBetweenPoints(_touchPointInViewStart, touchPointInView) > kClosestTapLimit) {
        [self reset];
    }
    
    if (self.center && point && point != self.center) {
        DHCircle* circle = [[DHCircle alloc] init];
        circle.center = self.center;
        circle.pointOnRadius = point;
        
        [objectsToAdd addObject:circle];
        
        self.center.highlighted = false;
        self.center = nil;
        
        [self.delegate addGeometricObjects:objectsToAdd];
        [objectsToAdd removeAllObjects];
        [self.delegate toolTipDidChange:self.initialToolTip];
    }
    if (objectsToAdd.count > 0) {
        [self.delegate addGeometricObjects:objectsToAdd];
    }
    if (self.center) {
        [self.delegate toolTipDidChange:@"Tap on a second point that the circle will pass through"];
    }
    [touch.view setNeedsDisplay];
}
- (BOOL)active
{
    if (self.center) {
        return YES;
    }
    
    return NO;
}
- (void)reset
{
    if (_temporaryCenter) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCenter]];
        _temporaryCenter = nil;
    }
    if (_temporaryCircle) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCircle]];
        _temporaryCircle = nil;
    }
    
    self.center.highlighted = NO;
    self.center = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)dealloc
{
    if (_temporaryCenter) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCenter]];
        _temporaryCenter = nil;
    }
    if (_temporaryCircle) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCircle]];
        _temporaryCircle = nil;
    }

    self.center.highlighted = NO;
    [self.delegate toolTipDidChange:self.initialToolTip];
}
@end


@implementation DHIntersectTool
- (NSString*)initialToolTip
{
    return @"Tap on any intersection between two lines/circles to add a new point";
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
    DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
    if (intersectionPoint) {
        [self.delegate addGeometricObject:intersectionPoint];
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

@end


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
        DHLineSegment* segment = FindLineSegmentClosestToPoint(touchPoint, self.delegate.geometryObjects,
                                                            kClosestTapLimit / geoViewScale);
        if (segment) {
            _temporarySegment = segment;
            segment.highlighted = YES;
            _temporaryMidPoint = [[DHMidPoint alloc] initWithPoint1:segment.start andPoint2:segment.end];
            [self.delegate addTemporaryGeometricObjects:@[_temporaryMidPoint]];
            [self.delegate toolTipDidChange:_temporaryTooltipFinished];
            [touch.view setNeedsDisplay];
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
    if (self.startPoint) {
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
    _temporarySegment = nil;
    
    if (_temporaryMidPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryMidPoint]];
        _temporaryMidPoint = nil;
    }
    if (_temporaryInitialStartingPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        _temporaryInitialStartingPoint = nil;
    }
    if (self.startPoint) {
        self.startPoint.highlighted = false;
    }
}
@end


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


@implementation DHBisectTool
- (NSString*)initialToolTip
{
    return @"Tap two lines, rays or line segments (or three points) that define an angle to create its bisector";
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
    NSArray* objects = self.delegate.geometryObjects;
    
    // If no first point has been tapped, look for closest line or point
    if (self.firstPoint == nil) {
        DHLineObject* line = FindLineClosestToPoint(touchPoint, objects, kClosestTapLimit / geoViewScale);
        DHPoint* point = FindPointClosestToPoint(touchPoint, objects, kClosestTapLimit / geoViewScale);
        
        if (point && self.firstLine == nil) {
            self.firstPoint = point;
            point.highlighted = true;
            [self.delegate toolTipDidChange:@"Tap on a second point to mark the corner of the angle"];
            [touch.view setNeedsDisplay];
        } else if (line) {
            if (self.firstLine && line != self.firstLine) {
                // Ensure the lines intersect
                DHIntersectionResult r = IntersectionTestLineLine(self.firstLine, line);
                if (r.intersect == NO) {
                    [self.delegate showTemporaryMessage:@"The lines must intersect or be connected to define an angle"
                                                atPoint:touchPointInView withColor:[UIColor redColor]];
                    return;
                }
                
                // Ensure the lines define an angle
                CGFloat angle = CGVectorAngleBetween(self.firstLine.vector, line.vector);
                if (angle < 0.0001 || fabs(angle - M_PI) < 0.001) {
                    [self.delegate showTemporaryMessage:@"The lines can not be parallel to define an angle"
                                                atPoint:touchPointInView withColor:[UIColor redColor]];
                    return;
                }
                
                DHBisectLine* bl = [[DHBisectLine alloc] init];
                bl.line1 = self.firstLine;
                bl.line2 = line;
                
                DHPerpendicularLine* perpLine = [[DHPerpendicularLine alloc] init];
                perpLine.line = bl;
                perpLine.point = bl.start;
                [self.delegate addGeometricObjects:@[bl, perpLine]];
                
                self.firstLine.highlighted = false;
                self.firstLine = nil;
                [self.delegate toolTipDidChange:self.initialToolTip];
            } else if (self.firstLine == nil) {
                self.firstLine = line;
                line.highlighted = true;
                [self.delegate toolTipDidChange:@"Tap on a second line intersecting/connect to the first to create the bisector"];
                [touch.view setNeedsDisplay];
            }
        }
    } else {
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (point) {
            if (point == self.firstPoint || point == self.secondPoint) {
                return;
            }
            if (self.secondPoint == nil) {
                self.secondPoint = point;
                point.highlighted = true;
                [self.delegate toolTipDidChange:@"Tap on a third point to define the angle and create the bisector"];
                [touch.view setNeedsDisplay];
            } else {
                // Ensure the lines define an angle
                CGVector v1 = CGVectorBetweenPoints(self.secondPoint.position, self.firstPoint.position);
                CGVector v2 = CGVectorBetweenPoints(self.secondPoint.position, point.position);
                CGFloat angle = CGVectorAngleBetween(v1, v2);
                if (angle < 0.0001 || fabs(angle - M_PI) < 0.001) {
                    [self.delegate showTemporaryMessage:@"The points can not all lie on a line to define an angle"
                                                atPoint:touchPointInView withColor:[UIColor redColor]];
                    return;
                }
                
                DHBisectLine* bl = [[DHBisectLine alloc] init];
                bl.line1 = [[DHLineSegment alloc] initWithStart:self.secondPoint andEnd:self.firstPoint];
                bl.line2 = [[DHLineSegment alloc] initWithStart:self.secondPoint andEnd:point];
                DHPerpendicularLine* perpLine = [[DHPerpendicularLine alloc] init];
                perpLine.line = bl;
                perpLine.point = bl.start;
                
                [self.delegate addGeometricObjects:@[bl, perpLine]];
                
                self.firstPoint.highlighted = false;
                self.firstPoint = nil;
                self.secondPoint.highlighted = false;
                self.secondPoint = nil;
                [self.delegate toolTipDidChange:self.initialToolTip];
            }
        }
    }
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
    self.firstLine.highlighted = NO;
    self.firstPoint.highlighted = NO;
    self.secondPoint.highlighted = NO;
    self.firstLine = nil;
    self.firstPoint = nil;
    self.secondPoint = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)dealloc
{
    self.firstLine.highlighted = NO;
    self.firstPoint.highlighted = NO;
    self.secondPoint.highlighted = NO;
}
@end


@implementation DHPerpendicularTool
- (NSString*)initialToolTip
{
    return @"Tap a line you wish to make a line perpendicular to";
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

    if (self.line == nil) {
        DHLineObject* line = FindLineClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (line) {
            self.line = line;
            line.highlighted = true;
            [self.delegate toolTipDidChange:@"Tap on a point through which the perpendicular line should pass"];
            [touch.view setNeedsDisplay];
        }
    } else {
        
        DHPoint* point= FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        //prefers normal point selection above automatic intersection
        if (intersectionPoint && !(point)) {
            [self.delegate addGeometricObject:intersectionPoint];
            point = intersectionPoint;
        }
        
        
        if (point) {
            DHPerpendicularLine* perpLine = [[DHPerpendicularLine alloc] init];
            perpLine.line = self.line;
            perpLine.point = point;
            [self.delegate addGeometricObject:perpLine];
            
            self.line.highlighted = false;
            self.line = nil;
            [self.delegate toolTipDidChange:self.initialToolTip];
        }
    }
}
- (BOOL)active
{
    if (self.line) {
        return YES;
    }
    
    return NO;
}
- (void)reset
{
    self.line.highlighted = NO;
    self.line = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)dealloc
{
    if (self.line) {
        self.line.highlighted = NO;
    }
}
@end


@implementation DHParallelTool
- (NSString*)initialToolTip
{
    return @"Tap a line you wish to make a line parallel to";
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

    if (self.line == nil) {
        DHLineObject* line = FindLineClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (line) {
            self.line = line;
            line.highlighted = true;
            [self.delegate toolTipDidChange:@"Tap on a point through which the parallel line should pass"];
            [touch.view setNeedsDisplay];
        }
    } else {
        
        DHPoint* point= FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        //prefers normal point selection above automatic intersection
        if (intersectionPoint && !(point)) {
            [self.delegate addGeometricObject:intersectionPoint];
            point = intersectionPoint;
        }
        
        
        if (point) {
            DHParallelLine* paraLine = [[DHParallelLine alloc] init];
            paraLine.line = self.line;
            paraLine.point = point;
            [self.delegate addGeometricObject:paraLine];
            
            self.line.highlighted = false;
            self.line = nil;
            [self.delegate toolTipDidChange:self.initialToolTip];
        }
    }
}
- (BOOL)active
{
    if (self.line) {
        return YES;
    }
    
    return NO;
}
- (void)reset
{
    self.line.highlighted = NO;
    self.line = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)dealloc
{
    if (self.line) {
        self.line.highlighted = false;
    }
}
@end


@implementation DHTranslateSegmentTool
- (NSString*)initialToolTip
{
    return @"Tap two points or a line segment you wish to translate";
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
    const CGFloat tapLimitInGeo = kClosestTapLimit / geoViewScale;

    if (self.start == nil || self.end == nil) {
        DHPoint* point= FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, tapLimitInGeo);
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        // Prefers normal point selection above automatic intersection
        if (intersectionPoint && !(point)) {
            [self.delegate addGeometricObject:intersectionPoint];
            point = intersectionPoint;
        }
        if (point && self.start == nil) {
            self.start = point;
            self.start.highlighted = YES;
            [self.delegate toolTipDidChange:@"Tap on a second point to define the line segment to be translated"];
            [touch.view setNeedsDisplay];
            return;
        }
        if (point && self.end == nil) {
            self.end = point;
            self.end.highlighted = YES;
            [self.delegate toolTipDidChange:@"Tap on a point to define the starting point of the translated segment"];
            [touch.view setNeedsDisplay];
            return;
        }
        
        DHLineSegment* line = FindLineSegmentClosestToPoint(touchPoint, self.delegate.geometryObjects, tapLimitInGeo);
        if (line) {
            self.segment = line;
            self.start = line.start;
            self.end = line.end;
            self.segment.highlighted = YES;
            [self.delegate toolTipDidChange:@"Tap on a point that should be the starting point of the translated segment"];
            [touch.view setNeedsDisplay];
            return;
        }
    } else {
        DHPoint* point= FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, tapLimitInGeo);
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        // Prefers normal point selection above automatic intersection
        if (intersectionPoint && !(point)) {
            [self.delegate addGeometricObject:intersectionPoint];
            point = intersectionPoint;
        }
        
        if (point == nil) {
            return;
        }
        
        if (self.disableWhenOnSameLine) {
            // Check if point is on line and then do nothing
            CGVector vLineDir = CGVectorBetweenPoints(self.start.position, self.end.position);
            CGVector vLineStartToPoint = CGVectorBetweenPoints(self.start.position, point.position);
            CGFloat angle = CGVectorAngleBetween(vLineDir, vLineStartToPoint);
            if (fabs(angle) < 0.001 || fabs(angle - M_PI) < 0.001) {
                [self.delegate showTemporaryMessage:@"Not allowed, point lies on same line as segment"
                                            atPoint:touchPointInView withColor:[UIColor redColor]];
                return;
            }
        }
        
        DHTranslatedPoint* translatedPoint = [[DHTranslatedPoint alloc] init];
        translatedPoint.startOfTranslation = point;
        translatedPoint.translationStart = self.start;
        translatedPoint.translationEnd = self.end;
        
        DHLineSegment* transLine = [[DHLineSegment alloc] initWithStart:point andEnd:translatedPoint];
        [self.delegate addGeometricObjects:@[translatedPoint, transLine]];
        
        self.segment.highlighted = NO;
        self.start.highlighted = NO;
        self.end.highlighted = NO;
        self.start = nil;
        self.end = nil;
        self.segment = nil;
        [self.delegate toolTipDidChange:self.initialToolTip];
    }
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
    self.segment.highlighted = NO;
    self.start.highlighted = NO;
    self.end.highlighted = NO;
    self.segment = nil;
    self.start = nil;
    self.end = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)dealloc
{
    self.segment.highlighted = NO;
    self.start.highlighted = NO;
    self.end.highlighted = NO;
}
@end


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

    DHPoint* point= FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
    DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
    //prefers normal point selection above automatic intersection
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
                
                DHCircle* circle = [[DHCircle alloc] init];
                circle.center = point;
                circle.pointOnRadius = pointOnRadius;
                
                self.firstPoint.highlighted = false;
                self.firstPoint = nil;
                self.secondPoint.highlighted = false;
                self.secondPoint = nil;
                self.radiusSegment.highlighted = false;
                self.radiusSegment = nil;
                
                [self.delegate addGeometricObject:circle];
                [self.delegate toolTipDidChange:self.initialToolTip];
            } else if (point != self.firstPoint) {
                self.secondPoint = point;
                point.highlighted = true;
                [self.delegate toolTipDidChange:@"Tap on a third point to mark the center of the circle"];
                [touch.view setNeedsDisplay];
            }
        } else {
            self.firstPoint = point;
            point.highlighted = true;
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
            segment.highlighted = true;
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
    
    return false;
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
    if (self.firstPoint) {
        self.firstPoint.highlighted = false;
    }
    if (self.secondPoint) {
        self.secondPoint.highlighted = false;
    }
    if (self.radiusSegment) {
        self.radiusSegment.highlighted = false;
    }
}
@end
