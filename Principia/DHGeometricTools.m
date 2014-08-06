//
//  DHGeometricTools.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHGeometricObjects.h"
#import "DHMath.h"

const CGFloat kClosestTapLimit = 25.0f;

@implementation DHCircleTool {
    CGPoint _touchPointInViewStart;
    DHPoint* _temporaryCenter;
    DHCircle* _temporaryCircle;
}
- (NSString*)initialToolTip
{
    return @"Tap on any point to mark the center of a new circle";
}
- (void)touchBegan:(UITouch*)touch
{
    _touchPointInViewStart = [touch locationInView:touch.view];
    
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
    if (!point) {
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        if (intersectionPoint) {
            if (!self.center) _temporaryCenter = intersectionPoint;
            point = intersectionPoint;
        }
    }
    
    if (!self.center && point) {
        self.center = point;
        point.highlighted = true;
        [self.delegate toolTipDidChange:@"Drag to a point that the circle will pass through"];
        
        if (_temporaryCenter) {
            [self.delegate addTemporaryGeometricObjects:@[_temporaryCenter]];
        }
        [touch.view setNeedsDisplay];
    } else if (self.center) {
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryCircle = [[DHCircle alloc] initWithCenter:self.center andPointOnRadius:endPoint];
        if (point && point != self.center) {
            _temporaryCircle.pointOnRadius.position = point.position;
            [self.delegate toolTipDidChange:@"Release to create circle"];
        } else {
            _temporaryCircle.pointOnRadius.position = touchPoint;
            _temporaryCircle.temporary = YES;
            [self.delegate toolTipDidChange:@"Drag to a point that the circle will pass through"];
        }
        [self.delegate addTemporaryGeometricObjects:@[_temporaryCircle]];
        [touch.view setNeedsDisplay];
    }
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    if (!_temporaryCircle && self.center) {
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryCircle = [[DHCircle alloc] initWithCenter:self.center andPointOnRadius:endPoint];
        [self.delegate addTemporaryGeometricObjects:@[_temporaryCircle]];
        [touch.view setNeedsDisplay];
    }
    
    if (_temporaryCircle) {
        CGPoint endPoint = touchPoint;
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects, geoViewScale);
        }
        if (!point) {
            _temporaryCircle.pointOnRadius.position = endPoint;
            point = FindPointClosestToCircle(_temporaryCircle, self.delegate.geometryObjects, 8/geoViewScale);
        }
        
        if (point && point != self.center) {
            endPoint = point.position;
            [self.delegate toolTipDidChange:@"Release to create circle"];
            _temporaryCircle.temporary = NO;
        } else {
            [self.delegate toolTipDidChange:@"Drag to a point that the circle will pass through"];
            _temporaryCircle.temporary = YES;
        }
        _temporaryCircle.pointOnRadius.position = endPoint;
        [touch.view setNeedsDisplay];
    }
}
- (void)touchEnded:(UITouch*)touch
{
    // Do nothing if no start point
    if (!self.center) {
        return;
    }
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:3];
    
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    if (_temporaryCircle) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCircle]];
        _temporaryCircle = nil;
        [self.delegate toolTipDidChange:@"Tap on a second point that the circle will pass through"];
        [touch.view setNeedsDisplay];
    }
    if (_temporaryCenter) {
        [objectsToAdd addObject:_temporaryCenter];
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCenter]];
        _temporaryCenter = nil;
        [touch.view setNeedsDisplay];
    }
    
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
    // Prefer normal point selection above automatic intersection
    if (!point) {
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        if (intersectionPoint && !CGPointEqualToPoint(intersectionPoint.position, self.center.position)) {
            point = intersectionPoint;
            [objectsToAdd addObject:intersectionPoint];
        }
    }
    // If still no point, see if there is a point close to the circle and snap to it
    if (!point) {
        DHCircle* tempCircle = [[DHCircle alloc] init];
        tempCircle.center = self.center;
        tempCircle.pointOnRadius = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        point = FindPointClosestToCircle(tempCircle, self.delegate.geometryObjects, 8/geoViewScale);
    }
    
    if(!point && DistanceBetweenPoints(_touchPointInViewStart, touchPointInView) > kClosestTapLimit) {
        [self reset];
    }
    
    if (self.center && point && point != self.center) {
        DHCircle* circle = [[DHCircle alloc] init];
        circle.center = self.center;
        circle.pointOnRadius = point;
        
        [objectsToAdd addObject:circle];
        
        self.center.highlighted = false;
        self.center = nil;
        
        [self.delegate addGeometricObjects:objectsToAdd];
        [objectsToAdd removeAllObjects];
        [self.delegate toolTipDidChange:self.initialToolTip];
    }
    if (objectsToAdd.count > 0) {
        [self.delegate addGeometricObjects:objectsToAdd];
    }
    if (self.center) {
        [self.delegate toolTipDidChange:@"Tap on a second point that the circle will pass through"];
    }
    [touch.view setNeedsDisplay];
}
- (BOOL)active
{
    if (self.center) {
        return YES;
    }
    
    return NO;
}
- (void)reset
{
    if (_temporaryCenter) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCenter]];
        _temporaryCenter = nil;
    }
    if (_temporaryCircle) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCircle]];
        _temporaryCircle = nil;
    }
    
    self.center.highlighted = NO;
    self.center = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)dealloc
{
    if (_temporaryCenter) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCenter]];
        _temporaryCenter = nil;
    }
    if (_temporaryCircle) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryCircle]];
        _temporaryCircle = nil;
    }

    self.center.highlighted = NO;
    [self.delegate toolTipDidChange:self.initialToolTip];
}
@end


