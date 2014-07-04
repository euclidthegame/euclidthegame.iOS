//
//  DHLevel6.m
//  Principia
//
//  Created by David Hallgren on 2014-07-02.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevel6.h"
#import <CoreGraphics/CGBase.h>
#import "DHGeometricObjects.h"

@interface DHLevel6 () {
    DHPoint* _pointA;
    DHLine* _lineBC;
}

@end

@implementation DHLevel6

- (NSString*)title
{
    return @"Challenge 6";
}

- (NSString*)subTitle
{
    return @"Perpendicular";
}

- (NSString*)levelDescription
{
    return @"Create a line segment with A as one of its end points that is perpendicular to the line segment BC";
}

- (void)setUpLevel:(NSMutableArray *)geometricObjects
{
    DHPointOnLine* p1 = [[DHPointOnLine alloc] init];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:200 andY:300];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:500 andY:300];
    
    DHLine* l1 = [[DHLine alloc] init];
    l1.start = p2;
    l1.end = p3;

    p1.line = l1;
    p1.tValue = 0.75;
    
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    [geometricObjects addObject:p3];
    [geometricObjects addObject:l1];
    
    _pointA = p1;
    _lineBC = l1;
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
    
    complete = [self isLevelCompleteHelper:geometricObjects];

    _lineBC.start.position = pointB;
    _lineBC.end.position = pointC;
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([object class]  != [DHLine class]) continue;
        
        DHLine* l = object;
        if ((l.start == _pointA || l.end == _pointA) == NO) continue;
        
        CGVector bc = CGVectorNormalize(_lineBC.vector);
        
        CGFloat lDotBC = CGVectorDotProduct(CGVectorNormalize(l.vector), bc);
        if (fabs(lDotBC) < 0.000001) {
            return YES;
        }
    }
    
    return NO;
}

@end
