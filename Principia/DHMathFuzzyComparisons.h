//
//  DHMathFuzzyComparisons.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHGeometricObjects.h"

BOOL FuzzyPointsEqual(DHPoint* p1, DHPoint* p2);
BOOL FuzzyPointOnLine(DHPoint* p, DHLineObject* l);
BOOL FuzzyLinesPerpendicular(DHLineObject* l1, DHLineObject* l2);