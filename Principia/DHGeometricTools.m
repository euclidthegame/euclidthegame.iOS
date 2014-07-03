//
//  DHGeometricTools.m
//  Principia
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHGeometricObjects.h"
#import "DHMath.h"

DHPoint* FindPointClosestToPoint(CGPoint point, NSArray* geometricObjects)
{
    DHPoint* closestPoint = nil;
    CGFloat closestPointDistance = 30.0f;
    
    for (id object in geometricObjects) {
        if ([[object class] isSubclassOfClass:[DHPoint class]]) {
            CGPoint currentPoint = [object position];
            CGFloat distance = DistanceBetweenPoints(point, currentPoint);
            
            if (distance < closestPointDistance) {
                closestPoint = object;
                closestPointDistance = distance;
            }
        }
    }
    
    return closestPoint;
}

NSArray* FindIntersectablesNearPoint(CGPoint point, NSArray* geometricObjects)
{
    const CGFloat maxDistanceLimit = 30.0f;
    NSMutableArray* foundObjects = [[NSMutableArray alloc] init];
    DHPoint *dhPoint = [[DHPoint alloc] init];
    dhPoint.position = point;
    
    for (id object in geometricObjects) {
        if ([object class] == [DHCircle class]) {
            DHCircle* circle = (DHCircle*)object;
            CGFloat distanceToCenter = DistanceBetweenPoints(point, circle.center.position);
            CGFloat distanceToCircle = distanceToCenter - circle.radius;
            if (distanceToCircle <= maxDistanceLimit) {
                [foundObjects addObject:circle];
            }
        }
        if ([object class] == [DHLine class]) {
            DHLine* line = (DHLine*)object;
            CGFloat distanceToLine = DistanceFromPointToLine(dhPoint, line);
            if (distanceToLine <= maxDistanceLimit) {
                [foundObjects addObject:line];
            }
        }
    }
    
    return foundObjects;
}

@implementation DHPointTool
- (NSString*)initialToolTip
{
    return @"Tap anywhere to create a new point";
}
- (void)touchBegan:(UITouch*)touch
{
    
}
- (void)touchMoved:(UITouch*)touch
{
    
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPoint = [touch locationInView:touch.view];
    DHPoint* point = [[DHPoint alloc] init];
    point.position = touchPoint;
    [self.delegate addNewGeometricObject:point];
}
@end


@implementation DHLineTool
- (NSString*)initialToolTip
{
    return @"Tap on a point to mark the start of a new line";
}
- (void)touchBegan:(UITouch*)touch
{
    
}
- (void)touchMoved:(UITouch*)touch
{
    
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPoint = [touch locationInView:touch.view];
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects);
    if (point) {
        if (self.startPoint && point != self.startPoint) {
            DHLine* line = [[DHLine alloc] init];
            line.start = self.startPoint;
            line.end = point;
            
            self.startPoint.highlighted = false;
            self.startPoint = nil;
            
            [self.delegate addNewGeometricObject:line];
            [self.delegate toolTipDidChange:self.initialToolTip];
        } else {
            self.startPoint = point;
            point.highlighted = true;
            [self.delegate toolTipDidChange:@"Tap on a second point to mark the end the line"];
            [touch.view setNeedsDisplay];
        }
    }
}
- (void)dealloc
{
    if (self.startPoint) {
        self.startPoint.highlighted = false;
    }
}
@end


