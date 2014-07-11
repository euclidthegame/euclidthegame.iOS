//
//  DHLevel2.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelEquiTri.h"

@interface DHLevelEquiTri() {
    DHLineSegment* _lineAB;
}
@end

@implementation DHLevelEquiTri

- (NSString*)subTitle
{
    return @"Making triangles";
}

- (NSString*)levelDescription
{
    return (@"Create 3 lines forming an equilateral triangle (a triangle whose sides all are of equal length) "
            @"such that the segment AB is one of its sides");
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineToolAvailable | DHRayToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable);
}

- (NSString *)additionalCompletionMessage
{
    return @"You unlocked a new tool: Constructing equilateral triangles!";
}

- (NSUInteger)minimumNumberOfMoves
{
    return 4;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:400];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:400];
    DHLineSegment* l1 = [[DHLineSegment alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    
    _lineAB = l1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:380 andY:400-(sqrt(3)/2*_lineAB.length)];
    [objects addObject:pC];
    
    DHLineSegment* sAC = [[DHLineSegment alloc]initWithStart:_lineAB.start andEnd:pC];
    [objects insertObject:sAC atIndex:0];

    DHLineSegment* sBC = [[DHLineSegment alloc]initWithStart:_lineAB.end andEnd:pC];
    [objects insertObject:sBC atIndex:0];    
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
    
    _lineAB.start.position = CGPointMake(100, 100);
    _lineAB.end.position = CGPointMake(400, 400);
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _lineAB.start.position = pointA;
    _lineAB.end.position = pointB;
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    if (geometricObjects.count < 3) {
        return NO;
    }
    
    for (int index1 = 0; index1 < geometricObjects.count-2; ++index1) {
        id object1 = [geometricObjects objectAtIndex:index1];
        if ([[object1 class] isSubclassOfClass:[DHLineSegment class]] == NO) continue;
        
        for (int index2 = index1+1; index2 < geometricObjects.count-1; ++index2) {
            id object2 = [geometricObjects objectAtIndex:index2];
            if ([[object2 class] isSubclassOfClass:[DHLineSegment class]] == NO) continue;
            
            for (int index3 = index2+1; index3 < geometricObjects.count; ++index3) {
                id object3 = [geometricObjects objectAtIndex:index3];
                if ([[object3 class] isSubclassOfClass:[DHLineSegment class]] == NO) continue;
                
                DHLineSegment* l1 = object1;
                DHLineSegment* l2 = object2;
                DHLineSegment* l3 = object3;
                
                CGFloat length1 = l1.length;
                CGFloat length2 = l2.length;
                CGFloat length3 = l3.length;
                
                // Ensure one of the lines is AB
                if (l1 != _lineAB && l2 != _lineAB && l3 != _lineAB) {
                    continue;
                }
                
                // Ensure all lines are different
                if (AreLinesEqual(l1, l2) || AreLinesEqual(l1, l3) || AreLinesEqual(l2, l3)) {
                    continue;
                }
                
                // Ensure all lines are connected and of same length
                BOOL connected = AreLinesConnected(l1,l2) && AreLinesConnected(l2,l3) && AreLinesConnected(l3,l1);
                if (connected && fabs(length1 - length2) < 0.01 && fabs(length2 - length3) < 0.01) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}


@end