@implementation DHMidPointTool {
    CGPoint _touchPointInViewStart;
    DHPoint* _temporaryInitialStartingPoint;
    DHMidPoint* _temporaryMidPoint;
    DHLineSegment* _temporarySegment;
    NSString* _temporaryTooltipUnfinished;
    NSString* _temporaryTooltipFinished;
    NSString* _partialTooltip;
}
- (id)init
{
    self = [super init];
    if (self) {
        _temporaryTooltipUnfinished = @"Drag to a second point between which to create the midpoint";
        _temporaryTooltipFinished = @"Release to create midpoint";
        _partialTooltip = @"Tap on a second point, between which to create the midpoint";
    }
    return self;
}
- (NSString*)initialToolTip
{
    return @"Tap a line segment or two points two create a midpoint";
}
- (void)touchBegan:(UITouch*)touch
{
    _touchPointInViewStart = [touch locationInView:touch.view];
    
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
    if (!point) {
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        if (intersectionPoint) {
            if (!self.startPoint) _temporaryInitialStartingPoint = intersectionPoint;
            point = intersectionPoint;
        }
    }
    
    if (!self.startPoint && point) {
        // If no current starting point but a point was found, use that as a temporary starting point
        self.startPoint = point;
        point.highlighted = true;
        [self.delegate toolTipDidChange:_temporaryTooltipUnfinished];
        
        if (_temporaryInitialStartingPoint) {
            [self.delegate addTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        }
        [touch.view setNeedsDisplay];
    } else if (self.startPoint) {
        // If there already is a startpoint use current point/touch point as temporary end point
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryMidPoint = [[DHMidPoint alloc] initWithPoint1:self.startPoint andPoint2:endPoint];
        if (point && point != self.startPoint) {
            _temporaryMidPoint.end.position = point.position;
            [self.delegate toolTipDidChange:_temporaryTooltipFinished];
        } else {
            _temporaryMidPoint.end.position = touchPoint;
            //_temporaryMidPoint.temporary = YES;
            [self.delegate toolTipDidChange:_temporaryTooltipUnfinished];
        }
        [self.delegate addTemporaryGeometricObjects:@[_temporaryMidPoint]];
        [touch.view setNeedsDisplay];
    } else if (!self.startPoint && !point) {
        // If no starting point and no point was close, check if a line segment was tapped
        DHLineSegment* segment = FindLineSegmentClosestToPoint(touchPoint, self.delegate.geometryObjects,
                                                            kClosestTapLimit / geoViewScale);
        if (segment) {
            _temporarySegment = segment;
            segment.highlighted = YES;
            _temporaryMidPoint = [[DHMidPoint alloc] initWithPoint1:segment.start andPoint2:segment.end];
            [self.delegate addTemporaryGeometricObjects:@[_temporaryMidPoint]];
            [self.delegate toolTipDidChange:_temporaryTooltipFinished];
            [touch.view setNeedsDisplay];
        }
    }
}
- (void)touchMoved:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    if (_temporarySegment) {
        if (DistanceFromPositionToLine(touchPoint, _temporarySegment) > kClosestTapLimit / geoViewScale) {
            [self reset];
            [touch.view setNeedsDisplay];
        }
        return;
    }
    
    if (!_temporaryMidPoint && self.startPoint) {
        DHPoint* endPoint = [[DHPoint alloc] initWithPositionX:touchPoint.x andY:touchPoint.y];
        _temporaryMidPoint = [[DHMidPoint alloc] initWithPoint1:self.startPoint andPoint2:endPoint];
        [self.delegate addTemporaryGeometricObjects:@[_temporaryMidPoint]];
        [touch.view setNeedsDisplay];
    }
    
    if (_temporaryMidPoint) {
        CGPoint endPoint = touchPoint;
        DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects, geoViewScale);
        }
        
        if (point && point != self.startPoint) {
            endPoint = point.position;
            [self.delegate toolTipDidChange:_temporaryTooltipFinished];
            //_temporaryMidPoint.temporary = NO;
        } else {
            [self.delegate toolTipDidChange:_temporaryTooltipUnfinished];
            //_temporaryMidPoint.temporary = YES;
        }
        _temporaryMidPoint.end.position = endPoint;
        [touch.view setNeedsDisplay];
    }
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    // If we already have  a temporary segment defining the midpoint, use that end exit early
    if (_temporarySegment) {
        DHMidPoint* midPoint = [[DHMidPoint alloc] initWithPoint1:_temporarySegment.start
                                                        andPoint2:_temporarySegment.end];
        [self.delegate addGeometricObjects:@[midPoint]];
        [self reset];
        return;
    }
    
    // Do nothing if no start point
    if (!self.startPoint) {
        return;
    }
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:3];
    
    if (_temporaryMidPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryMidPoint]];
        _temporaryMidPoint = nil;
        [self.delegate toolTipDidChange:_partialTooltip];
        [touch.view setNeedsDisplay];
    }
    if (_temporaryInitialStartingPoint) {
        [objectsToAdd addObject:_temporaryInitialStartingPoint];
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        _temporaryInitialStartingPoint = nil;
        [touch.view setNeedsDisplay];
    }
    
    DHPoint* point = FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
    // Prefer normal point selection above automatic intersection
    if (!point) {
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        if (intersectionPoint && !CGPointEqualToPoint(intersectionPoint.position, self.startPoint.position)) {
            point = intersectionPoint;
            [objectsToAdd addObject:intersectionPoint];
        }
    }
    
    if(!point && DistanceBetweenPoints(_touchPointInViewStart, touchPointInView) > kClosestTapLimit) {
        [self reset];
    }
    
    if (self.startPoint && point && point != self.startPoint) {
        DHMidPoint* midPoint = [[DHMidPoint alloc] initWithPoint1:self.startPoint andPoint2:point];
        [objectsToAdd addObject:midPoint];
        
        self.startPoint.highlighted = false;
        self.startPoint = nil;
        
        [self.delegate addGeometricObjects:objectsToAdd];
        [objectsToAdd removeAllObjects];
        [self.delegate toolTipDidChange:self.initialToolTip];
    }
    if (objectsToAdd.count > 0) {
        [self.delegate addGeometricObjects:objectsToAdd];
    }
    if (self.startPoint) {
        [self.delegate toolTipDidChange:_partialTooltip];
    }
    [touch.view setNeedsDisplay];
}
- (BOOL)active
{
    if (self.startPoint) {
        return YES;
    }
    return NO;
}