@implementation DHCircleTool
- (NSString*)initialToolTip
{
    return @"Tap on any point to mark the center of a new circle";
}
- (void)touchBegan:(UITouch*)touch
{
    
}
- (void)touchMoved:(UITouch*)touch
{
    
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPoint = [touch locationInView:touch.view];
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects);
    if (point) {
        if (self.center && point != self.center) {
            DHCircle* circle = [[DHCircle alloc] init];
            circle.center = self.center;
            circle.pointOnRadius = point;
            
            self.center.highlighted = false;
            self.center = nil;
            
            [self.delegate addNewGeometricObject:circle];
            [self.delegate toolTipDidChange:self.initialToolTip];
        } else {
            self.center = point;
            point.highlighted = true;
            [self.delegate toolTipDidChange:@"Tap on a second point to mark the radius of the circle"];
            [touch.view setNeedsDisplay];
        }
    }
}
- (void)dealloc
{
    if (self.center) {
        self.center.highlighted = false;
    }
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
    CGPoint touchPoint = [touch locationInView:touch.view];    
    NSArray* nearObjects = FindIntersectablesNearPoint(touchPoint, self.delegate.geometryObjects);
    
    NSMutableArray* intersectionPoints = [[NSMutableArray alloc] init];
    
    if (nearObjects.count < 2) {
        return;
    }
    
    for (int index1 = 0; index1 < nearObjects.count-1; ++index1) {
        for (int index2 = index1+1; index2 < nearObjects.count; ++index2) {
            id object1 = [nearObjects objectAtIndex:index1];
            id object2 = [nearObjects objectAtIndex:index2];
            
            // Circle/circle intersection
            if ([[object1 class] isSubclassOfClass:[DHCircle class]] &&
                [[object2 class] isSubclassOfClass:[DHCircle class]]) {
                DHCircle* c1 = object1;
                DHCircle* c2 = object2;
                
                if (DoCirclesIntersect(c1, c2)) {
                    { // First variant
                        DHIntersectionPointCircleCircle* iPoint = [[DHIntersectionPointCircleCircle alloc] init];
                        iPoint.c1 = c1;
                        iPoint.c2 = c2;
                        iPoint.onPositiveY = false;
                        [intersectionPoints addObject:iPoint];
                    }
                    { // Second variant
                        DHIntersectionPointCircleCircle* iPoint = [[DHIntersectionPointCircleCircle alloc] init];
                        iPoint.c1 = c1;
                        iPoint.c2 = c2;
                        iPoint.onPositiveY = true;
                        [intersectionPoints addObject:iPoint];
                    }
                }
            }
            
            // Line/line intersection
            if ([[object1 class] isSubclassOfClass:[DHLine class]] &&
                [[object2 class] isSubclassOfClass:[DHLine class]]) {
                DHLine* l1 = object1;
                DHLine* l2 = object2;
                
                if (DoLinesIntersect(l1, l2)) {
                    DHIntersectionPointLineLine* iPoint = [[DHIntersectionPointLineLine alloc] init];
                    iPoint.l1 = l1;
                    iPoint.l2 = l2;
                    [intersectionPoints addObject:iPoint];
                }
            }
            
            // Line/circle intersection
            if ([[object1 class] isSubclassOfClass:[DHLine class]] &&
                [[object2 class] isSubclassOfClass:[DHCircle class]]) {
                DHLine* l = object1;
                DHCircle* c = object2;
                
                DHIntersectionResult result = DoLineAndCircleIntersect(l, c, NO);
                if (result.intersect) {
                    {
                        DHIntersectionPointLineCircle* iPoint = [[DHIntersectionPointLineCircle alloc] init];
                        iPoint.l = l;
                        iPoint.c = c;
                        iPoint.preferEnd = NO;
                        [intersectionPoints addObject:iPoint];
                    }
                    {
                        DHIntersectionPointLineCircle* iPoint = [[DHIntersectionPointLineCircle alloc] init];
                        iPoint.l = l;
                        iPoint.c = c;
                        iPoint.preferEnd = YES;
                        [intersectionPoints addObject:iPoint];
                    }
                }
            }
            if ([[object1 class] isSubclassOfClass:[DHCircle class]] &&
                [[object2 class] isSubclassOfClass:[DHLine class]]) {
                DHCircle* c = object1;
                DHLine* l = object2;
                
                DHIntersectionResult result = DoLineAndCircleIntersect(l, c, NO);
                if (result.intersect) {
                    {
                        DHIntersectionPointLineCircle* iPoint = [[DHIntersectionPointLineCircle alloc] init];
                        iPoint.l = l;
                        iPoint.c = c;
                        iPoint.preferEnd = NO;
                        [intersectionPoints addObject:iPoint];
                    }
                    {
                        DHIntersectionPointLineCircle* iPoint = [[DHIntersectionPointLineCircle alloc] init];
                        iPoint.l = l;
                        iPoint.c = c;
                        iPoint.preferEnd = YES;
                        [intersectionPoints addObject:iPoint];
                    }
                }
            }
        }
    }
    
    if (intersectionPoints.count < 1) {
        return;
    }
    
    // Found closest point
    CGFloat closestDistance = CGFLOAT_MAX;
    DHPoint* closestPoint = nil;
    for (DHPoint* iPoint in intersectionPoints) {
        CGFloat distance = DistanceBetweenPoints(touchPoint, iPoint.position);
        if (distance < closestDistance) {
            closestDistance = distance;
            closestPoint = iPoint;
        }
    }
    
    if (closestPoint) {
        [self.delegate addNewGeometricObject:closestPoint];
    }
}

