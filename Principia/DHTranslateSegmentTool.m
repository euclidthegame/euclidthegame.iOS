//
//  DHTranslateSegmentTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

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


