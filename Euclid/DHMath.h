//
//  DHMath.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#ifndef Euclid_DHMath_h
#define Euclid_DHMath_h

#import "DHGeometricObjects.h"
#import "DHMathCGVector.h"
#import "DHMathFuzzyComparisons.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"

typedef struct DHIntersectionResult {
    BOOL intersect;
    CGPoint intersectionPoint;
} DHIntersectionResult;

FOUNDATION_EXPORT const CGFloat kClosestTapLimit;

#pragma mark - Floating point comparison

#ifndef CGFLOAT_EPSILON
#if CGFLOAT_IS_DOUBLE
#define CGFLOAT_EPSILON DBL_EPSILON
#else
#define CGFLOAT_EPSILON FLT_EPSILON
#endif
#endif
static BOOL CGFloatsEqualWithinEpsilon(CGFloat a, CGFloat b)
{
    if(a == b) return YES;
    
    if (fabs(a-b) < 6 * CGFLOAT_EPSILON * fabs(a+b) || fabs(a-b) < CGFLOAT_MIN) return YES;
    
    return NO;
}

static CGFloat DistanceBetweenPoints(CGPoint a, CGPoint b);

#pragma mark - Closest position on object functions
static CGPoint ClosestPointOnLineFromPosition(CGPoint position, DHLineObject* line)
{
    CGPoint p1 = line.start.position;
    CGPoint p2 = line.end.position;
    
    CGVector aToB = CGVectorBetweenPoints(line.start.position, line.end.position);
    const CGFloat l2 = CGVectorDotProduct(aToB, aToB); // Length squared
    if (l2 == 0.0) {
        // If zero length line, return start/end
        if ([line class] == [DHLineSegment class]) {
            return line.start.position;
        }
        // Degenerate case if ray or line
        return CGPointMake(NAN, NAN);
    }
    
    // Consider the line extending the segment, parameterized as v + t (w - v).
    // We find projection of point p onto the line.
    // It falls where t = [(p-a) . (b-a)] / |w-v|^2
    CGVector vecAP = CGVectorBetweenPoints(line.start.position, position);
    const CGFloat t = CGVectorDotProduct(vecAP, aToB) / l2;
    if (t < line.tMin) return line.start.position;
    else if (t > line.tMax) return line.end.position;
    
    CGPoint closestPoint;
    
    closestPoint.x = p1.x + t * (p2.x - p1.x);  // Projection falls on the segment
    closestPoint.y = p1.y + t * (p2.y - p1.y);  // Projection falls on the segment
    
    return closestPoint;
}

#pragma mark - Distance functions
static CGFloat DistanceBetweenPoints(CGPoint a, CGPoint b)
{
    return ({CGFloat d1 = a.x - b.x, d2 = a.y - b.y; sqrt(d1 * d1 + d2 * d2); });
}

static CGFloat SquaredDistanceBetweenPoints(CGPoint a, CGPoint b)
{
    return ({CGFloat d1 = a.x - b.x, d2 = a.y - b.y; d1 * d1 + d2 * d2; });
}

static CGFloat DistanceFromPositionToCircle(CGPoint position, DHCircle* circle)
{
    CGFloat distanceToCenter = DistanceBetweenPoints(position, circle.center.position);
    CGFloat distanceToCircle = fabs(distanceToCenter - circle.radius);
    return distanceToCircle;
}

static CGFloat DistanceFromPositionToLine(CGPoint position, DHLineObject* line)
{
    //float minimum_distance(vec2 v, vec2 w, vec2 p) {
    
    CGPoint p1 = line.start.position;
    CGPoint p2 = line.end.position;
    
    CGVector aToB = CGVectorBetweenPoints(line.start.position, line.end.position);
    const CGFloat l2 = CGVectorDotProduct(aToB, aToB); // Length squared
    if (l2 == 0.0) {
        // If zero length line, return distance to start/end
        if ([line class] == [DHLineSegment class]) {
            return DistanceBetweenPoints(position, line.start.position);
        }
        // Degenerate case if ray or line
        return NAN;
    }
    
    // Consider the line extending the segment, parameterized as v + t (w - v).
    // We find projection of point p onto the line.
    // It falls where t = [(p-a) . (b-a)] / |w-v|^2
    CGVector vecAP = CGVectorBetweenPoints(line.start.position, position);
    const CGFloat t = CGVectorDotProduct(vecAP, aToB) / l2;
    if (t < line.tMin) return DistanceBetweenPoints(position, line.start.position);
    else if (t > line.tMax) return DistanceBetweenPoints(position, line.end.position);
    
    CGPoint closestPoint;
    
    closestPoint.x = p1.x + t * (p2.x - p1.x);  // Projection falls on the segment
    closestPoint.y = p1.y + t * (p2.y - p1.y);  // Projection falls on the segment
    
    return DistanceBetweenPoints(position, closestPoint);
}


