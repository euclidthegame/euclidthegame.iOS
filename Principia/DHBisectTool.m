//
//  DHBisectTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHBisectTool
- (NSString*)initialToolTip
{
    return @"Tap two lines, rays or line segments (or three points) that define an angle to create its bisector";
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
    NSMutableArray* objectsToAdd = [[NSMutableArray alloc] initWithCapacity:3];
    
    // If no first point has been tapped, look for closest line or point
    if (self.firstPoint == nil) {
        DHLineObject* line = FindLineClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        
        if (point && self.firstLine == nil) {
            self.firstPoint = point;
            point.highlighted = true;
            [self.delegate toolTipDidChange:@"Tap on a second point to mark the corner of the angle"];
            [touch.view setNeedsDisplay];
        } else if (line) {
            if (self.firstLine && line != self.firstLine) {
                // Ensure the lines intersect
                DHIntersectionResult r = IntersectionTestLineLine(self.firstLine, line);
                if (r.intersect == NO) {
                    [self.delegate showTemporaryMessage:@"The lines must intersect or be connected to define an angle"
                                                atPoint:touchPointInView withColor:[UIColor redColor]];
                    return;
                }
                
                // Ensure the lines define an angle
                CGFloat angle = CGVectorAngleBetween(self.firstLine.vector, line.vector);
                if (angle < 0.0001 || fabs(angle - M_PI) < 0.001) {
                    [self.delegate showTemporaryMessage:@"The lines can not be parallel to define an angle"
                                                atPoint:touchPointInView withColor:[UIColor redColor]];
                    return;
                }
                
                BOOL createPerpendicular = YES;
                
                if ([_firstLine isKindOfClass:[DHLineSegment class]] &&
                    [line isKindOfClass:[DHLineSegment class]]) {
                    
                    if (_firstLine.start == line.start || _firstLine.start == line.end ||
                        _firstLine.end == line.start || _firstLine.end == line.end)
                    {
                        createPerpendicular = NO;
                    }
                }
                
                DHBisectLine* bl = [[DHBisectLine alloc] initWithLine:self.firstLine andLine:line];
                
                if (createPerpendicular) {
                    DHPerpendicularLine* perpLine = [[DHPerpendicularLine alloc] initWithLine:bl andPoint:bl.start];
                    [self.delegate addGeometricObjects:@[bl, perpLine]];
                } else {
                    [self.delegate addGeometricObjects:@[bl]];
                }
                
                self.firstLine.highlighted = false;
                self.firstLine = nil;
                [self.delegate toolTipDidChange:self.initialToolTip];
            } else if (self.firstLine == nil) {
                self.firstLine = line;
                line.highlighted = true;
                [self.delegate toolTipDidChange:@"Tap on a second line intersecting/connect to the first to create the bisector"];
                [touch.view setNeedsDisplay];
            }
        }
    } else {
        DHPoint* point = FindPointClosestToPoint(touchPoint, geoObjects, kClosestTapLimit / geoViewScale);
        if (!point) {
            point = FindClosestUniqueIntersectionPoint(touchPoint, geoObjects, geoViewScale);
            if (point) [objectsToAdd addObject:point];
        }
        if (point) {
            if (point == self.firstPoint || point == self.secondPoint) {
                return;
            }
            if (self.secondPoint == nil) {
                self.secondPoint = point;
                point.highlighted = true;
                [self.delegate toolTipDidChange:@"Tap on a third point to define the angle and create the bisector"];
                [touch.view setNeedsDisplay];
            } else {
                // Ensure the lines define an angle
                CGVector v1 = CGVectorBetweenPoints(self.secondPoint.position, self.firstPoint.position);
                CGVector v2 = CGVectorBetweenPoints(self.secondPoint.position, point.position);
                CGFloat angle = CGVectorAngleBetween(v1, v2);
                if (angle < 0.0001 || fabs(angle - M_PI) < 0.001) {
                    [self.delegate showTemporaryMessage:@"The points can not all lie on a line to define an angle"
                                                atPoint:touchPointInView withColor:[UIColor redColor]];
                    return;
                }
                
                DHBisectLine* bl = [[DHBisectLine alloc] init];
                bl.line1 = [[DHLineSegment alloc] initWithStart:self.secondPoint andEnd:self.firstPoint];
                bl.line2 = [[DHLineSegment alloc] initWithStart:self.secondPoint andEnd:point];
                [objectsToAdd addObjectsFromArray:@[bl]];
                
                //DHPerpendicularLine* perpLine = [[DHPerpendicularLine alloc] initWithLine:bl andPoint:bl.start];
                //[objectsToAdd addObjectsFromArray:@[bl, perpLine]];
                
                [self.delegate addGeometricObjects:objectsToAdd];
                
                [self reset];
            }
        }
    }
}
- (BOOL)active
{
    if (self.firstLine || self.firstPoint || self.secondPoint) {
        return YES;
    }
    return false;
}
- (void)reset
{
    self.firstLine.highlighted = NO;
    self.firstPoint.highlighted = NO;
    self.secondPoint.highlighted = NO;
    self.firstLine = nil;
    self.firstPoint = nil;
    self.secondPoint = nil;
    [self.delegate toolTipDidChange:self.initialToolTip];
    self.associatedTouch = 0;
}
- (void)dealloc
{
    self.firstLine.highlighted = NO;
    self.firstPoint.highlighted = NO;
    self.secondPoint.highlighted = NO;
}
@end
