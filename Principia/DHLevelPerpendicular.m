//
//  DHLevel6.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-02.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelPerpendicular.h"
#import <CoreGraphics/CGBase.h>
#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@interface DHLevelPerpendicular () {
    DHPoint* _pointA;
    DHPoint* _pointHidden1;
    DHPoint* _pointHidden2;
    DHLine* _lineBC;
    BOOL _step1finished;
    BOOL pointOnLineOK;
}

@end

@implementation DHLevelPerpendicular

- (NSString*)levelDescription
{
    return @"Construct a line on A that is perpendicular to the given line.";
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct a line (segment) on A that is perpendicular to the given line. \n \nWhen a straight line standing on a straight line makes the adjacent angles equal to one another, each of the equal angles is right, and the straight line standing on the other is called a perpendicular to that on which it stands.");
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable_Weak |
            DHBisectToolAvailable);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 3;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 3;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:200 andY:300];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:500 andY:300];
    
    DHLine* l1 = [[DHLine alloc] init];
    l1.start = p2;
    l1.end = p3;

    DHPointOnLine* p1 = [[DHPointOnLine alloc] init];
    p1.line = l1;
    p1.tValue = 0.75;
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    
    _pointA = p1;
    _lineBC = l1;
    _pointHidden1 = p2;
    _pointHidden2 = p3;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHPoint* p = [[DHPoint alloc] initWithPositionX:500 andY:200];
    DHCircle* c = [[DHCircle alloc] initWithCenter:p andPointOnRadius:_pointA];
    DHIntersectionPointLineCircle* ip1 = [[DHIntersectionPointLineCircle alloc] init];
    ip1.c = c;
    ip1.l = _lineBC;
    ip1.preferEnd = NO;
    DHLine* l1 = [[DHLine alloc] initWithStart:ip1 andEnd:p];
    DHIntersectionPointLineCircle* ip2 = [[DHIntersectionPointLineCircle alloc] init];
    ip2.c = c;
    ip2.l = l1;
    ip2.preferEnd = YES;
    
    
    DHRay* r = [[DHRay alloc] init];
    r.start = _pointA;
    r.end = ip2;
    
    [objects insertObject:r atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }

    // Move B and C and ensure solution holds    
    CGPoint pointB = _lineBC.start.position;
    CGPoint pointC = _lineBC.end.position;
    
    _lineBC.start.position = CGPointMake(100, 100);
    _lineBC.end.position = CGPointMake(400, 400);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];

    _lineBC.start.position = pointB;
    _lineBC.end.position = pointC;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    pointOnLineOK = NO;
    BOOL pointOnPerpLineOK = NO;
    self.progress = 0;
    DHPerpendicularLine* pl = [[DHPerpendicularLine alloc] initWithLine:_lineBC andPoint:_pointA];
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if (object == _pointA) continue;
        
        if ([object class] == [DHPointOnLine class]) {
            DHPointOnLine* p = object;
            if (PointOnLine(p, _lineBC) ) {
                pointOnLineOK = YES;
            }
        }
        if ([[object class]  isSubclassOfClass:[DHPoint class]] && [object class] != [DHPoint class]) {
            CGFloat dist = DistanceFromPointToLine(object, pl);
            if (dist < 0.001) {
                pointOnPerpLineOK = YES;
            }
        }
        
        if ([[object class]  isSubclassOfClass:[DHLineObject class]]) {
            DHLineObject* l = object;
            CGFloat distAL = DistanceFromPointToLine(_pointA, l);
            CGVector bc = CGVectorNormalize(_lineBC.vector);
            
            CGFloat lDotBC = CGVectorDotProduct(CGVectorNormalize(l.vector), bc);
            if (distAL < 0.001 && fabs(lDotBC) < 0.001) {
                self.progress = 100;
                return YES;
            }
        }
    }
    
    self.progress = (pointOnPerpLineOK * 50);
    
    return NO;
}

- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    DHPerpendicularLine* perp = [[DHPerpendicularLine alloc] init];
    perp.line = _lineBC;
    perp.point = _pointA;
    
    for (id object in objects){
        
        if ([object class] == [DHCircle class])
        {
            DHCircle* c = object;
            if (EqualPoints(c.center,_pointA)) return c.center.position;
        }
        if ([object class] == [DHIntersectionPointLineCircle class])
        {
            DHPoint* p = object;
            if (PointOnLine(p,_lineBC)) return p.position;
        }
        if (PointOnLine(object,perp)){ DHPoint* p = object; return p.position; }
        if (EqualDirection(object,perp) && PointOnLine(_pointA, object))  return _pointA.position;
        
    }
    return CGPointMake(NAN, NAN);
}

- (void)showHint
{
    DHGeometryView* geometryView = self.levelViewController.geometryView;
    
    if (self.showingHint) {
        [self hideHint];
        return;
    }
    
    self.showingHint = YES;
    
    [self slideOutToolbar];
    
    [self afterDelay:1.0 :^{
        if (!self.showingHint) return;
        
        UIView* hintView = [[UIView alloc]initWithFrame:geometryView.frame];
        hintView.backgroundColor = [UIColor whiteColor];
        
        DHGeometryView* oldObjects = [[DHGeometryView alloc] initWithObjects:geometryView.geometricObjects supView:geometryView addTo:hintView];
        oldObjects.hideBorder = NO;
        [oldObjects.layer setValue:[NSNumber numberWithFloat:1.0] forKeyPath:@"opacity"];
        [hintView addSubview:oldObjects];
        
        [geometryView addSubview:hintView];
        
        DHPointOnLine* p1 = [[DHPointOnLine alloc] initWithLine:_lineBC andTValue:0.75-0.3];
        p1.temporary = YES;
        DHPointOnLine* p2 = [[DHPointOnLine alloc] initWithLine:_lineBC andTValue:0.75+0.3];
        p2.temporary = YES;
        DHTrianglePoint* p3 = [[DHTrianglePoint alloc] initWithPoint1:p1 andPoint2:p2];
        p3.temporary = YES;
        
        DHGeometryView* p12View = [[DHGeometryView alloc] initWithObjects:@[p1, p2]
                                                                 supView:geometryView addTo:hintView];
        DHGeometryView* p3View = [[DHGeometryView alloc] initWithObjects:@[p3]
                                                                 supView:geometryView addTo:hintView];
        
        Message* message1 = [self createMiddleMessageWithSuperView:hintView];
        
        [self afterDelay:0.0:^{
            [message1 text:@"You have already constructed a midpoint, in level 2."];
            [self fadeInViews:@[message1] withDuration:2.0];
        }];
        
        [self afterDelay:3.0 :^{
            [message1 appendLine:(@"Can you think of a way to construct a two points such that, point A is always "
                                  @"at their midpoint?")
                    withDuration:2.0];
            [self fadeInViews:@[p12View] withDuration:2.0];
        }];

        [self afterDelay:6.0 :^{
            [message1 appendLine:(@"If so, use them similarly to create a point straight above A.")
                    withDuration:2.0];
            [self fadeInViews:@[p3View] withDuration:2.0];
        }];
        
        [self afterDelay:2.0 :^{
            [self showEndHintMessageInView:hintView];
        }];
        
    }];
}

@end
