//
//  DHMathFuzzyComparisons.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-23.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <Foundation/Foundation.h>
#import "DHGeometricObjects.h"

BOOL EqualPoints(id point1, id point2);
BOOL EqualPositions(CGPoint p1, CGPoint p2);
BOOL EqualLines(id lineObject1, id lineObject2);
BOOL EqualCircles(id circle1, id circle2);
BOOL EqualScalarValues(CGFloat a, CGFloat b);
BOOL EqualRadius (id circle1, id circle2);
BOOL EqualLineSegments(id segment1, id segment2);

BOOL PointOnLine(id point, id lineObject);
BOOL PointOnCircle(id point, id circle);

BOOL LineObjectCoversSegment(id lineObject, id lineSegment);
BOOL EqualDirection(id lineObject1, id lineObject2);
BOOL EqualDirection2(id lineObject1, id lineObject2);
BOOL LinesPerpendicular(DHLineObject* l1, DHLineObject* l2);
BOOL LineSegmentsWithEqualLength(id segment1, id segment2);
BOOL LineObjectTangentToCircle(id lineObject, id circle);

CGFloat AngleBetweenLineObjects(id o1, id o2);
CGPoint Position(id object);
CGFloat GetAngle(id rayOrSegment, id lineObject);
