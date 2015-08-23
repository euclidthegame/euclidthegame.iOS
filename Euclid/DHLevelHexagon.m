//
//  DHLevelHexagon.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-11.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelHexagon.h"

#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@interface DHLevelHexagon () {
    DHLineSegment* _lineAB;
}

@end

@implementation DHLevelHexagon

- (NSString*)levelDescription
{
    return (@"Construct a regular hexagon given one side AB.");
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
    return 6;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 8;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:300 andY:400];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:450 andY:400];
    
    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:pA andEnd:pB];
    
    [geometricObjects addObject:lAB];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];

    _lineAB = lAB;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHTrianglePoint* center = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.start
                                                            andPoint2:_lineAB.end];
    DHPoint* pA = _lineAB.start;
    DHPoint* pB = _lineAB.end;
    DHPoint* pC = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pB];
    DHPoint* pD = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pC];
    DHPoint* pE = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pD];
    DHPoint* pF = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pE];
    
    DHLineSegment* lBC = [[DHLineSegment alloc] initWithStart:pB andEnd:pC];
    DHLineSegment* lCD = [[DHLineSegment alloc] initWithStart:pC andEnd:pD];
    DHLineSegment* lDE = [[DHLineSegment alloc] initWithStart:pD andEnd:pE];
    DHLineSegment* lEF = [[DHLineSegment alloc] initWithStart:pE andEnd:pF];
    DHLineSegment* lFA = [[DHLineSegment alloc] initWithStart:pF andEnd:pA];
    
    [objects insertObject:lBC atIndex:0];
    [objects insertObject:lCD atIndex:0];
    [objects insertObject:lDE atIndex:0];
    [objects insertObject:lEF atIndex:0];
    [objects insertObject:lFA atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    NSUInteger progress1 = self.progress;
    NSUInteger progress2 = 0;

    DHPoint* pA = _lineAB.start;
    DHPoint* pB = _lineAB.end;
    
    if (!complete) {
        // Switch AB and see if other direction works
        _lineAB.start = pB;
        _lineAB.end = pA;
        for (id object in geometricObjects) {
            if ([object respondsToSelector:@selector(updatePosition)]) {
                [object updatePosition];
            }
        }
        
        complete = [self isLevelCompleteHelper:geometricObjects];
        progress2 = self.progress;
    }
    
    if (complete) {
        // Move A and B and ensure solution holds
        CGPoint pointA = pA.position;
        CGPoint pointB = pB.position;
        
        pA.position = CGPointMake(pointA.x - 10, pointA.y - 10);
        pB.position = CGPointMake(pointB.x + 10, pointB.y + 10);
        for (id object in geometricObjects) {
            if ([object respondsToSelector:@selector(updatePosition)]) {
                [object updatePosition];
            }
        }
        
        complete = [self isLevelCompleteHelper:geometricObjects];
        
        pA.position = pointA;
        pB.position = pointB;
    }
    
    // Switch back AB if change to original setup
    _lineAB.start = pA;
    _lineAB.end = pB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    self.progress = MAX(progress1, progress2);
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    DHTrianglePoint* center = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.start
                                                            andPoint2:_lineAB.end];
    DHPoint* pA = _lineAB.start;
    DHPoint* pB = _lineAB.end;
    DHPoint* pC = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pB];
    DHPoint* pD = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pC];
    DHPoint* pE = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pD];
    DHPoint* pF = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pE];
    
    DHLineSegment* lBC = [[DHLineSegment alloc] initWithStart:pB andEnd:pC];
    DHLineSegment* lCD = [[DHLineSegment alloc] initWithStart:pC andEnd:pD];
    DHLineSegment* lDE = [[DHLineSegment alloc] initWithStart:pD andEnd:pE];
    DHLineSegment* lEF = [[DHLineSegment alloc] initWithStart:pE andEnd:pF];
    DHLineSegment* lFA = [[DHLineSegment alloc] initWithStart:pF andEnd:pA];
    
    BOOL sBCOK = NO, sCDOK = NO, sDEOK = NO, sEFOK = NO, sFAOK = NO;
    
    for (id object in geometricObjects) {
        if (LineObjectCoversSegment(object, lBC)) sBCOK = YES;
        if (LineObjectCoversSegment(object, lCD)) sCDOK = YES;
        if (LineObjectCoversSegment(object, lDE)) sDEOK = YES;
        if (LineObjectCoversSegment(object, lEF)) sEFOK = YES;
        if (LineObjectCoversSegment(object, lFA)) sFAOK = YES;
    }
    
    if (sBCOK && sCDOK && sDEOK && sEFOK && sFAOK) {
        self.progress = 100;
        return YES;
    }
    
    self.progress = (sBCOK + sCDOK + sDEOK + sEFOK + sFAOK)/5.0 * 100;
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects{
    DHTrianglePoint* center = [[DHTrianglePoint alloc] initWithPoint1:_lineAB.start
                                                            andPoint2:_lineAB.end];
    DHPoint* pA = _lineAB.start;
    DHPoint* pB = _lineAB.end;
    DHPoint* pC = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pB];
    DHPoint* pD = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pC];
    DHPoint* pE = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pD];
    DHPoint* pF = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pE];
    
    DHCircle* cAB = [[DHCircle alloc] initWithCenter:_lineAB.start andPointOnRadius:_lineAB.end];
    
    DHLineSegment* lBC = [[DHLineSegment alloc] initWithStart:pB andEnd:pC];
    DHLineSegment* lCD = [[DHLineSegment alloc] initWithStart:pC andEnd:pD];
    DHLineSegment* lDE = [[DHLineSegment alloc] initWithStart:pD andEnd:pE];
    DHLineSegment* lEF = [[DHLineSegment alloc] initWithStart:pE andEnd:pF];
    DHLineSegment* lFA = [[DHLineSegment alloc] initWithStart:pF andEnd:pA];
    
    
    for (id object in objects){
        if (EqualRadius(object,cAB)){
            if (PointOnCircle(pA,object)) return Position(object);
            if (PointOnCircle(pB,object)) return Position(object);
            if (PointOnCircle(pC,object)) return Position(object);
            if (PointOnCircle(pD,object)) return Position(object);
            if (PointOnCircle(pE,object)) return Position(object);
            if (PointOnCircle(pF,object)) return Position(object);
        }
        if (EqualPoints(object,pC)) return Position(object);
        if (EqualPoints(object,pD)) return Position(object);
        if (EqualPoints(object,pE)) return Position(object);
        if (EqualPoints(object,pF)) return Position(object);
        if (LineObjectCoversSegment(object, lBC)) return Position(object);
        if (LineObjectCoversSegment(object, lCD)) return Position(object);
        if (LineObjectCoversSegment(object, lDE)) return Position(object);
        if (LineObjectCoversSegment(object, lEF)) return Position(object);
        if (LineObjectCoversSegment(object, lFA)) return Position(object);
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

        DHPoint* pA = [[DHPoint alloc] initWithPositionX:centerX-80 andY:400];
        DHPoint* pB = [[DHPoint alloc] initWithPositionX:centerX+80 andY:400];
        
        
        DHTrianglePoint* center = [[DHTrianglePoint alloc] initWithPoint1:pA andPoint2:pB];
        DHPoint* pC = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pB];
        DHPoint* pD = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pC];
        DHPoint* pE = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pD];
        DHPoint* pF = [[DHTrianglePoint alloc] initWithPoint1:center andPoint2:pE];
        
        DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:pA andEnd:pB];
        DHLineSegment* lBC = [[DHLineSegment alloc] initWithStart:pB andEnd:pC];
        DHLineSegment* lCD = [[DHLineSegment alloc] initWithStart:pC andEnd:pD];
        DHLineSegment* lDE = [[DHLineSegment alloc] initWithStart:pD andEnd:pE];
        DHLineSegment* lEF = [[DHLineSegment alloc] initWithStart:pE andEnd:pF];
        DHLineSegment* lFA = [[DHLineSegment alloc] initWithStart:pF andEnd:pA];
        
        DHAngleIndicator* angleA = [[DHAngleIndicator alloc] initWithLine1:lFA line2:lAB andRadius:20];
        angleA.showAngleText = YES;
        angleA.anglePosition = 3;
        DHAngleIndicator* angleB = [[DHAngleIndicator alloc] initWithLine1:lAB line2:lBC andRadius:20];
        angleB.showAngleText = YES;
        angleB.anglePosition = 3;
        DHAngleIndicator* angleC = [[DHAngleIndicator alloc] initWithLine1:lBC line2:lCD andRadius:20];
        angleC.showAngleText = YES;
        angleC.anglePosition = 3;
        angleC.alwaysInner = YES;
        DHAngleIndicator* angleD = [[DHAngleIndicator alloc] initWithLine1:lCD line2:lDE andRadius:20];
        angleD.showAngleText = YES;
        angleD.anglePosition = 3;
        DHAngleIndicator* angleE = [[DHAngleIndicator alloc] initWithLine1:lDE line2:lEF andRadius:20];
        angleE.showAngleText = YES;
        angleE.anglePosition = 3;
        DHAngleIndicator* angleF = [[DHAngleIndicator alloc] initWithLine1:lFA line2:lEF andRadius:20];
        angleF.showAngleText = YES;
        angleF.anglePosition = 2;
        angleF.alwaysInner = YES;
        
        DHGeometryView* hexaView = [[DHGeometryView alloc] initWithObjects:@[lAB, lBC, lCD, lDE, lEF, lFA,
                                                                             angleA, angleB, angleC, angleD,
                                                                             angleE, angleF]
                                                                   supView:geometryView addTo:hintView];
        
        Message* message1 = [[Message alloc] initAtPoint:CGPointMake(80,460) addTo:hintView];
        
        [self afterDelay:0.0:^{
            [message1 text:@"All the inner angles of a hexagon always equal 120°."];
            [self fadeInViews:@[message1, hexaView] withDuration:2.5];
        }];
        [self afterDelay:3.0:^{
            [message1 appendLine:@"Do you have tool that can make an angle easily related to that?"
                    withDuration:2.5];
        }];
        
        [self afterDelay:2.0 :^{
            [self showEndHintMessageInView:hintView];
        }];
        
    }];
}

@end