- (void)reset {
    if (_temporaryMidPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryMidPoint]];
        _temporaryMidPoint = nil;
    }
    if (_temporaryInitialStartingPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        _temporaryInitialStartingPoint = nil;
    }

    _temporarySegment.highlighted = NO;
    _temporarySegment = nil;
    
    self.startPoint.highlighted = NO;
    self.startPoint = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];

    self.associatedTouch = 0;
}
- (void)dealloc
{
    _temporarySegment.highlighted = NO;
    _temporarySegment = nil;
    
    if (_temporaryMidPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryMidPoint]];
        _temporaryMidPoint = nil;
    }
    if (_temporaryInitialStartingPoint) {
        [self.delegate removeTemporaryGeometricObjects:@[_temporaryInitialStartingPoint]];
        _temporaryInitialStartingPoint = nil;
    }
    if (self.startPoint) {
        self.startPoint.highlighted = false;
    }
}
@end


@implementation DHPerpendicularTool
- (NSString*)initialToolTip
{
    return @"Tap a line you wish to make a line perpendicular to";
}
- (void)touchBegan:(UITouch*)touch
{
    
}
- (void)touchMoved:(UITouch*)touch
{
    
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];

    if (self.line == nil) {
        DHLineObject* line = FindLineClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (line) {
            self.line = line;
            line.highlighted = true;
            [self.delegate toolTipDidChange:@"Tap on a point through which the perpendicular line should pass"];
            [touch.view setNeedsDisplay];
        }
    } else {
        
        DHPoint* point= FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        //prefers normal point selection above automatic intersection
        if (intersectionPoint && !(point)) {
            [self.delegate addGeometricObject:intersectionPoint];
            point = intersectionPoint;
        }
        
        
        if (point) {
            DHPerpendicularLine* perpLine = [[DHPerpendicularLine alloc] init];
            perpLine.line = self.line;
            perpLine.point = point;
            [self.delegate addGeometricObject:perpLine];
            
            self.line.highlighted = false;
            self.line = nil;
            [self.delegate toolTipDidChange:self.initialToolTip];
        }
    }
}
- (BOOL)active
{
    if (self.line) {
        return YES;
    }
    
    return NO;
}
- (void)reset
{
    self.line.highlighted = NO;
    self.line = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)dealloc
{
    if (self.line) {
        self.line.highlighted = NO;
    }
}
@end


