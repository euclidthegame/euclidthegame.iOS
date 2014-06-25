//
//  DHViewController.m
//  Principia
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometryViewController.h"
#import "DHGeometryView.h"
#import "DHGeometricTools.h"
#import "DHMath.h"

@interface DHGeometryViewController () {
    NSMutableArray* _geometricObjects;
    DHLineTool* _lineTool;
    DHCircleTool* _circleTool;
    DHMoveTool* _moveTool;
}

@end

@implementation DHGeometryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _geometricObjects = [[NSMutableArray alloc] init];
    ((DHGeometryView*)self.view).geometricObjects = _geometricObjects;
    
    _lineTool = [[DHLineTool alloc] init];
    _circleTool = [[DHCircleTool alloc] init];
    _moveTool = [[DHMoveTool alloc] init];
    
    [_toolControl addTarget:self
                         action:@selector(toolChanged:)
               forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    DHGeometryView* view = (DHGeometryView*)self.view;
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:view];
    
    if (self.toolControl.selectedSegmentIndex == 4) {
        DHPoint* point = [self findPointClosestToPoint:touchPoint];
        if (point) {
            _moveTool.point = point;
            _moveTool.touchStart = touchPoint;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    DHGeometryView* view = (DHGeometryView*)self.view;
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:view];
    
    if (self.toolControl.selectedSegmentIndex == 4) {
        if (_moveTool.point) {
            CGPoint previousPosition = _moveTool.point.position;
            previousPosition.x = previousPosition.x + touchPoint.x - _moveTool.touchStart.x;
            previousPosition.y = previousPosition.y + touchPoint.y - _moveTool.touchStart.y;
            _moveTool.point.position = previousPosition;
            _moveTool.touchStart = touchPoint;
            [view setNeedsDisplay];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    DHGeometryView* view = (DHGeometryView*)self.view;
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:view];
    
    // Point
    if (self.toolControl.selectedSegmentIndex == 0) {
        DHPoint* point = [[DHPoint alloc] init];
        point.position = touchPoint;
        
        [_geometricObjects addObject:point];
        [view setNeedsDisplay];
    }

    // Line
    if (self.toolControl.selectedSegmentIndex == 1) {
        DHPoint* point = [self findPointClosestToPoint:touchPoint];
        if (point) {
            if (_lineTool.startPoint) {
                DHLine* line = [[DHLine alloc] init];
                line.start = _lineTool.startPoint;
                line.end = point;
                
                [_geometricObjects addObject:line];
                _lineTool.startPoint.highlighted = false;
                _lineTool.startPoint = nil;
                [view setNeedsDisplay];
            } else {
                _lineTool.startPoint = point;
                point.highlighted = true;
                [view setNeedsDisplay];
            }
        }
    }

    // Circle
    if (self.toolControl.selectedSegmentIndex == 2) {
        DHPoint* point = [self findPointClosestToPoint:touchPoint];
        if (point) {
            if (_circleTool.center) {
                DHCircle* circle = [[DHCircle alloc] init];
                circle.center = _circleTool.center;
                circle.pointOnRadius = point;
                
                [_geometricObjects addObject:circle];
                _circleTool.center.highlighted = false;
                _circleTool.center = nil;
                [view setNeedsDisplay];
            } else {
                _circleTool.center = point;
                point.highlighted = true;
                [view setNeedsDisplay];
            }
        }
    }
    
    // Intersect
    if (self.toolControl.selectedSegmentIndex == 3) {
        NSArray* nearObjects = [self findIntersectablesNearPoint:touchPoint];

        for (int index1 = 0; index1 < nearObjects.count-1; ++index1) {
            for (int index2 = index1+1; index2 < nearObjects.count; ++index2) {
                id object1 = [nearObjects objectAtIndex:index1];
                id object2 = [nearObjects objectAtIndex:index2];
                
                // Circle/circle intersection
                if ([[object1 class] isSubclassOfClass:[DHCircle class]] &&
                    [[object2 class] isSubclassOfClass:[DHCircle class]]) {
                    DHCircle* c1 = object1;
                    DHCircle* c2 = object2;
                    
                    if (DoCirclesIntersect(c1, c2)) {
                        DHIntersectionPointCircleCircle* iPoint = [[DHIntersectionPointCircleCircle alloc] init];
                        iPoint.c1 = c1;
                        iPoint.c2 = c2;
                        
                        // Check if above or below line
                        CGFloat m = (c1.center.position.y - c2.center.position.y)/(c1.center.position.x - c2.center.position.x);
                        if (touchPoint.y > m*touchPoint.x + (c1.center.position.y - m*c1.center.position.x)) {
                            iPoint.onPositiveY = false;
                        } else {
                            iPoint.onPositiveY = true;
                        }
                        
                        [_geometricObjects addObject:iPoint];
                        [view setNeedsDisplay];
                    }
                }

                // Line/line intersection
                if ([[object1 class] isSubclassOfClass:[DHLine class]] &&
                    [[object2 class] isSubclassOfClass:[DHLine class]]) {
                    DHLine* l1 = object1;
                    DHLine* l2 = object2;
                    
                    if (DoLinesIntersect(l1, l2)) {
                        DHIntersectionPointLineLine* iPoint = [[DHIntersectionPointLineLine alloc] init];
                        iPoint.l1 = l1;
                        iPoint.l2 = l2;

                        [_geometricObjects addObject:iPoint];
                        [view setNeedsDisplay];
                    }
                }
                
                // Line/circle intersection
                if ([[object1 class] isSubclassOfClass:[DHLine class]] &&
                    [[object2 class] isSubclassOfClass:[DHCircle class]]) {
                    DHLine* l = object1;
                    DHCircle* c = object2;
                    
                    DHIntersectionResult result = DoLineAndCircleIntersect(l, c);
                    if (result.intersect) {
                        DHIntersectionPointLineCircle* iPoint = [[DHIntersectionPointLineCircle alloc] init];
                        iPoint.l = l;
                        iPoint.c = c;
                        
                        [_geometricObjects addObject:iPoint];
                        [view setNeedsDisplay];
                    }
                }
                if ([[object1 class] isSubclassOfClass:[DHCircle class]] &&
                    [[object2 class] isSubclassOfClass:[DHLine class]]) {
                    DHCircle* c = object1;
                    DHLine* l = object2;
                    
                    DHIntersectionResult result = DoLineAndCircleIntersect(l, c);
                    if (result.intersect) {
                        DHIntersectionPointLineCircle* iPoint = [[DHIntersectionPointLineCircle alloc] init];
                        iPoint.l = l;
                        iPoint.c = c;
                        
                        [_geometricObjects addObject:iPoint];
                        [view setNeedsDisplay];
                    }
                }
            }
        }
    }
}

- (DHPoint*)findPointClosestToPoint:(CGPoint)point
{
    DHPoint* closestPoint = nil;
    CGFloat closestPointDistance = 30.0f;
    
    for (id object in _geometricObjects) {
        if ([[object class] isSubclassOfClass:[DHPoint class]]) {
            CGPoint currentPoint = [object position];
            CGFloat distance = DistanceBetweenPoints(point, currentPoint);
            
            if (distance < closestPointDistance) {
                closestPoint = object;
                closestPointDistance = distance;
            }
        }
    }
    
    return closestPoint;
}

- (NSArray*)findIntersectablesNearPoint:(CGPoint)point
{
    const CGFloat maxDistanceLimit = 30.0f;
    NSMutableArray* foundObjects = [[NSMutableArray alloc] init];
    DHPoint *dhPoint = [[DHPoint alloc] init];
    dhPoint.position = point;
    
    for (id object in _geometricObjects) {
        if ([object class] == [DHCircle class]) {
            DHCircle* circle = (DHCircle*)object;
            CGFloat distanceToCenter = DistanceBetweenPoints(point, circle.center.position);
            CGFloat distanceToCircle = distanceToCenter - circle.radius;
            if (distanceToCircle <= maxDistanceLimit) {
                [foundObjects addObject:circle];
            }
        }
        if ([object class] == [DHLine class]) {
            DHLine* line = (DHLine*)object;
            CGFloat distanceToLine = DistanceFromPointToLine(dhPoint, line);
            if (distanceToLine <= maxDistanceLimit) {
                [foundObjects addObject:line];
            }
        }
    }
    
    return foundObjects;
}

- (IBAction)resetGeometricObject:(id)sender
{
    [_geometricObjects removeAllObjects];
    [self.view setNeedsDisplay];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)toolChanged:(id)sender
{
    NSLog(@"Changed tool");
}

@end
