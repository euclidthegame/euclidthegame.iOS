//
//  DHLevel1.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelTutorial.h"

@interface DHLevelTutorial () {
    DHPoint* _pointA;
    DHPoint* _pointB;
    DHPoint* _pointC;
    DHPoint* _pointD;
    DHPoint* _pointE;
    DHPoint* _pointF;
}
@end

@implementation DHLevelTutorial

- (NSString*)subTitle
{
    return @"Learn the basics";
}

- (NSString*)levelDescription
{
    return (@"Construct a line segment from A to B and a line through C and D. "
            @"Construct a point at the intersection of AB and the line. "
            @"Construct two circles with centers E and F, both with radius EF.");
}

- (NSString *)additionalCompletionMessage
{
    return @"Well done! You are now ready to begin with Level 1.";
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 4;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:100 andY:200];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:200 andY:150];
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:150 andY:300];
    DHPoint* pD = [[DHPoint alloc] initWithPositionX:150 andY:250];
    DHPoint* pE = [[DHPoint alloc] initWithPositionX:380 andY:220];
    DHPoint* pF = [[DHPoint alloc] initWithPositionX:450 andY:220];
    DHLineSegment* lEF = [[DHLineSegment alloc] init];
    lEF.start = pE;
    lEF.end = pF;

    [geometricObjects addObject:lEF];
    [geometricObjects addObject:pA];
    [geometricObjects addObject:pB];
    [geometricObjects addObject:pC];
    [geometricObjects addObject:pD];
    [geometricObjects addObject:pE];
    [geometricObjects addObject:pF];
    
    _pointA = pA;
    _pointB = pB;
    _pointC = pC;
    _pointD = pD;
    _pointE = pE;
    _pointF = pF;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHLineSegment* sAB = [[DHLineSegment alloc]initWithStart:_pointA andEnd:_pointB];
    [objects insertObject:sAB atIndex:0];

    DHRay* rCD = [[DHRay alloc] initWithStart:_pointC andEnd:_pointD];
    [objects insertObject:rCD atIndex:0];
    
    DHIntersectionPointLineLine* ip = [[DHIntersectionPointLineLine alloc] initWithLine:sAB andLine:rCD];
    [objects addObject:ip];
    
    DHCircle* cEF = [[DHCircle alloc] initWithCenter:_pointE andPointOnRadius:_pointF];
    [objects insertObject:cEF atIndex:0];

    DHCircle* cFE = [[DHCircle alloc] initWithCenter:_pointF andPointOnRadius:_pointE];
    [objects insertObject:cFE atIndex:0];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL segmentAB = NO;
    BOOL lineCD = NO;
    BOOL circleEF = NO;
    BOOL circleFE = NO;
    BOOL intersectionPoint = NO;
    DHLineSegment* lAB = nil;
    DHLine* lCD = nil;
    
    
    for (id object in geometricObjects) {
        if ([object class] == [DHLineSegment class]) {
            DHLineSegment* segment = object;
            if ((segment.start == _pointA || segment.end == _pointA) &&
                (segment.start == _pointB || segment.end == _pointB)) {
                segmentAB = YES;
                lAB = segment;
            }
        }

        if ([object class] == [DHLine class]) {
            DHLine* line = object;
            if ((line.start == _pointC || line.end == _pointC) &&
                (line.start == _pointD || line.end == _pointD)) {
                lineCD = YES;
                lCD = line;
            }
        }

        if ([object class] == [DHCircle class]) {
            DHCircle* circle = object;
            if (circle.center == _pointE && circle.pointOnRadius == _pointF) circleEF = YES;
            if (circle.center == _pointF && circle.pointOnRadius == _pointE) circleFE = YES;
        }

        if ([object class] == [DHIntersectionPointLineLine class]) {
            DHIntersectionPointLineLine* point = object;
            if ((point.l1 == lAB || point.l2 == lAB) && (point.l1 == lCD || point.l2 == lCD)) {
                intersectionPoint = YES;
            }
        }
    }
    
    self.progress = (segmentAB + lineCD + circleEF + circleFE + intersectionPoint)/5.0*100;
    
    if (segmentAB && lineCD && circleEF && circleFE && intersectionPoint) {
        return YES;
    }
    
    return NO;
}


- (CGPoint)testObjectsForProgressHints:(NSArray*)objects {
    
    // Objects to test for
    DHLineSegment* sAB = [[DHLineSegment alloc]initWithStart:_pointA andEnd:_pointB];
    DHLine* lCD = [[DHLine alloc] initWithStart:_pointC andEnd:_pointD];
    DHCircle* cEF = [[DHCircle alloc] initWithCenter:_pointE andPointOnRadius:_pointF];
    DHCircle* cFE = [[DHCircle alloc] initWithCenter:_pointF andPointOnRadius:_pointE];
    DHIntersectionPointLineLine* ip = [[DHIntersectionPointLineLine alloc] initWithLine:sAB andLine:lCD];
    DHPoint* pABCD = [[DHPoint alloc ]init];
    pABCD.position = ip.position;
    
    for (id object in objects){
        if (EqualSegments(sAB, object)){
            return sAB.end.position;
        }
        if (EqualLines(lCD, object)){
            return lCD.end.position;
        }
        if (EqualCircles(cEF, object)){
            return cEF.center.position;
        }
        if (EqualCircles(cFE, object)){
            return cFE.center.position;
        }
        if (EqualPoints(pABCD, object)){
            return pABCD.position;
        }
    }
    
    return CGPointMake(NAN, NAN);
}

@end