static CGFloat DistanceFromPointToLine(DHPoint* point, DHLineObject* line)
{
    //float minimum_distance(vec2 v, vec2 w, vec2 p) {
    
    CGPoint p1 = line.start.position;
    CGPoint p2 = line.end.position;
    
    CGVector aToB = CGVectorBetweenPoints(line.start.position, line.end.position);
    const CGFloat l2 = CGVectorDotProduct(aToB, aToB); // Length squared
    if (l2 == 0.0) {
        // If zero length line, return distance to start/end
        if ([line class] == [DHLineSegment class]) {
            return DistanceBetweenPoints(point.position, line.start.position);
        }
        // Degenerate case if ray or line
        return NAN;
    }
    
    // Consider the line extending the segment, parameterized as v + t (w - v).
    // We find projection of point p onto the line.
    // It falls where t = [(p-a) . (b-a)] / |w-v|^2
    CGVector vecAP = CGVectorBetweenPoints(line.start.position, point.position);
    const CGFloat t = CGVectorDotProduct(vecAP, aToB) / l2;
    if (t < line.tMin) return DistanceBetweenPoints(point.position, line.start.position);
    else if (t > line.tMax) return DistanceBetweenPoints(point.position, line.end.position);
    
    CGPoint closestPoint;
    
    closestPoint.x = p1.x + t * (p2.x - p1.x);  // Projection falls on the segment
    closestPoint.y = p1.y + t * (p2.y - p1.y);  // Projection falls on the segment

    return DistanceBetweenPoints(point.position, closestPoint);
}

#pragma mark - Intersection tests
static BOOL DoCirclesIntersect(DHCircle* c1, DHCircle* c2)
{
    CGFloat distance = DistanceBetweenPoints(c1.center.position, c2.center.position);
    if (distance > c1.radius + c2.radius) {
        return false;
    }
    
    CGFloat minRadius = MIN(c1.radius, c2.radius);
    CGFloat maxRadius = MAX(c1.radius, c2.radius);
    if (distance + minRadius < maxRadius) {
        return false;
    }
    
    return true;
}

static DHIntersectionResult IntersectionTestLineLine(DHLineObject* l1, DHLineObject* l2)
{
    DHIntersectionResult result;
    result.intersectionPoint.x = NAN;
    result.intersectionPoint.y = NAN;

    // Fast out if the lines already share a point
    if (l1.start == l2.start || l1.start == l2.end) {
        result.intersect = YES;
        result.intersectionPoint = l1.start.position;
        return result;
    }
    if (l1.end == l2.start || l1.end == l2.end) {
        result.intersect = YES;
        result.intersectionPoint = l1.end.position;
        return result;
    }
    
    CGPoint pA = l1.start.position;
    CGPoint pB = l1.end.position;
    CGPoint pC = l2.start.position;
    CGPoint pD = l2.end.position;
    
    CGVector vAB = CGVectorBetweenPoints(pA, pB);
    CGVector vCD = CGVectorBetweenPoints(pC, pD);
    CGVector vAC = CGVectorBetweenPoints(pA, pC);
    CGVector n = CGVectorMakePerpendicular(CGVectorBetweenPoints(pC, pD));
    CGVector n2 = CGVectorMakePerpendicular(CGVectorBetweenPoints(pA, pB));
    
    CGFloat t = CGVectorDotProduct(n, vAC)/CGVectorDotProduct(n, vAB);
    CGFloat t2 = -CGVectorDotProduct(n2, vAC)/CGVectorDotProduct(n2, vCD); // Minus to account for vAC not vCA
    
    if ((t >= l1.tMin && t <= l1.tMax) && (t2 >= l2.tMin && t2 <= l2.tMax))  {
        result.intersect = YES;
    } else {
        result.intersect = NO;
    }
    result.intersectionPoint.x = pA.x + t * vAB.dx;
    result.intersectionPoint.y = pA.y + t * vAB.dy;
    
    return result;
}