@implementation DHParallelTool
- (NSString*)initialToolTip
{
    return @"Tap a line you wish to make a line parallel to";
}
- (void)touchBegan:(UITouch*)touch
{
    
}
- (void)touchMoved:(UITouch*)touch
{
    
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];

    if (self.line == nil) {
        DHLineObject* line = FindLineClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        if (line) {
            self.line = line;
            line.highlighted = true;
            [self.delegate toolTipDidChange:@"Tap on a point through which the parallel line should pass"];
            [touch.view setNeedsDisplay];
        }
    } else {
        
        DHPoint* point= FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        //prefers normal point selection above automatic intersection
        if (intersectionPoint && !(point)) {
            [self.delegate addGeometricObject:intersectionPoint];
            point = intersectionPoint;
        }
        
        
        if (point) {
            DHParallelLine* paraLine = [[DHParallelLine alloc] init];
            paraLine.line = self.line;
            paraLine.point = point;
            [self.delegate addGeometricObject:paraLine];
            
            self.line.highlighted = false;
            self.line = nil;
            [self.delegate toolTipDidChange:self.initialToolTip];
        }
    }
}
- (BOOL)active
{
    if (self.line) {
        return YES;
    }
    
    return NO;
}
- (void)reset
{
    self.line.highlighted = NO;
    self.line = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)dealloc
{
    if (self.line) {
        self.line.highlighted = false;
    }
}
@end


@implementation DHTranslateSegmentTool
- (NSString*)initialToolTip
{
    return @"Tap two points or a line segment you wish to translate";
}
- (void)touchBegan:(UITouch*)touch
{
    
}
- (void)touchMoved:(UITouch*)touch
{
    
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    const CGFloat tapLimitInGeo = kClosestTapLimit / geoViewScale;

    if (self.start == nil || self.end == nil) {
        DHPoint* point= FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, tapLimitInGeo);
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        // Prefers normal point selection above automatic intersection
        if (intersectionPoint && !(point)) {
            [self.delegate addGeometricObject:intersectionPoint];
            point = intersectionPoint;
        }
        if (point && self.start == nil) {
            self.start = point;
            self.start.highlighted = YES;
            [self.delegate toolTipDidChange:@"Tap on a second point to define the line segment to be translated"];
            [touch.view setNeedsDisplay];
            return;
        }
        if (point && self.end == nil) {
            self.end = point;
            self.end.highlighted = YES;
            [self.delegate toolTipDidChange:@"Tap on a point to define the starting point of the translated segment"];
            [touch.view setNeedsDisplay];
            return;
        }
        
        DHLineSegment* line = FindLineSegmentClosestToPoint(touchPoint, self.delegate.geometryObjects, tapLimitInGeo);
        if (line) {
            self.segment = line;
            self.start = line.start;
            self.end = line.end;
            self.segment.highlighted = YES;
            [self.delegate toolTipDidChange:@"Tap on a point that should be the starting point of the translated segment"];
            [touch.view setNeedsDisplay];
            return;
        }
    } else {
        DHPoint* point= FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, tapLimitInGeo);
        DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
        // Prefers normal point selection above automatic intersection
        if (intersectionPoint && !(point)) {
            [self.delegate addGeometricObject:intersectionPoint];
            point = intersectionPoint;
        }
        
        if (point == nil) {
            return;
        }
        
        if (self.disableWhenOnSameLine) {
            // Check if point is on line and then do nothing
            CGVector vLineDir = CGVectorBetweenPoints(self.start.position, self.end.position);
            CGVector vLineStartToPoint = CGVectorBetweenPoints(self.start.position, point.position);
            CGFloat angle = CGVectorAngleBetween(vLineDir, vLineStartToPoint);
            if (fabs(angle) < 0.001 || fabs(angle - M_PI) < 0.001) {
                [self.delegate showTemporaryMessage:@"Not allowed, point lies on same line as segment"
                                            atPoint:touchPointInView withColor:[UIColor redColor]];
                return;
            }
        }
        
        DHTranslatedPoint* translatedPoint = [[DHTranslatedPoint alloc] init];
        translatedPoint.startOfTranslation = point;
        translatedPoint.translationStart = self.start;
        translatedPoint.translationEnd = self.end;
        
        DHLineSegment* transLine = [[DHLineSegment alloc] initWithStart:point andEnd:translatedPoint];
        [self.delegate addGeometricObjects:@[translatedPoint, transLine]];
        
        self.segment.highlighted = NO;
        self.start.highlighted = NO;
        self.end.highlighted = NO;
        self.start = nil;
        self.end = nil;
        self.segment = nil;
        [self.delegate toolTipDidChange:self.initialToolTip];
    }
}
- (BOOL)active
{
    if (self.segment || self.start || self.end) {
        return YES;
    }
    
    return NO;
}
- (void)reset
{
    self.segment.highlighted = NO;
    self.start.highlighted = NO;
    self.end.highlighted = NO;
    self.segment = nil;
    self.start = nil;
    self.end = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)dealloc
{
    self.segment.highlighted = NO;
    self.start.highlighted = NO;
    self.end.highlighted = NO;
}
@end


