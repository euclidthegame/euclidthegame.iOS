//
//  DHMathFuzzyComparisons.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-23.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHMathFuzzyComparisons.h"
#import "DHMath.h"

const CGFloat kFuzzyEpsilon = 0.01;

BOOL EqualPoints(id point1, id point2)
{
    if ([[point1 class] isSubclassOfClass:[DHPoint class]] &&
        [[point2 class] isSubclassOfClass:[DHPoint class]])
    {
        DHPoint* p1 = point1;
        DHPoint* p2 = point2;
        
        if (fabs(p1.position.x-p2.position.x) < kFuzzyEpsilon &&
            fabs(p1.position.y - p2.position.y) < kFuzzyEpsilon) {
            return YES;
        }
        else return NO;
    }
    else return NO;
    
}

BOOL EqualPositions(CGPoint p1, CGPoint p2)
{
    if (fabs(p1.x - p2.x) < kFuzzyEpsilon && fabs(p1.y - p2.y) < kFuzzyEpsilon)
        return YES;
    else
        return NO;
    
}

BOOL PointOnLine(id point, id lineObject)
{
    if ([[point class] isSubclassOfClass:[DHPoint class]] &&
        [[lineObject class] isSubclassOfClass: [DHLineObject class]])
    {
        DHPoint* p = point;
        DHLineObject* l = lineObject;
        CGFloat dist = DistanceFromPointToLine(p, l);
        if (dist < kFuzzyEpsilon) return YES;
        else return NO;
    }
    else return NO;
}

BOOL PointOnCircle(id point, id circle)
{
    if ([[point class] isSubclassOfClass:[DHPoint class]] &&
        [circle class] == [DHCircle class])
    {
        DHPoint* p = point;
        DHCircle* c = circle;
        CGFloat dist = DistanceFromPositionToCircle(p.position, c);
        if (dist < kFuzzyEpsilon) return YES;
        else return NO;
    }
    else return NO;
}

BOOL LineObjectCoversSegment(id lineObject, id lineSegment)
{
    if (
        [[lineObject class] isSubclassOfClass:[DHLineObject class]] &&
        [lineSegment class] == [DHLineSegment class])
    {
        DHLineObject* l = lineObject;
        DHLineSegment* s = lineSegment;
        if (PointOnLine(s.start, l) &&
            PointOnLine(s.end,l))
            return YES;
        else return NO;
    }
    else return NO;
}

BOOL EqualLines(id line1, id line2)
{
    if (
        [line1 class] == [DHLine class] &&
        [line2 class] == [DHLine class])
    {
        DHLine* l1 = line1;
        DHLine* l2 = line2;
        if (PointOnLine(l1.start,l2) && PointOnLine(l1.end,l2))
        {
            return YES;
        }
        else return NO;
    }
    else return NO;
}


BOOL EqualDirection(id lineObject1, id lineObject2)
{
    if (
        [[lineObject1 class] isSubclassOfClass:[DHLineObject class]] &&
        [[lineObject2 class] isSubclassOfClass:[DHLineObject class]])
    {
        DHLineObject* l1 = lineObject1;
        DHLineObject* l2 = lineObject2;
        DHLine* line2 = [[DHLine alloc] initWithStart:l2.start andEnd:l2.end];
        if (PointOnLine(l1.start,line2) && PointOnLine(l1.end,line2))
        {
            return YES;
        }
        else return NO;
    }
    else return NO;
}


BOOL EqualDirection2(id lineObject1, id lineObject2)
{
    if (
        [[lineObject1 class] isSubclassOfClass:[DHLineObject class]] &&
        [[lineObject2 class] isSubclassOfClass:[DHLineObject class]])
    {
        DHLineObject* l1 = lineObject1;
        DHLineObject* l2 = lineObject2;
        if (
            fabs((l1.end.position.y - l1.start.position.y)*(l2.end.position.x - l2.start.position.x) - (l2.end.position.y - l2.start.position.y)*(l1.end.position.x - l1.start.position.x)) < kFuzzyEpsilon )
        {
            return YES;
        }
        else return NO;
    }
    else return NO;
}


BOOL EqualCircles(id circle1, id circle2)
{
    if ([circle1 class] == [DHCircle class] && [circle2 class] == [DHCircle class])
    {
        DHCircle* c1 = circle1;
        DHCircle* c2 = circle2;
        
        if (EqualPoints(c1.center, c2.center) && EqualScalarValues(c1.radius, c2.radius)) {
            return YES;
        } else {
            return NO;
        }
    }
    else return NO;
}

BOOL LinesPerpendicular(DHLineObject* l1, DHLineObject* l2)
{
    CGFloat dot = CGVectorDotProduct(CGVectorNormalize(l1.vector), CGVectorNormalize(l2.vector));
    if (dot < kFuzzyEpsilon) {
        return YES;
    }
    return NO;
}

BOOL EqualLineSegments(id segment1, id segment2)
{
    if ([segment1 class] == [DHLineSegment class] && [segment2 class] == [DHLineSegment class]) {
        DHLineSegment* s1 = segment1;
        DHLineSegment* s2 = segment2;
        if ((EqualPoints(s1.start, s2.start) && EqualPoints(s1.end, s2.end)) ||
            (EqualPoints(s1.start, s2.end) && EqualPoints(s1.end, s2.start))){
            return YES;
        }
    }
    return NO;
}

