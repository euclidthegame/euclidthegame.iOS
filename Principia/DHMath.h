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
    
    if (fabs(a-b) < 5 * CGFLOAT_EPSILON * fabs(a+b) || fabs(a-b) < CGFLOAT_MIN) return YES;
    
    return NO;
}

#pragma mark - Distance functions
static CGFloat DistanceBetweenPoints(CGPoint a, CGPoint b)
{
    return ({CGFloat d1 = a.x - b.x, d2 = a.y - b.y; sqrt(d1 * d1 + d2 * d2); });
}

static CGFloat DistanceFromPointToLine(DHPoint* point, DHLine* line)
{
    CGPoint p = point.position;
    CGPoint l1 = line.start.position;
    CGPoint l2 = line.end.position;
    
    CGFloat Dx = l2.x - l1.x;
    CGFloat Dy = l2.y - l1.y;
    
    CGFloat distance = fabs(Dy*p.x - Dx * p.y - l1.x*l2.y + l2.x*l1.y)/DistanceBetweenPoints(l1, l2);
    
    return distance;
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

static BOOL DoLinesIntersect(DHLine* l1, DHLine* l2)
{
    CGPoint p1 = l1.start.position;
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
    
    return false;
}

static DHIntersectionResult DoLineAndCircleIntersect(DHLine* line, DHCircle* circle, BOOL preferEnd)
{
    DHIntersectionResult result;
    result.intersectionPoint.x = NAN;
    result.intersectionPoint.y = NAN;
    
    CGVector m = CGVectorBetweenPoints(circle.center.position, line.start.position);
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
    
    return result;
}

#pragma mark - Other
static BOOL AreLinesConnected(DHLine* l1, DHLine* l2)
{
    if (l1.start == l2.start || l1.start == l2.end || l1.end == l2.start || l1.end == l2.end) {
        return YES;
    }
    
    return NO;
}

static BOOL AreLinesEqual(DHLine* l1, DHLine* l2)
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
