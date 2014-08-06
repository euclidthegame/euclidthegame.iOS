//
//  DHCompassTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

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
    NSArray* geoObjects = self.delegate.geometryObjects;
    
    DHPoint* point= FindPointClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
    DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects, geoViewScale);
    
    // Prefers normal point selection above automatic intersection
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
                
                DHCircle* circle = [[DHCircle alloc] initWithCenter:point andPointOnRadius:pointOnRadius];
                [self.delegate addGeometricObject:circle];
                
                [self reset];
            } else if (point != self.firstPoint) {
                self.secondPoint = point;
                point.highlighted = YES;
                [self.delegate toolTipDidChange:@"Tap on a third point to mark the center of the circle"];
                [touch.view setNeedsDisplay];
            }
        } else {
            self.firstPoint = point;
            point.highlighted = YES;
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
            segment.highlighted = YES;
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
    
    return NO;
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
    self.firstPoint.highlighted = NO;
    self.secondPoint.highlighted = NO;
    self.radiusSegment.highlighted = NO;
}
@end
