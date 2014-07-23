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

BOOL FuzzyPointsEqual(DHPoint* p1, DHPoint* p2)
{
    if (fabs(p1.position.x-p2.position.x) < kFuzzyEpsilon &&
        fabs(p1.position.y - p2.position.y) < kFuzzyEpsilon) {
        return YES;
    }
    return NO;
}

BOOL FuzzyPointOnLine(DHPoint* p, DHLineObject* l)
{
    CGFloat dist = DistanceFromPointToLine(p, l);
    if (dist < kFuzzyEpsilon) {
        return YES;
    }
    
    return NO;
}

BOOL FuzzyLinesPerpendicular(DHLineObject* l1, DHLineObject* l2)
{
    CGFloat dot = CGVectorDotProduct(CGVectorNormalize(l1.vector), CGVectorNormalize(l2.vector));
    if (dot < kFuzzyEpsilon) {
        return YES;
    }
    return NO;
}