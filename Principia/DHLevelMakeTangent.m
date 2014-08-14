//
//  DHLevelMakeTangent.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelMakeTangent.h"

#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@interface DHLevelMakeTangent () {
    DHCircle* _circle;
    Message* _message1,*_message2,*_message3;
    BOOL _step1finished;
    BOOL centerOK;
}

@end

@implementation DHLevelMakeTangent

- (NSString*)subTitle
{
    return @"Tangentially related";
}

- (NSString*)levelDescription
{
    return (@"Construct a line (segment) tangent to the given circle");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct a line (segment) tangent to the circle. \n\n"
            @"A tangent line to a circle is a line that only touches the circle at one point.");
}


- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable | DHTranslateToolAvailable |
            DHCompassToolAvailable);
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
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:200 andY:200];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:300 andY:220];
    
    DHCircle* circle = [[DHCircle alloc] init];
    circle.center = pA;
    circle.pointOnRadius = pB;
    
    [geometricObjects addObject:circle];
 
    _circle = circle;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    
    DHLineSegment* r = [[DHLineSegment alloc] initWithStart:_circle.center andEnd:_circle.pointOnRadius];
    DHPerpendicularLine* pl = [[DHPerpendicularLine alloc] initWithLine:r andPoint:r.end];
    
    [objects insertObject:pl atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    DHPoint* pCenter = _circle.center;
    DHPoint* pRadius = _circle.pointOnRadius;
    
    // Move A and B and ensure solution holds
    CGPoint pointA = pCenter.position;
    CGPoint pointB = pRadius.position;
    
    pCenter.position = CGPointMake(pointA.x - 1, pointA.y - 1);
    pRadius.position = CGPointMake(pointB.x + 1, pointB.y + 1);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    pCenter.position = pointA;
    pRadius.position = pointB;
    
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    BOOL tangentOK = NO;
    centerOK = NO;
    
    for (id object in geometricObjects) {
        
        if (EqualPoints(_circle.center, object)){
            centerOK = YES;
            
        }
        if (LineObjectTangentToCircle(object, _circle)) {
            tangentOK = YES;
            break;
        }
    }
    
    if (tangentOK) {
        self.progress = 100;
        return YES;
    }
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects{
    
    
    for (id object in objects){
        if (EqualPoints(_circle.center, object)) {
            [self fadeOut:_message3 withDuration:1.0];
            return _circle.center.position;
        }
    
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
    
    DHGeometryView* hintView = [[DHGeometryView alloc] initWithFrame:geometryView.frame];
    hintView.backgroundColor = [UIColor whiteColor];
    hintView.layer.opacity = 0;
    hintView.hideBottomBorder = YES;
    [geometryView addSubview:hintView];
    [self fadeInViews:@[hintView] withDuration:1.0];
    hintView.geometricObjects = [NSMutableArray arrayWithObject:_circle];
    
    [self afterDelay:1.0 :^{
        if (!self.showingHint) return;
        hintView.frame = geometryView.frame;
        [hintView setNeedsDisplay];
        [self afterDelay:0.5 :^{
            [self showEndHintMessageInView:hintView];
        }];
        
        DHLineSegment* s1 = [[DHLineSegment alloc] initWithStart:_circle.center andEnd:_circle.pointOnRadius];
        s1.temporary = YES;
        DHPerpendicularLine* l1 = [[DHPerpendicularLine alloc] initWithLine:s1 andPoint:_circle.pointOnRadius];
        l1.temporary = YES;
        DHPoint* p1 = [[DHPoint alloc] initWithPosition:_circle.pointOnRadius.position];
        p1.temporary = YES;
        DHAngleIndicator* angle = [[DHAngleIndicator alloc] initWithLine1:l1 line2:s1 andRadius:20];
        angle.label = @"?";
        angle.anglePosition = 2;
        
        DHGeometryView* tangentView = [[DHGeometryView alloc] initWithObjects:@[l1]
                                                                   supView:geometryView addTo:hintView];
        DHGeometryView* radiusView = [[DHGeometryView alloc] initWithObjects:@[angle, s1, _circle.center]
                                                                      supView:geometryView addTo:hintView];
        DHGeometryView* p1View = [[DHGeometryView alloc] initWithObjects:@[p1]
                                                                      supView:geometryView addTo:hintView];
        
        Message* message1 = [[Message alloc] initAtPoint:CGPointMake(80,460) addTo:hintView];
        Message* message2 = [[Message alloc] initAtPoint:CGPointMake(80,480) addTo:hintView];
        Message* message3 = [[Message alloc] initAtPoint:CGPointMake(80,500) addTo:hintView];
        Message* message4 = [[Message alloc] initAtPoint:CGPointMake(80,520) addTo:hintView];
        
        [self afterDelay:0.0:^{
            [message1 text:@"Assume that we already have a tangent to the circle."];
            [self fadeInViews:@[message1, tangentView] withDuration:2.0];
        }];
        [self afterDelay:2.5:^{
            [message2 text:@"By definition, it will only touch the circle at one point."];
            [self fadeInViews:@[message2, p1View] withDuration:2.0];
        }];
        [self afterDelay:5.0:^{
            [message3 text:@"Can you work out what the angle between the tangent and"];
            [self fadeInViews:@[message3] withDuration:2.0];
        }];

        [self afterDelay:6.0:^{
            [self fadeInViews:@[radiusView] withDuration:4.0];
        }];
        
        [self afterDelay:7.5:^{
            [message4 text:@"a segment from that point to the circle center must be?"];
            [self fadeInViews:@[message4] withDuration:2.0];
        }];
        
    }];
}


@end
