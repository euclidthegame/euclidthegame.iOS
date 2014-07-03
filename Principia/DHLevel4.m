//
//  DHLevel3.m
//  Principia
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevel4.h"
#import <CoreGraphics/CGBase.h>
#import "DHGeometricObjects.h"

@interface DHLevel4 () {
    DHLine* _initialLine;
}

@end

@implementation DHLevel4

- (NSString*)title
{
    return @"Challenge 4";
}

- (NSString*)subTitle
{
    return @"Splitting hairs";
}

- (NSString*)levelDescription
{
    return @"Create a point exactly dividing the line AB into two parts of equal length";
}

- (void)setUpLevel:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:300 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:500 andY:300];
    DHLine* l1 = [[DHLine alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    [geometricObjects addObject:l1];
    
    _initialLine = l1;
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class] isSubclassOfClass:[DHPoint class]] == NO) continue;
        if (object == _initialLine.start || object == _initialLine.end) continue;
        
        DHPoint* p = object;
        CGPoint currentPoint = p.position;
        CGPoint midPoint = MidPointFromPoints(_initialLine.start.position, _initialLine.end.position);
        if (CGFloatsEqualWithinEpsilon(currentPoint.x, midPoint.x) &&
            CGFloatsEqualWithinEpsilon(currentPoint.y, midPoint.y)) {
            return YES;
        }
    }
    
    return NO;
}


@end