static DHIntersectionResult IntersectionTestLineCircle(DHLineObject* line, DHCircle* circle, BOOL preferEnd)
{
    DHIntersectionResult result;
    result.intersect = NO;
    result.intersectionPoint.x = NAN;
    result.intersectionPoint.y = NAN;
    
    CGPoint p1 = line.start.position;
    CGPoint p2 = line.end.position;
    CGVector d = CGVectorNormalize(CGVectorBetweenPoints(p1, p2));
    CGFloat l = DistanceBetweenPoints(p1, p2);
    CGFloat r = circle.radius;
    
    CGVector m = CGVectorBetweenPoints(circle.center.position, p1);
    CGFloat b = CGVectorDotProduct(m, d);
    CGFloat c = CGVectorDotProduct(m, m) - r*r;
    
    //Exit if line's origin outside circle (c > 0) and line pointing away from s (b > 0) and line is ray or segment
    //if (c > 0.0 && b > 0 && line.tMin == 0) return result;
    
    CGFloat discr = b*b - c;
    
    // A negative discriminant corresponds to line missing circle
    if (discr < 0.0f) return result;
    
    // Line found to intersect circle, now compute smallest t value of intersection
    CGFloat t = -b - sqrt(discr);
    
    // Allow small epsilon two handle precision errors when rays or linesegments originate on circle
    if (fabs(t) < 0.001) {
        t = 0;
    }
    
    // Check if the t value is within the the line objects allowed values
    if (t < line.tMin || (preferEnd && -b + sqrt(discr) <= line.tMax * l)) {
        // Check if larger t value works
        t = -b + sqrt(discr);
    }

    // Allow small epsilon two handle precision errors when rays or linesegments originate on circle
    if (fabs(t - line.tMax * l) < 0.001) {
        t = line.tMax * l;
    }
    
    if (t > line.tMax * l) {
        return result;
    }
    
    if (t >= line.tMin && t <= line.tMax * l) {
        result.intersect = YES;
        result.intersectionPoint.x = p1.x + t * d.dx;
        result.intersectionPoint.y = p1.y + t * d.dy;
    }
    
    return result;
}

#pragma mark - Other
static BOOL AreLinesConnected(DHLineSegment* l1, DHLineSegment* l2)
{
    if (l1.start == l2.start || l1.start == l2.end || l1.end == l2.start || l1.end == l2.end) {
        return YES;
    }
    
    return NO;
}

static BOOL AreLinesEqual(DHLineSegment* l1, DHLineSegment* l2)
{
    if ((l1.start == l2.start && l1.end == l2.end) || (l1.start == l2.end && l1.end == l2.start)) {
        return YES;
    }
    
    return NO;
}

static CGPoint MidPointFromPoints(CGPoint p1, CGPoint p2)
{
    return CGPointMake(0.5*(p1.x + p2.x), 0.5*(p1.y + p2.y));
}

static CGPoint MidPointFromLine(DHLineObject* l)
{
    return CGPointMake(0.5*(l.start.position.x + l.end.position.x), 0.5*(l.start.position.y + l.end.position.y));
}

#pragma mark - Tool helper functions
static DHPoint* FindPointClosestToPoint(CGPoint point, NSArray* geometricObjects, CGFloat maxDistance)
{
    DHPoint* closestPoint = nil;
    //CGFloat closestPointDistance = maxDistance;
    CGFloat closestPointDistanceSquared = maxDistance*maxDistance;
    
    for (id object in geometricObjects) {
        if ([[object class] isSubclassOfClass:[DHPoint class]]) {
            CGPoint currentPoint = [object position];
            CGFloat distance = SquaredDistanceBetweenPoints(point, currentPoint);
            
            if (distance < closestPointDistanceSquared) {
                closestPoint = object;
                closestPointDistanceSquared = distance;
            }
        }
    }
    
    return closestPoint;
}

static DHPoint* FindPointClosestToCircle(DHCircle* c, NSArray* geometricObjects, CGFloat maxDistance)
{
    DHPoint* closestPoint = nil;
    CGFloat closestPointDistance = maxDistance;
    
    for (id object in geometricObjects) {
        if ([[object class] isSubclassOfClass:[DHPoint class]]) {
            CGPoint currentPoint = [object position];
            CGFloat distance = DistanceFromPositionToCircle(currentPoint, c);
            
            if (distance < closestPointDistance) {
                closestPoint = object;
                closestPointDistance = distance;
            }
        }
    }
    
    return closestPoint;
}

// NOTE: DHPoint p is skipped and not returned
static DHPoint* FindPointClosestToLine(DHLineObject* l, DHPoint* p, NSArray* geometricObjects, CGFloat maxDistance)
{
    DHPoint* closestPoint = nil;
    CGFloat closestPointDistance = maxDistance;
    
    for (id object in geometricObjects) {
        if (object == p) continue;
        
        if ([[object class] isSubclassOfClass:[DHPoint class]]) {
            CGFloat distance = DistanceFromPointToLine(object, l);
            
            if (distance < closestPointDistance) {
                closestPoint = object;
                closestPointDistance = distance;
            }
        }
    }
    return closestPoint;
}


