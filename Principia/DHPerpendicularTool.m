//
//  DHPerpendicularTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHPerpendicularTool {
    DHPerpendicularLine* _tempPerpLine;
    DHPoint* _tempPoint;
}
- (NSString*)initialToolTip
{
    return @"Tap a line you wish to make a line perpendicular to";
}
- (void)touchBegan:(UITouch*)touch
{
    /*CGPoint touchPointInView = [touch locationInView:touch.view];
    CGPoint touchPoint = [[self.delegate geoViewTransform] viewToGeo:touchPointInView];
    CGFloat geoViewScale = [[self.delegate geoViewTransform] scale];
    
    if (self.line == nil) {
    }*/
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
    self.line.highlighted = NO;
}
@end