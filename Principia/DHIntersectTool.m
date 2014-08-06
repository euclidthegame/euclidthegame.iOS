//
//  DHIntersectTool.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricTools.h"
#import "DHMath.h"

@implementation DHIntersectTool
- (NSString*)initialToolTip
{
    return @"Tap on any intersection between two lines/circles to add a new point";
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
    DHPoint* intersectionPoint = FindClosestUniqueIntersectionPoint(touchPoint, self.delegate.geometryObjects,geoViewScale);
    if (intersectionPoint) {
        [self.delegate addGeometricObject:intersectionPoint];
    }
}
- (BOOL)active
{
    return false;
}
- (void)reset
{
    self.associatedTouch = 0;
}

@end