static DHLineObject* FindLineClosestToPoint(CGPoint point, NSArray* geometricObjects, CGFloat maxDistance)
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

static DHLineSegment* FindLineSegmentClosestToPoint(CGPoint point, NSArray* geometricObjects, CGFloat maxDistance)
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

static DHCircle* FindCircleClosestToPoint(CGPoint point, NSArray* geometricObjects, CGFloat maxDistance)
{
    DHCircle* closestCircle = nil;
    CGFloat closestDistance = maxDistance;
    
    for (id object in geometricObjects) {
        if ([object class] == [DHCircle class]) {
            DHCircle* currentCircle = object;
            CGFloat distance = DistanceFromPositionToCircle(point, currentCircle);
            
            if (distance < closestDistance) {
                closestCircle = object;
                closestDistance = distance;
            }
        }
    }
    
    return closestCircle;
}

static NSArray* FindIntersectablesNearPoint(CGPoint point, NSArray* geometricObjects, CGFloat maxDistance)
{
    const CGFloat maxDistanceLimit = maxDistance;
    NSMutableArray* foundObjects = [[NSMutableArray alloc] init];
    DHPoint *dhPoint = [[DHPoint alloc] init];
    dhPoint.position = point;
    
    for (id object in geometricObjects) {
        if ([object class] == [DHCircle class]) {
            DHCircle* circle = (DHCircle*)object;
            CGFloat distanceToCircle = DistanceFromPositionToCircle(point, circle);
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

static id FindClosestIntersectableNearPoint(CGPoint point, NSArray* geometricObjects, CGFloat maxDistance)
{
    CGFloat closestDistance = maxDistance;
    
    id foundObject = nil;
    
    for (id object in geometricObjects) {
        CGFloat dist = CGFLOAT_MAX;
        
        if ([object class] == [DHCircle class]) dist = DistanceFromPositionToCircle(point, object);
        if ([[object class] isSubclassOfClass:[DHLineObject class]]) dist = DistanceFromPositionToLine(point, object);
        if (dist < closestDistance) {
            closestDistance = dist;
            foundObject = object;
        }
    }
    
    return foundObject;
}


static NSMutableArray* CreateIntersectionPointsBetweenObjects(NSArray* nearObjects)
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

static DHPoint* FindClosestUniqueIntersectionPoint(CGPoint touchPoint, NSArray* geometricObjects, CGFloat geoViewScale)
{
    NSArray* nearObjects = FindIntersectablesNearPoint(touchPoint, geometricObjects, kClosestTapLimit / geoViewScale);
    if (nearObjects.count < 2) {
        // At least two potentially intersecting objects required to create intersection point
        return nil;
    }
    NSMutableArray* intersectionPoints = CreateIntersectionPointsBetweenObjects(nearObjects);
    
    if (intersectionPoints.count == 0) {
        // No intersection points could be created
        return nil;
    }
    
    // Determine intersection point closest to touch point
    CGFloat closestDistance = CGFLOAT_MAX;
    DHPoint* closestPoint = nil;
    for (DHPoint* iPoint in intersectionPoints) {
        CGFloat distance = DistanceBetweenPoints(touchPoint, iPoint.position);
        if (distance < closestDistance) {
            closestDistance = distance;
            closestPoint = iPoint;
        }
    }
    
    // Check if point at intersection already exists, if so, don't create new one
    CGPoint newPoint = [closestPoint position];
    DHPoint* oldPoint = FindPointClosestToPoint(newPoint, geometricObjects, kClosestTapLimit / geoViewScale);
    CGPoint oldPointPos = [oldPoint position];
    if ((newPoint.x == oldPointPos.x) && (newPoint.y == oldPointPos.y))
    {
        return nil;
    }
    
    return closestPoint;
}

static CGPoint PointFromToWithSteps(CGPoint from, CGPoint to, CGFloat steps) {
    return CGPointMake((to.x - from.x)/steps, (to.y - from.y)/steps);
}

static BOOL Log(CGPoint point){
    
    NSLog(@"%f %f",point.x,point.y);
    return YES;
}

static BOOL LogF(CGFloat f){
    
    NSLog(@"%f",f);
    return YES;
}

#pragma clang diagnostic pop

#endif
