//
//  DHLevelLineCopy2.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-05.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelLineCopy2.h"

#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@interface DHLevelLineCopy2 () {
    DHLineSegment* _lineAB;
    DHPoint* _pointC;
    BOOL _step1finished;
}

@end

@implementation DHLevelLineCopy2

- (NSString*)levelDescription
{
    return @"Translate the segment AB to the point C.";
}

- (NSString*)levelDescriptionExtra
{
    return @"Translate the segment AB to point C. \n\nIn other words, construct a line segment with the same length and same direction as line segment AB but with starting point C. Note that point C lays on the same line as segment AB.";
}

- (NSString *)additionalCompletionMessage
{
    return (@"You enhanced your tool: Translating lines!");
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable_Weak |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable |
            DHTranslateToolAvailable_Weak);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 2;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 4;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:180 andY:200];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:330 andY:150];
    
    DHLineSegment* l1 = [[DHLineSegment alloc] initWithStart:p1 andEnd:p2];
    DHLine* lHidden = [[DHLine alloc] initWithStart:p1 andEnd:p2];
    
    DHPointOnLine* p3 = [[DHPointOnLine alloc] initWithLine:lHidden andTValue:1.4];
    p3.hideBorder = YES;
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    [geometricObjects addObject:p3];
    
    _pointC = p3;
    _lineAB = l1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHTranslatedPoint* p = [[DHTranslatedPoint alloc] init];
    p.startOfTranslation = _pointC;
    p.translationStart = _lineAB.start;
    p.translationEnd = _lineAB.end;
    
    DHLineSegment* l = [[DHLineSegment alloc] initWithStart:_pointC andEnd:p];
    
    [objects insertObject:l atIndex:0];
    [objects addObject:p];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _lineAB.start.position;
    CGPoint pointB = _lineAB.end.position;
    
    _lineAB.start.position = CGPointMake(200, 300);
    _lineAB.end.position = CGPointMake(220, 150);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _lineAB.start.position = pointA;
    _lineAB.end.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    BOOL segmentOfEqualLengthOK = NO;
    BOOL lineObjectCoversSegmentOK = NO;
    BOOL endPointOK = NO;
    
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = _pointC;
    tp.translationStart = _lineAB.start;
    tp.translationEnd = _lineAB.end;
    DHLineSegment* sCD = [[DHLineSegment alloc] initWithStart:_pointC andEnd:tp];
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if (object == _pointC || object == _lineAB) continue;

        if (LineObjectCoversSegment(object, sCD)) {
            lineObjectCoversSegmentOK = YES;
        }
        if (EqualPoints(object, tp)) {
            endPointOK = YES;
        }
        if (LineSegmentsWithEqualLength(_lineAB, object)) {
            segmentOfEqualLengthOK = YES;
        }
    }
    
    self.progress = (segmentOfEqualLengthOK)/2.0*100;

    if (lineObjectCoversSegmentOK && endPointOK) {
        self.progress = 100;
        return YES;
    }
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = _pointC;
    tp.translationStart = _lineAB.start;
    tp.translationEnd = _lineAB.end;
    DHLineSegment* sCD = [[DHLineSegment alloc] initWithStart:_pointC andEnd:tp];
    
    
    for (id object in objects){
        if (LineObjectCoversSegment(object, sCD)) return MidPointFromLine(sCD);
        if (EqualPoints(object, tp)) return tp.position;
        if (LineSegmentsWithEqualLength(_lineAB, object) && EqualDirection2(_lineAB,object)){
            DHLineObject* line = object;
            return MidPointFromLine(line);
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
    
    [self afterDelay:1.0 :^{
        if (!self.showingHint) return;
        hintView.frame = geometryView.frame;
        
        CGFloat centerX = [geometryView.geoViewTransform viewToGeo:geometryView.center].x;
        DHPoint* p1 = [[DHPoint alloc] initWithPositionX:centerX-100 andY:100];
        DHPoint* p2 = [[DHPoint alloc] initWithPositionX:centerX-120 andY:200];
        DHPoint* p3 = [[DHPoint alloc] initWithPositionX:centerX+100 andY:120];
        DHPoint* p4 = [[DHPoint alloc] initWithPositionX:centerX+80 andY:220];
        DHLineSegment* s1 = [[DHLineSegment alloc] initWithStart:p1 andEnd:p2];
        
        DHLine* l2 = [[DHLine alloc] initWithStart:p1 andEnd:p3];
        DHLine* l3 = [[DHLine alloc] initWithStart:p2 andEnd:p4];
        DHLine* l4 = [[DHLine alloc] initWithStart:p3 andEnd:p4];
        l2.temporary = l3.temporary = l4.temporary = YES;

        DHLineSegment* s2 = [[DHLineSegment alloc] initWithStart:p3 andEnd:p4];
        
        DHGeometryView* rhombView1 = [[DHGeometryView alloc] initWithObjects:@[l2, l3]
                                                                 supView:geometryView addTo:hintView];
        DHGeometryView* rhombView2 = [[DHGeometryView alloc] initWithObjects:@[l4]
                                                                    supView:geometryView addTo:hintView];
        DHGeometryView* s1View = [[DHGeometryView alloc] initWithObjects:@[s1, p1, p2, p4]
                                                                   supView:geometryView addTo:hintView];
        DHGeometryView* s2View = [[DHGeometryView alloc] initWithObjects:@[s2, p3]
                                                                 supView:geometryView addTo:hintView];
        
        Message* message1 = [[Message alloc] initAtPoint:CGPointMake(80,460) addTo:hintView];
        
        [self afterDelay:0.0:^{
            [message1 text:@"Constructing a rhomboid makes it possible to copy a line segment."];
            [self fadeInViews:@[message1, s1View] withDuration:1.5];
        }];
        
        [self afterDelay:2.0 :^{
            [self fadeInViews:@[rhombView1, rhombView2] withDuration:1.5];
        }];
        
        [self afterDelay:3.5 :^{
            [self fadeInViews:@[s2View] withDuration:1.5];
        }];
        
        [self afterDelay:6.0 :^{
            [message1 appendLine:@"However, that construction breaks down when the point is in line with the segment."
                    withDuration:2.0];
            [self movePoint:p3 toPosition:CGPointMake(centerX-130, 250) withDuration:3.0
                    inViews:@[rhombView1, rhombView2, s1View, s2View]];
            [self movePoint:p4 toPosition:CGPointMake(centerX-150, 350) withDuration:3.0
                    inViews:@[rhombView1, rhombView2, s1View, s2View]];
            [self fadeOut:s2View withDuration:3.5];
            [self fadeOut:rhombView1 withDuration:3.5];
        }];
        
        [self afterDelay:10.0 :^{
            [message1 appendLine:@"Can you think of another, indirect way, to copy the line segment in that case?"
                    withDuration:2.0];
        }];
        [self afterDelay:12.0 :^{
            [message1 appendLine:@"The new copy line segment tool is still useful!"
                    withDuration:2.0];
        }];
        
        [self afterDelay:2.0 :^{
            [self showEndHintMessageInView:hintView];
        }];
        
    }];
}

@end