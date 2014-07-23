//
//  DHMathFuzzyComparisons.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
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


BOOL EqualCircles(id circle1, id circle2)
{
    if ([circle1 class] == [DHCircle class] && [circle2 class] == [DHCircle class])
    {
        DHCircle* c1 = circle1;
        DHCircle* c2 = circle2;
        if (EqualPoints(c1.center, c2.center) &&
            EqualPoints(c1.pointOnRadius, c2.pointOnRadius))
            return YES;
        else return NO;
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
        if (EqualPoints(s1.start, s2.start) && EqualPoints(s1.end, s2.end)) {
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