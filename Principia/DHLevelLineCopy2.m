//
//  DHLevelLineCopy2.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-05.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelLineCopy2.h"

#import "DHGeometricObjects.h"

@interface DHLevelLineCopy2 () {
    DHLineSegment* _lineAB;
    DHPoint* _pointC;
}

@end

@implementation DHLevelLineCopy2

- (NSString*)subTitle
{
    return @"Straight translation";
}

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
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
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

@end