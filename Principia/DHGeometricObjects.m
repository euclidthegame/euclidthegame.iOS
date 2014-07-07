//
//  DHGeometricObjects.m
//  Principia
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricObjects.h"
#import "DHMath.h"
#import "DHGeometricObjectLabeler.h"

@implementation DHGeometricObject


@end

@implementation DHPoint
- (instancetype) init
{
    self = [super init];
    
    if (self) {
    }
    
    return self;
}

- (instancetype) initWithPositionX:(CGFloat)x andY:(CGFloat)y
{
    self = [super init];
    
    if (self) {
        _position = CGPointMake(x, y);
    }
    
    return self;
}
- (void)drawInContext:(CGContextRef)context
{
    CGFloat pointWidth = 10.0f;
    CGRect rect = CGRectMake(self.position.x - pointWidth*0.5f, self.position.y - pointWidth*0.5f, pointWidth, pointWidth);

    CGContextSaveGState(context);
    
    if (self.highlighted) {
        CGSize shadowSize = CGSizeMake(0, 0);
        CGContextSetShadow(context, shadowSize, 10.0f);
        CGContextSetLineWidth(context, 1.0);
        CGContextSetRGBFillColor(context, 1.0, 0.1, 0.1, 1.0);
        CGContextSetRGBStrokeColor(context, 0.4, 0.1, 0.1, 1.0);
        CGContextFillEllipseInRect(context, rect);
        
    } else {
        CGContextSetLineWidth(context, 1.0);
        CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
        CGContextFillEllipseInRect(context, rect);
    }
    
    CGContextRestoreGState(context);
    
    if (self.label) {
        /// Make a copy of the default paragraph style
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        NSDictionary* attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:10],
                                     NSParagraphStyleAttributeName: paragraphStyle};
        CGSize textSize = [self.label sizeWithAttributes:attributes];
        CGRect labelRect = CGRectMake(self.position.x - textSize.width*0.5f + 7,
                                      self.position.y - pointWidth*0.5f - 4 - textSize.height,
                                      textSize.width, textSize.height);
        [self.label drawInRect:labelRect withAttributes:attributes];
    }
}
@end


@implementation DHLineObject
- (CGVector)vector
{
    return CGVectorMake(self.end.position.x - self.start.position.x, self.end.position.y - self.start.position.y);
}
- (void)drawInContext:(CGContextRef)context
{
    // Avoid CG-errors by exiting early if positions are not valid numbers
    CGPoint start = self.start.position;
    CGPoint end = self.end.position;
    
    if (start.x != start.x) return;
    if (start.y != start.y) return;
    if (end.x != end.x) return;
    if (end.y != end.y) return;

    CGVector dir = CGVectorNormalize(CGVectorBetweenPoints(start, end));
    if (self.tMin == -INFINITY) {
        start.x = start.x - 1000*dir.dx;
        start.y = start.y - 1000*dir.dy;
    }
    if (self.tMax == INFINITY) {
        end.x = end.x + 1000*dir.dx;
        end.y = end.y + 1000*dir.dy;
    }
    
    if (self.highlighted) {
        CGContextSetLineWidth(context, 3.0);
        CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
        CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    } else {
        CGContextSetLineWidth(context, 1.0);
        CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
    }
    
    CGContextMoveToPoint(context, start.x, start.y);
    CGContextAddLineToPoint(context, end.x, end.y);
    CGContextStrokePath(context);
}
@end

@implementation DHLineSegment
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tMin = 0.0;
        self.tMax = 1.0;
    }
    return self;
}
- (CGFloat)length
{
    return DistanceBetweenPoints(self.start.position, self.end.position);
}
@end

@implementation DHCircle
- (void)drawInContext:(CGContextRef)context
{
    CGFloat radius = self.radius;
    CGRect rect = CGRectMake(_center.position.x - radius, _center.position.y - radius, radius*2, radius*2);
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
    CGContextStrokeEllipseInRect(context, rect);
}

- (CGFloat)radius
{
    return DistanceBetweenPoints(_center.position, _pointOnRadius.position);
}
@end


@implementation DHIntersectionPointCircleCircle
- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
}

- (CGPoint)position
{
    CGFloat d = DistanceBetweenPoints(_c1.center.position, _c2.center.position);
    CGFloat dx = _c2.center.position.x - _c1.center.position.x;
    CGFloat dy = _c2.center.position.y - _c1.center.position.y;
    CGVector vx = CGVectorMake(dx/d, dy/d);
    CGVector vy = CGVectorMake(-vx.dy, vx.dx);
    
    CGFloat r1 = _c1.radius;
    CGFloat r2 = _c2.radius;

    CGFloat x = (d*d + r1*r1 - r2*r2)/(2*d);
    CGFloat y = sqrt(r1*r1 - x*x);
    
    if (_onPositiveY) {
        y = -y;
    }
    
    return CGPointMake(_c1.center.position.x + x * vx.dx + y * vy.dx, _c1.center.position.y + x * vx.dy + y * vy.dy);
}

@end


@implementation DHIntersectionPointLineLine
- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
}

