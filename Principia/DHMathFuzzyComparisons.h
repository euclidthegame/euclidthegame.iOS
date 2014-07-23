//
//  DHMathFuzzyComparisons.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHGeometricObjects.h"

BOOL EqualPoints(id point1, id point2);
BOOL PointOnLine(id point, id lineObject);
BOOL LineObjectCoversSegment(id lineObject, id lineSegment);
BOOL EqualDirection(id lineObject, id lineObjectOrSegment);
BOOL EqualCircles(id circle1, id circle2);
BOOL LinesPerpendicular(DHLineObject* l1, DHLineObject* l2);
