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

static const CGFloat kClosestTapLimit = 25.0f;

DHPoint* FindPointClosestToPoint(CGPoint point, NSArray* geometricObjects, CGFloat maxDistance)
{
    DHPoint* closestPoint = nil;
    CGFloat closestPointDistance = maxDistance;
    
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

DHLineObject* FindLineClosestToPoint(CGPoint point, NSArray* geometricObjects, CGFloat maxDistance)
{
    DHLineObject* closestLine = nil;
    CGFloat closestLineDistance = maxDistance;
    
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


DHLineSegment* FindLineSegmentClosestToPoint(CGPoint point, NSArray* geometricObjects, CGFloat maxDistance)
{
    DHLineSegment* closestLine = nil;
    CGFloat closestLineDistance = maxDistance;
    
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



NSArray* FindIntersectablesNearPoint(CGPoint point, NSArray* geometricObjects, CGFloat maxDistance)
{
    const CGFloat maxDistanceLimit = maxDistance;
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
        CGPoint touchPointInView = [touch locationInView:touch.view];
        CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
        
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
        CGPoint touchPointInView = [touch locationInView:touch.view];
        CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
        
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
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];

    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
    if (point == nil) {
        return;
    }
    // If no point was found, create a new point at location
    /*if (point == nil) {
        point = [[DHPoint alloc] init];
        point.position = touchPoint;
        [self.delegate addGeometricObject:point];
    }*/
    
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
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];

    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
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

NSMutableArray* intersectionPoints(CGPoint touchPoints, NSArray* nearObjects)
{
    NSMutableArray* intersectionPoints = [[NSMutableArray alloc] init];
    
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
                
                DHIntersectionResult result = IntersectionTestLineCircle(l, c, NO);
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
                
                DHIntersectionResult result = IntersectionTestLineCircle(l, c, NO);
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
    
    
    return intersectionPoints;
}

DHPoint* FindPointAtIntersection(CGPoint point, NSArray* geometricObjects, CGFloat geoViewScale)
{
    NSArray* nearObjects = FindIntersectablesNearPoint(point, geometricObjects, kClosestTapLimit / geoViewScale);
    if (nearObjects.count < 2) {
        return nil;
    }
    NSMutableArray* intersections = intersectionPoints(point, nearObjects);
    
    if (intersections.count < 1) {
        return nil;
    }
    
    // Found closest point
    CGFloat closestDistance = CGFLOAT_MAX;
    DHPoint* closestPoint = nil;
    for (DHPoint* iPoint in intersections) {
        CGFloat distance = DistanceBetweenPoints(point, iPoint.position);
        if (distance < closestDistance) {
            closestDistance = distance;
            closestPoint = iPoint;
        }
    }
    // check if point at intersection already exists, if so, don't create new one
    CGPoint newPoint = [closestPoint position];
    DHPoint* oldPoint = FindPointClosestToPoint(newPoint, geometricObjects, kClosestTapLimit / geoViewScale);
    CGPoint oldPointPos = [oldPoint position];
    if ((newPoint.x == oldPointPos.x) && (newPoint.y == oldPointPos.y))
    {
        return nil;
    }
    
    return closestPoint;
}

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
    DHPoint* intersectionPoint = FindPointAtIntersection(touchPoint, self.delegate.geometryObjects,geoViewScale);
    if (intersectionPoint) {
        [self.delegate addGeometricObject:intersectionPoint];
    }
}

@end


@implementation DHMidPointTool
- (NSString*)initialToolTip
{
    return @"Tap a line segment or two points two create a midpoint";
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

    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
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
    } else if (self.startPoint == nil) {
        DHLineSegment* line = FindLineSegmentClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (line) {
            DHMidPoint* midPoint = [[DHMidPoint alloc] init];
            midPoint.start = line.start;
            midPoint.end = line.end;
            
            [self.delegate addGeometricObject:midPoint];
            [self.delegate toolTipDidChange:self.initialToolTip];
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
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];

    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
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
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
   
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
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
            
            [self.delegate addGeometricObjects:@[triPoint, l1, l2]];
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
    
    // If no first point has been tapped, first try to see if the tap is close to a line
    if (self.firstPoint == nil) {
        DHLineObject* line = FindLineClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (line) {
            if (self.firstLine && line != self.firstLine) {
                DHBisectLine* bl = [[DHBisectLine alloc] init];
                bl.line1 = self.firstLine;
                bl.line2 = line;
                
                // Create an intersection point and perpendicular line to bisector located at that point
                // Note: This line should only be visible if the lines actually intersect, but this is
                // handled by the point object so that if two lines that currenly do not intersect are moved
                // it becomes visible again
                DHIntersectionPointLineLine* p = [[DHIntersectionPointLineLine alloc] init];
                p.l1 = self.firstLine;
                p.l2 = line;
                DHPerpendicularLine* perpLine = [[DHPerpendicularLine alloc] init];
                perpLine.line = bl;
                perpLine.point = p;
                [self.delegate addGeometricObjects:@[bl, perpLine]];
                
                self.firstLine.highlighted = false;
                self.firstLine = nil;
                [self.delegate toolTipDidChange:self.initialToolTip];
            } else if (self.firstLine == nil) {
                self.firstLine = line;
                line.highlighted = true;
                [self.delegate toolTipDidChange:@"Tap on a second line to create a line bisecting the angle between it and the first"];
                [touch.view setNeedsDisplay];
            }
        } else if (self.firstLine == nil) {
            DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
            if (point) {
                self.firstPoint = point;
                point.highlighted = true;
                [self.delegate toolTipDidChange:@"Tap on a second point to mark the corner of the angle"];
                [touch.view setNeedsDisplay];
            }
        }
    } else {
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (point) {
            if (self.secondPoint == nil) {
                self.secondPoint = point;
                point.highlighted = true;
                [self.delegate toolTipDidChange:@"Tap on a third point to define the angle and create the bisector"];
                [touch.view setNeedsDisplay];
            } else {
                DHBisectLine* bl = [[DHBisectLine alloc] init];
                bl.line1 = [[DHLine alloc] initWithStart:self.secondPoint andEnd:self.firstPoint];
                bl.line2 = [[DHLine alloc] initWithStart:self.secondPoint andEnd:point];
                
                [self.delegate addGeometricObjects:@[bl]];
                
                self.firstPoint.highlighted = false;
                self.firstPoint = nil;
                self.secondPoint.highlighted = false;
                self.secondPoint = nil;
                [self.delegate toolTipDidChange:self.initialToolTip];
            }
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
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        
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
        
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        
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
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];

    if (self.segment == nil) {
        DHLineSegment* line = FindLineSegmentClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (line) {
            self.segment = line;
            self.segment.highlighted = YES;
            [self.delegate toolTipDidChange:@"Tap on a point that should be the starting point of the translated segment"];
            [touch.view setNeedsDisplay];
        }
    } else {
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        
        if (point == nil) {
            return;
        }
        
        if (self.disableWhenOnSameLine) {
            // Check if point is on line and then do nothing
            CGVector vLineDir = self.segment.vector;
            CGVector vLineStartToPoint = CGVectorBetweenPoints(self.segment.start.position, point.position);
            CGFloat angle = CGVectorAngleBetween(vLineDir, vLineStartToPoint);
            if (fabs(angle) < 0.0001) {
                [self.delegate showTemporaryMessage:@"Not allowed, point lies on same line as segment"
                                            atPoint:touchPointInView];
                return;
            }
        }
        
        DHTranslatedPoint* translatedPoint = [[DHTranslatedPoint alloc] init];
        translatedPoint.startOfTranslation = point;
        translatedPoint.translationStart = self.segment.start;
        translatedPoint.translationEnd = self.segment.end;
        
        DHLineSegment* transLine = [[DHLineSegment alloc] initWithStart:point andEnd:translatedPoint];
        [self.delegate addGeometricObjects:@[translatedPoint, transLine]];
        
        self.segment.highlighted = NO;
        self.segment = nil;
        [self.delegate toolTipDidChange:self.initialToolTip];
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

    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects,
                                             kClosestTapLimit / geoViewScale);
    
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