- (CGPoint)position
{
    CGPoint intersection = CGPointMake(NAN,NAN);
    
    DHIntersectionResult r  = IntersectionTestLineLine(self.l1, self.l2);
    if (r.intersect) {
        intersection = r.intersectionPoint;
    }
    
    return intersection;
}

@end


@implementation DHIntersectionPointLineCircle
- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
}

- (CGPoint)position
{
    DHIntersectionResult result = DoLineAndCircleIntersect(_l, _c, _preferEnd);
    return result.intersectionPoint;
}

@end


@implementation DHMidPoint
- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
}
- (CGPoint)position
{
    return MidPointFromPoints(self.start.position, self.end.position);
}
@end

@implementation DHTrianglePoint
- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
}
- (CGPoint)position
{
    CGPoint p = MidPointFromPoints(self.start.position, self.end.position);
    CGVector baseVector = CGVectorBetweenPoints(self.start.position, self.end.position);
    CGVector hDir = CGVectorNormalize(CGVectorMakePerpendicular(baseVector));
    CGVector h = CGVectorMultiplyByScalar(hDir, sqrt(3)*0.5*CGVectorLength(baseVector));
    return CGPointMake(p.x - h.dx, p.y - h.dy);
}
@end

@implementation DHPointOnLine
- (void)drawInContext:(CGContextRef)context
{
    [super drawInContext:context];
}
- (CGPoint)position
{
    CGPoint p1 = self.line.start.position;
    CGPoint p2 = self.line.end.position;
    return CGPointMake(p1.x + self.tValue * (p2.x - p1.x), p1.y + self.tValue * (p2.y - p1.y));
}
@end


@implementation DHRay
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tMin = 0.0;
        self.tMax = INFINITY;// 1000.0;
    }
    return self;
}
@end

@implementation DHLine
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tMin = -INFINITY;// 1000.0;
        self.tMax = INFINITY; //1000.0;
    }
    return self;
}
@end


@implementation DHBisectLine
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tMin = -INFINITY;// 1000.0;
        self.tMax = INFINITY; //1000.0;
    }
    return self;
}
- (DHPoint*)start
{
    DHLine* l1 = [[DHLine alloc] init];
    l1.start = self.line1.start;
    l1.end = self.line1.end;
    DHLine* l2 = [[DHLine alloc] init];
    l2.start = self.line2.start;
    l2.end = self.line2.end;
    
    DHIntersectionResult r = IntersectionTestLineLine(l1, l2);
    if (r.intersect) {
        return [[DHPoint alloc] initWithPositionX:r.intersectionPoint.x andY:r.intersectionPoint.y];
    }
    
    return nil;
}
- (DHPoint*)end
{
    CGVector v1 = CGVectorNormalize(self.line1.vector);
    CGVector v2 = CGVectorNormalize(self.line2.vector);
    
    DHPoint* start = self.start;
    DHPoint* end = [[DHPoint alloc] init];
    
    end.position = CGPointMake(start.position.x + v1.dx + v2.dx, start.position.y + v1.dy + v2.dy);
    
    if (start) {
        return end;
    }
    
    return nil;
}
@end


@implementation DHPerpendicularLine
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tMin = -INFINITY;// 1000.0;
        self.tMax = INFINITY; //1000.0;
    }
    return self;
}
- (DHPoint*)start
{
    return self.point;
}
- (DHPoint*)end
{
    if (self.line == nil || self.point == nil) {
        return nil;
    }
    
    CGVector v = CGVectorNormalize(CGVectorMakePerpendicular(self.line.vector));
    
    DHPoint* start = self.start;
    DHPoint* end = [[DHPoint alloc] init];
    
    end.position = CGPointMake(start.position.x + v.dx, start.position.y + v.dy);
    
    return end;
}
@end


@implementation DHParallelLine
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tMin = -INFINITY;// 1000.0;
        self.tMax = INFINITY; //1000.0;
    }
    return self;
}
- (DHPoint*)start
{
    return self.point;
}
- (DHPoint*)end
{
    if (self.line == nil || self.point == nil) {
        return nil;
    }
    
    CGVector v = CGVectorNormalize(self.line.vector);
    
    DHPoint* start = self.start;
    DHPoint* end = [[DHPoint alloc] init];
    
    end.position = CGPointMake(start.position.x + v.dx, start.position.y + v.dy);
    
    return end;
}
@end


@implementation DHTranslatedLine
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tMin = 0;
        self.tMax = 1;
    }
    return self;
}
- (DHPoint*)start
{
    return self.point;
}
- (DHPoint*)end
{
    if (self.line == nil || self.point == nil) {
        return nil;
    }
    
    CGVector v = self.line.vector;
    
    DHPoint* start = self.start;
    DHPoint* end = [[DHPoint alloc] init];
    
    end.position = CGPointMake(start.position.x + v.dx, start.position.y + v.dy);
    
    return end;
}
@end

@implementation DHTranslatedPoint
- (void)drawInContext:(CGContextRef)context
{
    
}
- (CGPoint)position
{
    CGVector translation = CGVectorBetweenPoints(self.translationStart.position, self.translationEnd.position);
    return CGPointMake(self.startOfTranslation.position.x + translation.dx, self.startOfTranslation.position.y + translation.dy);
}
@end