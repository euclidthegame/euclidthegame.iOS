//
//  DHGeometricTools.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHGeometricObjects.h"
#import "DHGeometricTransform.h"
#import "DHGeometryTool.h"

typedef NS_OPTIONS(NSUInteger, DHToolsAvailable)
{
    DHPointToolAvailable = 1 << 0,
    DHLineSegmentToolAvailable = 1 << 1,
    DHLineToolAvailable = 1 << 2,
    DHCircleToolAvailable = 1 << 3,
    DHIntersectToolAvailable = 1 << 4,
    DHMidpointToolAvailable = 1 << 5,
    DHMoveToolAvailable = 1 << 6,
    DHTriangleToolAvailable = 1 << 7,
    DHBisectToolAvailable = 1 << 8,
    DHPerpendicularToolAvailable = 1 << 9,
    DHParallelToolAvailable = 1 << 10,
    DHTranslateToolAvailable_Weak = 1 << 11,
    DHTranslateToolAvailable = 1 << 12,
    DHCompassToolAvailable = 1 << 13,
    DHAllToolsAvailable = NSUIntegerMax
};

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
@end

@interface DHLineTool : DHGeometryTool <DHGeometryTool>
@property (nonatomic, weak) DHPoint* startPoint;
@end

@interface DHTriangleTool : DHGeometryTool <DHGeometryTool>
@property (nonatomic, weak) DHPoint* startPoint;
@end

@interface DHBisectTool : DHGeometryTool <DHGeometryTool>
@property (nonatomic, weak) DHLineObject* firstLine;
@property (nonatomic, weak) DHPoint* firstPoint;
@property (nonatomic, weak) DHPoint* secondPoint;
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

@end