@end


@implementation DHMoveTool
- (NSString*)initialToolTip
{
    return @"Tap and hold on a point and then move it to a new location";
}
- (void)touchBegan:(UITouch*)touch
{
    if (self.point) {
        return;
    }
    
    CGPoint touchPoint = [touch locationInView:touch.view];
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects);
    if (point) {
        self.point = point;
        self.touchStart = touchPoint;
        [self.delegate toolTipDidChange:@"Move the point to the desired location and release"];
    }
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPoint = [touch locationInView:touch.view];
    if (self.point) {
        CGPoint previousPosition = self.point.position;
        previousPosition.x = previousPosition.x + touchPoint.x - self.touchStart.x;
        previousPosition.y = previousPosition.y + touchPoint.y - self.touchStart.y;
        self.point.position = previousPosition;
        self.touchStart = touchPoint;
        [touch.view setNeedsDisplay];
    }
    
}
- (void)touchEnded:(UITouch*)touch
{
    self.point = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
}
@end


@implementation DHMidPointTool
- (NSString*)initialToolTip
{
    return @"Tap a line or two points two create a midpoint";
}
- (void)touchBegan:(UITouch*)touch
{
    
}
- (void)touchMoved:(UITouch*)touch
{
    
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPoint = [touch locationInView:touch.view];
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects);
    if (point) {
        if (self.startPoint && point != self.startPoint) {
            DHMidPoint* midPoint = [[DHMidPoint alloc] init];
            midPoint.start = self.startPoint;
            midPoint.end = point;
            
            self.startPoint.highlighted = false;
            self.startPoint = nil;
            
            [self.delegate addNewGeometricObject:midPoint];
            [self.delegate toolTipDidChange:self.initialToolTip];
        } else {
            self.startPoint = point;
            point.highlighted = true;
            [self.delegate toolTipDidChange:@"Tap on a second point, between which to create the midpoint"];
            [touch.view setNeedsDisplay];
        }
    }
}
- (void)dealloc
{
    if (self.startPoint) {
        self.startPoint.highlighted = false;
    }
}
@end


@implementation DHRayTool
- (NSString*)initialToolTip
{
    return @"Tap on a point to mark the start of a new ray";
}
- (void)touchBegan:(UITouch*)touch
{
    
}
- (void)touchMoved:(UITouch*)touch
{
    
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPoint = [touch locationInView:touch.view];
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects);
    if (point) {
        if (self.startPoint && point != self.startPoint) {
            DHRay* line = [[DHRay alloc] init];
            line.start = self.startPoint;
            line.direction = point;
            
            self.startPoint.highlighted = false;
            self.startPoint = nil;
            
            [self.delegate addNewGeometricObject:line];
            [self.delegate toolTipDidChange:self.initialToolTip];
        } else {
            self.startPoint = point;
            point.highlighted = true;
            [self.delegate toolTipDidChange:@"Tap on a second point that the ray will pass through"];
            [touch.view setNeedsDisplay];
        }
    }
}
- (void)dealloc
{
    if (self.startPoint) {
        self.startPoint.highlighted = false;
    }
}
@end
