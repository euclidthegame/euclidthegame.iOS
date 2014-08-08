//
//  DHLevelHexagon.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-11.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelHexagon.h"

#import "DHGeometricObjects.h"

@interface DHLevelHexagon () {
    DHLineSegment* _lineAB;
    BOOL hint1_OK;
    BOOL hint2_OK;
}

@end

@implementation DHLevelHexagon

- (NSString*)subTitle
{
    return @"Super hexagon";
}

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

-(void)hint:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view and:(NSLayoutConstraint *)heightToolBar and:(UIButton *)hintButton{
if ([hintButton.titleLabel.text  isEqual: @"Hide hint"]) {
    [hintButton setTitle:@"Show hint" forState:UIControlStateNormal];
    [geometryView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    return;
}

if (!hint1_OK) {
    [self showTemporaryMessage:@"You can find all the required points, using only one tool." atPoint:CGPointMake(self.geometryView.center.x,50) withColor:[UIColor darkGrayColor] andTime:4.0];
    hint1_OK = YES;
    return;
}
else if (!hint2_OK) {
        [self showTemporaryMessage:@"Try the circle tool." atPoint:CGPointMake(self.geometryView.center.x,50) withColor:[UIColor darkGrayColor] andTime:4.0];
    hint2_OK = YES;
    return;
    }
else{
    [self showTemporaryMessage:@"No more hints available." atPoint:CGPointMake(self.geometryView.center.x,50) withColor:[UIColor darkGrayColor] andTime:4.0];
        hint1_OK = NO;
    hint2_OK = NO;
    return;
        
    }
}

@end


