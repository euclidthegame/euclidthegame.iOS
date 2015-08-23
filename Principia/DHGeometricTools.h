//
//  DHGeometricTools.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <Foundation/Foundation.h>
#import "DHGeometricObjects.h"
#import "DHGeometricTransform.h"
#import "DHGeometryTool.h"

typedef NS_OPTIONS(NSUInteger, DHToolsAvailable)
{
    DHPointToolAvailable            = 1 << 0,
    DHLineSegmentToolAvailable      = 1 << 1,
    DHLineToolAvailable             = 1 << 2,
    DHCircleToolAvailable           = 1 << 3,
    DHIntersectToolAvailable        = 1 << 4,
    DHMidpointToolAvailable_Weak    = 1 << 5,
    DHMidpointToolAvailable         = 1 << 6,
    DHMoveToolAvailable             = 1 << 7,
    DHTriangleToolAvailable         = 1 << 8,
    DHBisectToolAvailable           = 1 << 9,
    DHPerpendicularToolAvailable    = 1 << 10,
    DHParallelToolAvailable         = 1 << 11,
    DHTranslateToolAvailable_Weak   = 1 << 12,
    DHTranslateToolAvailable        = 1 << 13,
    DHCompassToolAvailable          = 1 << 14,
    DHAllToolsAvailable = NSUIntegerMax
};

#define DHToolTempObjectCleanup(object) if (object) { \
                                            [self.delegate removeTemporaryGeometricObjects:@[object]]; \
                                            object = nil; \
                                        }

@interface DHPointTool : DHGeometryTool <DHGeometryTool>
@property (nonatomic, weak) DHPoint* point;
@property (nonatomic) CGPoint touchStart;
@end

@interface DHLineSegmentTool : DHGeometryTool <DHGeometryTool>
@property (nonatomic, weak) DHPoint* startPoint;
@end

@interface DHCircleTool : DHGeometryTool <DHGeometryTool>
@property (nonatomic, weak) DHPoint* center;
@end

@interface DHIntersectTool : DHGeometryTool <DHGeometryTool>
@end


@interface DHMidPointTool : DHGeometryTool <DHGeometryTool>
@property (nonatomic, weak) DHPoint* startPoint;
@property (nonatomic, weak) DHCircle* circle;
@property (nonatomic) BOOL disableCircles;
@end

@interface DHLineTool : DHGeometryTool <DHGeometryTool>
@property (nonatomic, weak) DHPoint* startPoint;
@end

@interface DHTriangleTool : DHGeometryTool <DHGeometryTool>
@property (nonatomic, weak) DHPoint* startPoint;
@end

@interface DHBisectTool : DHGeometryTool <DHGeometryTool>
@property (nonatomic, weak) DHLineObject* firstLine;
@property (nonatomic, weak) DHLineObject* secondLine;
@property (nonatomic, weak) DHPoint* firstPoint;
@property (nonatomic, weak) DHPoint* secondPoint;
@property (nonatomic, weak) DHPoint* thirdPoint;
@end


@interface DHPerpendicularTool : DHGeometryTool <DHGeometryTool>
@property (nonatomic, weak) DHLineObject* line;
@end

@interface DHParallelTool : DHGeometryTool <DHGeometryTool>
@property (nonatomic, weak) DHLineObject* line;
@end

@interface DHTranslateSegmentTool : DHGeometryTool <DHGeometryTool>
@property (nonatomic, weak) DHPoint* start;
@property (nonatomic, weak) DHPoint* end;
@property (nonatomic, weak) DHLineSegment* segment;
@property (nonatomic) BOOL disableWhenOnSameLine;
@end

@interface DHCompassTool : DHGeometryTool <DHGeometryTool>
@property (nonatomic, weak) DHPoint* firstPoint;
@property (nonatomic, weak) DHPoint* secondPoint;
@property (nonatomic, weak) DHLineSegment* radiusSegment;
@property (nonatomic, weak) DHCircle* radiusCircle;
@end