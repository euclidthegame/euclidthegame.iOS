//
//  DHMath.h
//  Principia
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#ifndef Principia_DHMath_h
#define Principia_DHMath_h

#import "DHGeometricObjects.h"
#import "DHMathCGVector.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"

typedef struct DHIntersectionResult {
    BOOL intersect;
    CGPoint intersectionPoint;
} DHIntersectionResult;

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

#pragma mark - Distance functions
static CGFloat DistanceBetweenPoints(CGPoint a, CGPoint b)
{
    return ({CGFloat d1 = a.x - b.x, d2 = a.y - b.y; sqrt(d1 * d1 + d2 * d2); });
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
    
    
    /*CGPoint p = point.position;
    CGPoint l1 = line.start.position;
    CGPoint l2 = line.end.position;
    
    CGFloat Dx = l2.x - l1.x;
    CGFloat Dy = l2.y - l1.y;
    
    CGFloat distance = fabs(Dy*p.x - Dx * p.y - l1.x*l2.y + l2.x*l1.y)/DistanceBetweenPoints(l1, l2);
    
    return distance;*/
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

// To find orientation of ordered triplet (p, q, r).
// The function returns following values
// 0 --> p, q and r are colinear
// 1 --> Clockwise
// 2 --> Counterclockwise
static int OrientationOfPoints(CGPoint p, CGPoint q, CGPoint r)
{
    CGFloat val = (q.y - p.y) * (r.x - q.x) -
    (q.x - p.x) * (r.y - q.y);
    
    if (fabs(val) < 0.00001) return 0;  // colinear
    
    return (val > 0)? 1: 2; // clock or counterclock wise
}

static CGFloat Signed2DTriArea(CGPoint a, CGPoint b, CGPoint c)
{
    return (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x);
}

static DHIntersectionResult IntersectionTestLineLine(DHLineObject* l1, DHLineObject* l2)
{
    DHIntersectionResult result;
    result.intersectionPoint.x = NAN;
    result.intersectionPoint.y = NAN;
    
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
        result.intersectionPoint.x = pA.x + t * vAB.dx;
        result.intersectionPoint.y = pA.y + t * vAB.dy;
    }
    
    return result;
}

static BOOL DoLinesIntersect(DHLineObject* l1, DHLineObject* l2)
{
    CGPoint pA = l1.start.position;
    CGPoint pB = l1.end.position;
    CGPoint pC = l2.start.position;
    CGPoint pD = l2.end.position;

    CGVector vAB = CGVectorBetweenPoints(pA, pB);
    CGVector vAC = CGVectorBetweenPoints(pA, pC);
    CGVector n = CGVectorMakePerpendicular(CGVectorBetweenPoints(pC, pD));
    
    CGFloat t = CGVectorDotProduct(n, vAC)/CGVectorDotProduct(n, vAB);
    
    if (t >= l1.tMin && t >= l2.tMin && t <= l1.tMax && t <= l2.tMax) {
        return YES;
    }
    
    return NO;
    
    /*CGPoint p1 = l1.start.position;
    CGPoint q1 = l1.end.position;
    CGPoint p2 = l2.start.position;
    CGPoint q2 = l2.end.position;
    
    if (CGPointEqualToPoint(p1, q1) ||
        CGPointEqualToPoint(p1, p2) ||
        CGPointEqualToPoint(p1, q2) ||
        CGPointEqualToPoint(q1, p2) ||
        CGPointEqualToPoint(q1, q2) ||
        CGPointEqualToPoint(p2, q2)) {
        return false;
    }
    
    // Find the four orientations
    int o1 = OrientationOfPoints(p1, q1, p2);
    int o2 = OrientationOfPoints(p1, q1, q2);
    int o3 = OrientationOfPoints(p2, q2, p1);
    int o4 = OrientationOfPoints(p2, q2, q1);
    
    if (o1 != o2 && o3 != o4)
        return true;
    
    return false;*/
}

static DHIntersectionResult DoLineAndCircleIntersect(DHLineObject* line, DHCircle* circle, BOOL preferEnd)
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
    
    //Exit if r's origin outside s (c > 0) and r pointing away from s (b > 0)
    if (c > 0.0 && b > 0) return result;
    
    CGFloat discr = b*b - c;
    
    // A negative discriminant corresponds to line missing circle
    if (discr < 0.0f) return result;
    
    // Line found to intersect circle, now compute smallest t value of intersection
    CGFloat t = -b - sqrt(discr);
    
    // Check if the t value is within the the line objects allowed values
    if (t < line.tMin || (preferEnd && -b + sqrt(discr) <= line.tMax * l)) {
        // Check if larger t value works
        t = -b + sqrt(discr);
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
    
    /*CGVector m = CGVectorBetweenPoints(circle.center.position, line.start.position);
    CGVector d = CGVectorBetweenPoints(line.start.position, line.end.position);
    CGFloat l = line.length;
    d.dx = d.dx / l;
    d.dy = d.dy / l;
    CGFloat b = CGVectorDotProduct(m, d);
    CGFloat r = circle.radius;
    CGFloat c = CGVectorDotProduct(m, m) - r * r;
    // Exit if lines origin is outside circle and the direction of the line pointing away from circle
    if (c > 0.0f && b > 0.0f) return result;
    
    CGFloat discr = b*b - c;
    
    // A negative discriminant corresponds to line not directed toward circle
    if (discr < 0.0f) return result;
    
    CGFloat t = -b - sqrt(discr);
    if (t < 0.0f || (preferEnd && -b + sqrt(discr) <= l)) {
        t = -b + sqrt(discr);
    }
    
    if (t >= 0.0f && t <= l) {
        result.intersect = YES;
        result.intersectionPoint.x = line.start.position.x + t * d.dx;
        result.intersectionPoint.y = line.start.position.y + t * d.dy;
        
        return result;
    }
    
    return result;*/
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

#pragma clang diagnostic pop

#endif
