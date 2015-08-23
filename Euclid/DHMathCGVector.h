//
//  DHMathCGVector.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#ifndef Euclid_DHMathCGVector_h
#define Euclid_DHMathCGVector_h

@import CoreGraphics;
@import Foundation;

#include <math.h>

#if defined(__ARM_NEON__)
#include <arm_neon.h>
#endif


CG_INLINE CGVector CGVectorBetweenPoints(CGPoint from, CGPoint to);
CG_INLINE CGVector CGVectorBetweenPoints(CGPoint from, CGPoint to)
{
    return CGVectorMake(to.x - from.x, to.y - from.y);
}

CG_INLINE CGVector CGVectorInvert(CGVector vector)
{
    return CGVectorMake(-vector.dx, -vector.dy);
}

/* Add two vectors */
CG_INLINE CGVector CGVectorSum(CGVector vector1, CGVector vector2);

/* Subtract two vectors */
CG_INLINE CGVector CGVectorDifference(CGVector vector1, CGVector vector2);

/* Multiply two vectors */
CG_INLINE CGVector CGVectorMultiply(CGVector vector1, CGVector vector2);

/* Multiply a vector by a single scalar */
CG_INLINE CGVector CGVectorMultiplyByScalar(CGVector vector, CGFloat scalar);

/* Normalize a vector. This scales the length of the vector to 1 */
CG_INLINE CGVector CGVectorNormalize(CGVector vector);

/* Creates a vector perpendicular to `vector` */
CG_INLINE CGVector CGVectorMakePerpendicular(CGVector vector);

/* Calculate the angle of between two vectors */
CG_INLINE CGFloat CGVectorAngleBetween(CGVector vector1, CGVector vector2);

/* Calculate the angle of `vector` */
CG_INLINE CGFloat CGVectorAngle(CGVector vector);

/* Rotates the vector by angle */
CG_INLINE CGVector CGVectorRotateByAngle(CGVector vector, CGFloat angle);

/* Calculate new point translated by vector */
CG_INLINE CGPoint CGPointFromPointByAddingVector(CGPoint p, CGVector v);

/* Calculate the dot product of two vectors */
CG_INLINE CGFloat CGVectorDotProduct(CGVector vector1, CGVector vector2);

/* Calculate the magnitude (length) of a vector */
CG_INLINE CGFloat CGVectorLength(CGVector vector);

/* Calculate the distance between two vectors */
CG_INLINE CGFloat CGVectorDistance(CGVector vectorStart, CGVector vectorEnd);

/* Create an NSString describing this vector */
//static CG_INLINE NSString* NSStringFromCGVector(CGVector vector);

/* Determine if two vectors are equal */
CG_INLINE bool __CGVectorEqualToVector(CGVector vector1, CGVector vector2);

/* Determine if two vectors are perpendicular */
CG_INLINE bool __CGVectorPerpendicularToVector(CGVector vector1, CGVector vector2);


#pragma mark -
#pragma mark Implementations
#pragma mark -

CG_INLINE CGVector CGVectorSum(CGVector vector1, CGVector vector2)
{
#if defined(__ARM_NEON__) && 0
    float32x2_t v = vadd_f32(*(float32x2_t *)&vector1,
                             *(float32x2_t *)&vector2);
    return *(CGVector *)&v;
#else
    return CGVectorMake(vector1.dx + vector2.dx, vector1.dy + vector2.dy);
#endif
}

CG_INLINE CGVector CGVectorDifference(CGVector vector1, CGVector vector2)
{
#if defined(__ARM_NEON__) && 0
    float32x2_t v = vsub_f32(*(float32x2_t *)&vector1,
                             *(float32x2_t *)&vector2);
    return *(CGVector *)&v;
#else
    return CGVectorMake(vector1.dx - vector2.dx, vector1.dy - vector2.dy);
#endif
}

CG_INLINE CGVector CGVectorMultiply(CGVector vector1, CGVector vector2)
{
#if defined(__ARM_NEON__) && 0
    float32x2_t v = vmul_f32(*(float32x2_t *)&vector1,
                             *(float32x2_t *)&vector2);
    return *(CGVector *)&v;
#else
    return CGVectorMake(vector1.dx * vector2.dx, vector1.dy * vector2.dy);
#endif
}

