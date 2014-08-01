//
//  DHLevelLineCopy.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-05.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelLineCopy.h"

#import "DHGeometricObjects.h"

@interface DHLevelLineCopy () {
    DHLineSegment* _lineAB;
    DHPoint* _pointC;
}

@end

@implementation DHLevelLineCopy

- (NSString*)subTitle
{
    return @"Copy the line";
}

- (NSString*)levelDescription
{
    return @"Translate the segment AB to the point C.";
}

- (NSString*)levelDescriptionExtra
{
    return @"Translate the segment AB to point C. \n\nIn other words, construct a line segment with the same length and same direction as line segment AB but with starting point C.";
}

- (NSString *)additionalCompletionMessage
{
    return (@"You unlocked a new tool: Translating lines! Note that this new tool won't work when all points "
            @"lay on the same line. Enhance your new tool in Level 8.");
}

- (NSUInteger)minimumNumberOfMoves
{
    return 3;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 6;
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable);
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:180 andY:400];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:230 andY:100];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:350 andY:450];
    
    DHLineSegment* l1 = [[DHLineSegment alloc] initWithStart:p1 andEnd:p2];
    
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
    
    _lineAB.start.position = CGPointMake(pointA.x+1, pointA.y+2);
    _lineAB.end.position = CGPointMake(pointB.x-3, pointB.y-4);
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
    BOOL parallelLineOK = NO;
    BOOL intersectingLineOK = NO;
    
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = _pointC;
    tp.translationStart = _lineAB.start;
    tp.translationEnd = _lineAB.end;
    
    // First, look for a point translated from C at distance AB and parallell to AB
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        
        if ([[object class]  isSubclassOfClass:[DHLineObject class]]) {
            DHLineObject* l = object;
            BOOL intersectsTP = PointOnLine(tp, l);
            if (PointOnLine(_pointC, l) && intersectsTP) {
                parallelLineOK = YES;
            } else if (intersectsTP) {
                intersectingLineOK = YES;
            }
        }
        
        if ([[object class]  isSubclassOfClass:[DHPoint class]]) {
            DHPoint* p = object;
            if (parallelLineOK && EqualPoints(p, tp)) {
                self.progress = 100;
                return YES;
            }
        }
    }
    
    self.progress = (parallelLineOK + intersectingLineOK)/3.0*100;
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    DHParallelLine* par1 = [[DHParallelLine alloc] initWithLine:_lineAB andPoint:_pointC];
    DHLine* lineAC = [[DHLine alloc] initWithStart:_lineAB.start andEnd:_pointC];
    DHParallelLine* par2 = [[DHParallelLine alloc] initWithLine:lineAC andPoint:_lineAB.end];
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = _pointC;
    tp.translationStart = _lineAB.start;
    tp.translationEnd = _lineAB.end;
    
    for (id object in objects){
        if (EqualDirection(object,par1))  return MidPointFromLine(par1);
        if (EqualDirection(object,lineAC)) return MidPointFromLine(lineAC);
        if (EqualDirection(object,par2))  return MidPointFromLine(par2);
        if (EqualPoints(object,tp)) return tp.position;
    }
    return CGPointMake(NAN, NAN);
}

@end