BOOL LineSegmentsWithEqualLength(id segment1, id segment2)
{
    if ([segment1 class] == [DHLineSegment class] && [segment2 class] == [DHLineSegment class]) {
        DHLineSegment* s1 = segment1;
        DHLineSegment* s2 = segment2;
        if (fabs(s1.length - s2.length) < kFuzzyEpsilon) {
            return YES;
        }
    }
    return NO;
}

BOOL EqualScalarValues(CGFloat a, CGFloat b)
{
    return fabs(a-b) < kFuzzyEpsilon;
}

CGFloat AngleBetweenLineObjects(id o1, id o2)
{
    if ([[o1 class] isSubclassOfClass:[DHLineObject class]] &&
        [[o2 class] isSubclassOfClass:[DHLineObject class]])
    {
        DHLineObject* l1 = o1;
        DHLineObject* l2 = o2;
        
        DHIntersectionResult r = IntersectionTestLineLine(l1, l2);
        
        if (r.intersect) {
            CGVector v1 = l1.vector;
            CGVector v2 = l2.vector;
            BOOL angleFromEndPointL1 = NO;
            BOOL angleFromEndPointL2 = NO;
            if (l1.tMin > -INFINITY && EqualPositions(l1.start.position, r.intersectionPoint)) {
                angleFromEndPointL1 = YES;
            }
            if (l2.tMin > -INFINITY && EqualPositions(l2.start.position, r.intersectionPoint)) {
                angleFromEndPointL2 = YES;
            }
            if (l1.tMax < INFINITY && EqualPositions(l1.end.position, r.intersectionPoint)) {
                angleFromEndPointL1 = YES;
                v1 = CGVectorInvert(v1);
            }
            if (l2.tMax < INFINITY && EqualPositions(l2.end.position, r.intersectionPoint)) {
                angleFromEndPointL2 = YES;
                v2 = CGVectorInvert(v2);
            }
            
            CGFloat angle = CGVectorAngleBetween(v1, v2);
            if (!(angleFromEndPointL1 && angleFromEndPointL2) && angle > M_PI_2) {
                angle = M_PI - angle;
            }
            return angle;
        }
    }
    
    return NAN;
}

CGFloat GetAngle(id rayOrSegment, id lineObject){
    if ([[rayOrSegment class] isSubclassOfClass:[DHLineObject class]] &&
        [[lineObject class] isSubclassOfClass:[DHLineObject class]])
    
    {
        DHLineObject* l1 = rayOrSegment;
        DHLineObject* l2 = lineObject;
        DHIntersectionPointLineLine* intersection = [[DHIntersectionPointLineLine alloc] initWithLine:l1 andLine:l2];
        
        
        if (PointOnLine(intersection,l1) && PointOnLine(intersection,l2)){
            if (EqualPoints(l1.end,intersection))
            {
                DHPoint* swap = l1.end;
                l1.end = l1.start;
                l1.start = swap;
            }
            if (l2.tMin == 0.0f && EqualPoints(l2.end,intersection))
            {
                DHPoint* swap = l2.end;
                l2.end = l2.start;
                l2.start = swap;
            }
            CGFloat result = CGVectorAngleBetween(l1.vector,l2.vector);
            //if l2 is a line, two angles are made, the function returns only the acute angle
            if (l2.tMin <0 && result > 0.5* M_PI ){
                result = M_PI - result;
            }
            return result;
        }
    }
    return NAN;
}

CGPoint Position(id object) {
    if ([[object class] isSubclassOfClass:[DHPoint class]]) {
        DHPoint* point = object;
        return point.position;
    }
    else if ([[object class] isSubclassOfClass:[DHLineObject class]])
    {
        DHLineObject* line = object;
        return MidPointFromLine(line);
    }
    else if ([object class] == [DHCircle class]){
        DHCircle* circle = object;
        return circle.center.position;
    }
    else return CGPointMake(NAN,NAN);
}

BOOL EqualRadius (id circle1, id circle2){
    if ([circle1 class] == [DHCircle class] && [circle2 class] == [DHCircle class]){
        DHCircle* c1 = circle1;
        DHCircle* c2 = circle2;
        if (EqualScalarValues(c1.radius, c2.radius)){
            return YES;
        }
    }
    return NO;
}

BOOL LineObjectTangentToCircle(id lineObject, id circle)
{
    if ([lineObject isKindOfClass:[DHLineObject class]] && [circle isKindOfClass:[DHCircle class]]){
        DHLineObject* l = lineObject;
        DHCircle* c = circle;
        CGFloat cRadius = c.radius;
        
        CGPoint closestPointOnLine = ClosestPointOnLineFromPosition(c.center.position, l);
        // Ensure closest point is on the radius
        CGFloat distCP = DistanceBetweenPoints(c.center.position, closestPointOnLine);
        if (!EqualScalarValues(cRadius, distCP)) {
            return NO;
        }
        
        // Ensure line object is perpendicular to line from circle center to radius
        DHPoint* pClosest = [[DHPoint alloc] initWithPosition:closestPointOnLine];
        DHLineSegment* s = [[DHLineSegment alloc] initWithStart:c.center andEnd:pClosest];
        DHPerpendicularLine* perpLine = [[DHPerpendicularLine alloc] initWithLine:s andPoint:pClosest];
        if (EqualDirection(perpLine, l)) {
            return YES;
        }
        
    }
    return NO;
}