CG_INLINE CGVector CGVectorMultiplyByScalar(CGVector vector, CGFloat value)
{
#if defined(__ARM_NEON__) && !CGFLOAT_IS_DOUBLE
    float32x2_t v = vmul_f32(*(float32x2_t *)&vector,
                             vdup_n_f32((float32_t)value));
    return *(CGVector *)&v;
#else
    return CGVectorMake(vector.dx * value, vector.dy * value);
#endif
}

CG_INLINE CGVector CGVectorNormalize(CGVector vector)
{
	CGFloat length = CGVectorLength(vector);
    
	if (length == 0) {
		return CGVectorMake(0, 0);
	}
    
    CGFloat scale = 1.0f / length;
    return CGVectorMultiplyByScalar(vector, scale);
}

CG_INLINE CGVector CGVectorMakePerpendicular(CGVector vector)
{
    return CGVectorMake(-vector.dy, vector.dx);
}

CG_INLINE CGFloat CGVectorAngleBetween(CGVector vector1, CGVector vector2)
{
    CGFloat dot = CGVectorDotProduct(vector1, vector2);
    CGFloat magnitude = CGVectorLength(vector1) * CGVectorLength(vector2);
    
	if (magnitude == 0) {
		return 0;
	}
    
	CGFloat tmp = dot / magnitude;
    
	if (tmp > 1.0f) {
		tmp = 1.0f;
	} else if (tmp < -1.0f) {
		tmp = -1.0f;
	}
    
#if CGFLOAT_IS_DOUBLE
    return acos( tmp );
#else
    return acosf( tmp );
#endif
}

CG_INLINE CGFloat CGVectorAngle(CGVector vector)
{
    return atan2(vector.dy, vector.dx);
}

CG_INLINE CGFloat CGVectorDotProduct(CGVector vector1, CGVector vector2)
{
#if defined(__ARM_NEON__) && 0
    float32x2_t v = vmul_f32(*(float32x2_t *)&vector1,
                             *(float32x2_t *)&vector2);
    v = vpadd_f32(v, v);
    return vget_lane_f32(v, 0);
#else
    return vector1.dx * vector2.dx + vector1.dy * vector2.dy;
#endif
}

CG_INLINE CGFloat CGVectorLength(CGVector vector)
{
#if defined(__ARM_NEON__) && 0
    float32x2_t v = vmul_f32(*(float32x2_t *)&vector,
                             *(float32x2_t *)&vector);
    v = vpadd_f32(v, v);
    return sqrt(vget_lane_f32(v, 0));
#else
    return hypotf(vector.dx, vector.dy);
#endif
}

CG_INLINE CGFloat CGVectorDistance(CGVector vectorStart, CGVector vectorEnd)
{
    return CGVectorLength(CGVectorDifference(vectorEnd, vectorStart));
}

/*CG_INLINE NSString* NSStringFromCGVector(CGVector vector)
{
    return [NSString stringWithFormat:@"{%f, %f}", vector.dx, vector.dy];
}*/

CG_INLINE bool CGVectorEqualToVector(CGVector vector1, CGVector vector2)
{
    return vector1.dx == vector2.dx && vector1.dy == vector2.dy;
}

CG_INLINE bool CGVectorPerpendicularToVector(CGVector vector1, CGVector vector2)
{
    return CGVectorDotProduct(vector1, vector2) == 0;
}

CG_INLINE CGVector CGVectorRotateByAngle(CGVector vector, CGFloat angle)
{
    CGVector result;
    result.dx = vector.dx * cos(angle) - vector.dy * sin(angle);
    result.dy = vector.dx * sin(angle) + vector.dy * cos(angle);
    return result;
}

CG_INLINE CGPoint CGPointFromPointByAddingVector(CGPoint p, CGVector v)
{
    CGPoint result;
    result.x = p.x + v.dx;
    result.y = p.y + v.dy;
    return result;
}

#endif
