//
//  DHLevels.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#ifndef Euclid_DHLevels_h
#define Euclid_DHLevels_h

#import "DHLevelTutorial.h"
#import "DHLevelEquiTri.h"
#import "DHLevelMidPoint.h"
#import "DHLevelBisect.h"
#import "DHLevelPerpendicular.h"
#import "DHLevelPerpendicularB.h"
#import "DHLevelParallellLines.h"
#import "DHLevelLineCopy.h"
#import "DHLevelLineCopy2.h"
#import "DHLevelMakeCompass.h"
#import "DHLevelLineCopyOnLine.h"
#import "DHLevelNonEquiTri.h"
#import "DHLevelCopyAngle.h"
#import "DHLevelCircleCenter.h"
#import "DHLevelMakeTangent.h"
#import "DHLevelTriIncircle.h"
#import "DHLevelTriCircumcircle.h"
#import "DHLevelCircleSegmentCutoff.h"
#import "DHLevelCircleToTangent.h"
#import "DHLevelThreeCircles.h"
#import "DHLevelSegmentInThree.h"
#import "DHLevelCircleTangentFromPoint.h"
#import "DHLevelHexagon.h"
#import "DHLevelTwoCirclesOuterTangent.h"
#import "DHLevelTwoCirclesInnerTangent.h"
#import "DHLevelPentagon.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
static void FillLevelArray(NSMutableArray* array) {
    [array addObject:[[DHLevelEquiTri alloc] init]];
    [array addObject:[[DHLevelMidPoint alloc] init]];
    [array addObject:[[DHLevelBisect alloc] init]];
    [array addObject:[[DHLevelPerpendicular alloc] init]];
    [array addObject:[[DHLevelPerpendicularB alloc] init]];
    [array addObject:[[DHLevelParallellLines alloc] init]];
    [array addObject:[[DHLevelLineCopy alloc] init]];
    [array addObject:[[DHLevelLineCopy2 alloc] init]];
    [array addObject:[[DHLevelMakeCompass alloc] init]];
    [array addObject:[[DHLevelLineCopyOnLine alloc] init]];
    [array addObject:[[DHLevelNonEquiTri alloc] init]];
    [array addObject:[[DHLevelCopyAngle alloc] init]];
    [array addObject:[[DHLevelCircleCenter alloc] init]];
    [array addObject:[[DHLevelMakeTangent alloc] init]];
    [array addObject:[[DHLevelTriIncircle alloc] init]];
    [array addObject:[[DHLevelTriCircumcircle alloc] init]];
    [array addObject:[[DHLevelCircleSegmentCutoff alloc] init]];
    [array addObject:[[DHLevelCircleToTangent alloc] init]];
    [array addObject:[[DHLevelThreeCircles alloc] init]];
    [array addObject:[[DHLevelHexagon alloc] init]];
    [array addObject:[[DHLevelSegmentInThree alloc] init]];
    [array addObject:[[DHLevelCircleTangentFromPoint alloc] init]];
    [array addObject:[[DHLevelTwoCirclesOuterTangent alloc] init]];
    [array addObject:[[DHLevelTwoCirclesInnerTangent alloc] init]];
    [array addObject:[[DHLevelPentagon alloc] init]];
}
#pragma clang diagnostic pop

#endif