@implementation DHCompassTool
- (NSString*)initialToolTip
{
    return @"Tap two points or a line segment to define the radius, followed by a third point to mark the center";
}
- (void)touchBegan:(UITouch*)touch
{
    
}
- (void)touchMoved:(UITouch*)touch
{
    
}
- (void)touchEnded:(UITouch*)touch
{
    CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];

    DHPoint* point= FindPointClosestToPoint(touchPoint, self.delegate.geometryObjects, kClosestTapLimit / geoViewScale);
    DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
    //prefers normal point selection above automatic intersection
    if (intersectionPoint && !(point)) {
        [self.delegate addGeometricObject:intersectionPoint];
        point = intersectionPoint;
    }
    
    
    if (point) {
        if (self.firstPoint) {
            if (self.secondPoint) {
                DHTranslatedPoint* pointOnRadius = [[DHTranslatedPoint alloc] init];
                pointOnRadius.startOfTranslation = point;
                pointOnRadius.translationStart = self.firstPoint;
                pointOnRadius.translationEnd = self.secondPoint;
                
                DHCircle* circle = [[DHCircle alloc] init];
                circle.center = point;
                circle.pointOnRadius = pointOnRadius;
                
                self.firstPoint.highlighted = false;
                self.firstPoint = nil;
                self.secondPoint.highlighted = false;
                self.secondPoint = nil;
                self.radiusSegment.highlighted = false;
                self.radiusSegment = nil;
                
                [self.delegate addGeometricObject:circle];
                [self.delegate toolTipDidChange:self.initialToolTip];
            } else if (point != self.firstPoint) {
                self.secondPoint = point;
                point.highlighted = true;
                [self.delegate toolTipDidChange:@"Tap on a third point to mark the center of the circle"];
                [touch.view setNeedsDisplay];
            }
        } else {
            self.firstPoint = point;
            point.highlighted = true;
            [self.delegate toolTipDidChange:@"Tap on a second point to mark the radius of the circle"];
            [touch.view setNeedsDisplay];
        }
    } else if (self.firstPoint == nil) {
        DHLineSegment* segment = FindLineSegmentClosestToPoint(touchPoint, self.delegate.geometryObjects,
                                                               kClosestTapLimit / geoViewScale);
        if (segment) {
            self.firstPoint = segment.start;
            self.secondPoint = segment.end;
            self.radiusSegment = segment;
            segment.highlighted = true;
            [self.delegate toolTipDidChange:@"Tap on a point to mark the center of the circle"];
            [touch.view setNeedsDisplay];
        }
    }
}
- (BOOL)active
{
    if (self.firstPoint || self.secondPoint || self.radiusSegment) {
        return YES;
    }
    
    return false;
}
- (void)reset
{
    self.firstPoint.highlighted = NO;
    self.secondPoint.highlighted = NO;
    self.radiusSegment.highlighted = NO;
    self.firstPoint = nil;
    self.secondPoint = nil;
    self.radiusSegment = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)dealloc
{
    if (self.firstPoint) {
        self.firstPoint.highlighted = false;
    }
    if (self.secondPoint) {
        self.secondPoint.highlighted = false;
    }
    if (self.radiusSegment) {
        self.radiusSegment.highlighted = false;
    }
}
@end
