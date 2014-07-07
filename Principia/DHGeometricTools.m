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

static const CGFloat kClosestTapLimit = 25.0f;

DHPoint* FindPointClosestToPoint(CGPoint point, NSArray* geometricObjects)
{
    DHPoint* closestPoint = nil;
    CGFloat closestPointDistance = kClosestTapLimit;
    
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

DHLineObject* FindLineClosestToPoint(CGPoint point, NSArray* geometricObjects)
{
    DHLineObject* closestLine = nil;
    CGFloat closestLineDistance = kClosestTapLimit;
    
    DHPoint *dhPoint = [[DHPoint alloc] init];
    dhPoint.position = point;
    
    for (id object in geometricObjects) {
        if ([[object class] isSubclassOfClass:[DHLineObject class]]) {
            DHLineObject* currentLine = object;
            CGFloat distance = DistanceFromPointToLine(dhPoint, currentLine);
            
            if (distance < closestLineDistance) {
                closestLine = object;
                closestLineDistance = distance;
            }
        }
    }
    
    return closestLine;
}


DHLineSegment* FindLineSegmentClosestToPoint(CGPoint point, NSArray* geometricObjects)
{
    DHLineSegment* closestLine = nil;
    CGFloat closestLineDistance = kClosestTapLimit;
    
    DHPoint *dhPoint = [[DHPoint alloc] init];
    dhPoint.position = point;
    
    for (id object in geometricObjects) {
        if ([object class] == [DHLineSegment class]) {
            DHLineSegment* currentLine = object;
            CGFloat distance = DistanceFromPointToLine(dhPoint, currentLine);
            
            if (distance < closestLineDistance) {
                closestLine = object;
                closestLineDistance = distance;
            }
        }
    }
    
    return closestLine;
}



NSArray* FindIntersectablesNearPoint(CGPoint point, NSArray* geometricObjects)
{
    const CGFloat maxDistanceLimit = kClosestTapLimit;
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
        if ([[object class] isSubclassOfClass:[DHLineObject class]]) {
            DHLineObject* line = (DHLineObject*)object;
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
    return @"Tap anywhere to create a new point, or hold down on an existing point to move it";
}
- (void)touchBegan:(UITouch*)touch
{
    if (self.point) {
        return;
    }
    
    CGPoint touchPoint = [touch locationInView:touch.view];
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects);
    if (point && [point class] == [DHPoint class]) {
        self.point = point;
        self.point.highlighted = YES;
        self.touchStart = touchPoint;
        [self.delegate toolTipDidChange:@"Move the point to the desired location and release"];
        [touch.view setNeedsDisplay];
    }
    
}
- (void)touchMoved:(UITouch*)touch
{
    if (self.point) {
        CGPoint touchPoint = [touch locationInView:touch.view];
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
    if (self.point) {
        self.point.highlighted = NO;
        self.point = nil;
        [self.delegate toolTipDidChange:self.initialToolTip];
        [touch.view setNeedsDisplay];
    } else {
        CGPoint touchPoint = [touch locationInView:touch.view];
        DHPoint* point = [[DHPoint alloc] init];
        point.position = touchPoint;
        [self.delegate addGeometricObject:point];
    }
}
- (void)dealloc
{
    if (self.point) {
        self.point.highlighted = NO;
    }
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
            DHLineSegment* line = [[DHLineSegment alloc] init];
            line.start = self.startPoint;
            line.end = point;
            
            self.startPoint.highlighted = false;
            self.startPoint = nil;
            
            [self.delegate addGeometricObject:line];
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
            
            [self.delegate addGeometricObject:circle];
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
            if ([[object1 class] isSubclassOfClass:[DHLineObject class]] &&
                [[object2 class] isSubclassOfClass:[DHLineObject class]]) {
                DHLineObject* l1 = object1;
                DHLineObject* l2 = object2;
                
                DHIntersectionResult r = IntersectionTestLineLine(l1, l2);
                if (r.intersect) {
                    DHIntersectionPointLineLine* iPoint = [[DHIntersectionPointLineLine alloc] init];
                    iPoint.l1 = l1;
                    iPoint.l2 = l2;
                    [intersectionPoints addObject:iPoint];
                }
            }
            
            // Line/circle intersection
            if ([[object1 class] isSubclassOfClass:[DHLineObject class]] &&
                [[object2 class] isSubclassOfClass:[DHCircle class]]) {
                DHLineObject* l = object1;
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
                [[object2 class] isSubclassOfClass:[DHLineObject class]]) {
                DHCircle* c = object1;
                DHLineObject* l = object2;
                
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
        [self.delegate addGeometricObject:closestPoint];
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
            
            [self.delegate addGeometricObject:midPoint];
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
            line.end = point;
            
            self.startPoint.highlighted = false;
            self.startPoint = nil;
            
            [self.delegate addGeometricObject:line];
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


@implementation DHTriangleTool
- (NSString*)initialToolTip
{
    return @"Tap a point that will form one of the corners in the triangle (counter-clockwise order)";
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
            DHTrianglePoint* triPoint = [[DHTrianglePoint alloc] init];
            triPoint.start = self.startPoint;
            triPoint.end = point;
            
            DHLineSegment* l1 = [[DHLineSegment alloc] init];
            l1.start = self.startPoint;
            l1.end = triPoint;
            
            DHLineSegment* l2 = [[DHLineSegment alloc] init];
            l2.start = point;
            l2.end = triPoint;
            
            self.startPoint.highlighted = false;
            self.startPoint = nil;
            
            [self.delegate addGeometricObject:triPoint];
            [self.delegate addGeometricObject:l1];
            [self.delegate addGeometricObject:l2];
            [self.delegate toolTipDidChange:self.initialToolTip];
        } else {
            self.startPoint = point;
            point.highlighted = true;
            [self.delegate toolTipDidChange:@"Tap on a second point, which will create the third"];
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


@implementation DHBisectTool
- (NSString*)initialToolTip
{
    return @"Tap two lines, rays or line segments";
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
    DHLineObject* line = FindLineClosestToPoint(touchPoint, self.delegate.geometryObjects);
    if (line) {
        if (self.firstLine && line != self.firstLine) {
            DHBisectLine* bl = [[DHBisectLine alloc] init];
            bl.line1 = self.firstLine;
            bl.line2 = line;
            
            [self.delegate addGeometricObject:bl];
            
            self.firstLine.highlighted = false;
            self.firstLine = nil;
            [self.delegate toolTipDidChange:self.initialToolTip];
        } else {
            self.firstLine = line;
            line.highlighted = true;
            [self.delegate toolTipDidChange:@"Tap on a second line to create a line bisect the angle between it and the first"];
            [touch.view setNeedsDisplay];
        }
    }
}
- (void)dealloc
{
    if (self.firstLine) {
        self.firstLine.highlighted = false;
    }
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
    CGPoint touchPoint = [touch locationInView:touch.view];
    
    if (self.line == nil) {
        DHLineObject* line = FindLineClosestToPoint(touchPoint, self.delegate.geometryObjects);
        if (line) {
            self.line = line;
            line.highlighted = true;
            [self.delegate toolTipDidChange:@"Tap on a point through which the perpendicular line should pass"];
            [touch.view setNeedsDisplay];
        }
    } else {
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects);
        
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
- (void)dealloc
{
    if (self.line) {
        self.line.highlighted = false;
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
    CGPoint touchPoint = [touch locationInView:touch.view];
    
    if (self.line == nil) {
        DHLineObject* line = FindLineClosestToPoint(touchPoint, self.delegate.geometryObjects);
        if (line) {
            self.line = line;
            line.highlighted = true;
            [self.delegate toolTipDidChange:@"Tap on a point through which the parallel line should pass"];
            [touch.view setNeedsDisplay];
        }
    } else {
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects);
        
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
    return @"Tap a line segment you wish to translate";
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
    
    if (self.segment == nil) {
        DHLineSegment* line = FindLineSegmentClosestToPoint(touchPoint, self.delegate.geometryObjects);
        if (line) {
            self.segment = line;
            self.segment.highlighted = YES;
            [self.delegate toolTipDidChange:@"Tap on a point that should be the starting point of the translated segment"];
            [touch.view setNeedsDisplay];
        }
    } else {
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects);
        
        if (point) {
            DHTranslatedLine* transLine = [[DHTranslatedLine alloc] init];
            transLine.line = self.segment;
            transLine.point = point;
            [self.delegate addGeometricObject:transLine];
            
            DHPointOnLine* p = [[DHPointOnLine alloc] init];
            p.line = transLine;
            p.tValue = 1;
            [self.delegate addGeometricObject:p];
            
            self.segment.highlighted = NO;
            self.segment = nil;
            [self.delegate toolTipDidChange:self.initialToolTip];
        }
    }
}
- (void)dealloc
{
    if (self.segment) {
        self.segment.highlighted = NO;
    }
}
@end


@implementation DHCompassTool
- (NSString*)initialToolTip
{
    return @"Tap two points to define the radius followed by a third point to be the center of the circle";
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
        if (self.firstPoint && point != self.firstPoint) {
            if (self.secondPoint && point != self.secondPoint) {
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
                
                [self.delegate addGeometricObject:circle];
                [self.delegate toolTipDidChange:self.initialToolTip];
            } else {
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
    }
}
- (void)dealloc
{
    if (self.firstPoint) {
        self.firstPoint.highlighted = false;
    }
    if (self.secondPoint) {
        self.secondPoint.highlighted = false;
    }
}
@end
