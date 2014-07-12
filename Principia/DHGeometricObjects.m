//
//  DHGeometricObjects.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricObjects.h"
#import "DHMath.h"
#import "DHGeometricObjectLabeler.h"

typedef struct DHColor_s {
    CGFloat r;
    CGFloat g;
    CGFloat b;
    CGFloat a;
} DHColor;

static const DHColor kPointColor = {130/255.0, 130/255.0, 130/255.0, 1.0};
static const DHColor kPointColorFixed = {20/255.0, 20/255.0, 20/255.0, 1.0};
static const DHColor kPointColorHighlighted = {0/255.0, 0/255.0, 0/255.0, 1.0};
static const DHColor kLineColor = {255/255.0, 204/255.0, 0/255.0, 1.0};
static const DHColor kLineColorHighlighted = {255/255.0, 149/255.0, 0/255.0, 1.0};

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
- (void)drawInContext:(CGContextRef)context withTransform:(DHGeometricTransform*)transform
{
    CGFloat pointWidth = 10.0f;
    CGPoint position = [transform geoToView:self.position];
    CGRect rect = CGRectMake(position.x - pointWidth*0.5f, position.y - pointWidth*0.5f, pointWidth, pointWidth);
    
    CGContextSaveGState(context);
    
    if (self.highlighted) {
        CGSize shadowSize = CGSizeMake(0, 0);
        //CGContextSetShadow(context, shadowSize, 8.0f);
        CGColorRef shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9].CGColor;
        CGContextSetShadowWithColor (context, shadowSize, 5.0f, shadowColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextSetRGBFillColor(context, kPointColorHighlighted.r, kPointColorHighlighted.g,
                                 kPointColorHighlighted.b, kPointColorHighlighted.a);
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
        CGContextFillEllipseInRect(context, rect);
        
    } else {
        CGContextSetLineWidth(context, 1.0);
        if (self.class == [DHPoint class] ||
            self.class == [DHPointOnCircle class] ||
            self.class == [DHPointOnLine class]) {
            CGContextSetRGBFillColor(context, kPointColor.r, kPointColor.g, kPointColor.b, kPointColor.a);
        } else {
            CGContextSetRGBFillColor(context, kPointColorFixed.r, kPointColorFixed.g,
                                     kPointColorFixed.b, kPointColorFixed.a);
        }
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
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
        CGRect labelRect = CGRectMake(position.x - textSize.width*0.5f + 7,
                                      position.y - pointWidth*0.5f - 4 - textSize.height,
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
- (void)drawInContext:(CGContextRef)context withTransform:(DHGeometricTransform*)transform
{
    // Exit early if for some reason the line is no longer valid
    DHPoint* lineStart = self.start;
    DHPoint* lineEnd = self.end;
    if (lineStart == nil || lineEnd == nil) return;
    
    // Avoid CG-errors by exiting early if positions are not valid numbers
    CGPoint start = lineStart.position;
    CGPoint end = lineEnd.position;
    
    if (start.x != start.x) return;
    if (start.y != start.y) return;
    if (end.x != end.x) return;
    if (end.y != end.y) return;

    start = [transform geoToView:start];
    end = [transform geoToView:end];
    
    CGVector dir = CGVectorNormalize(CGVectorBetweenPoints(start, end));
    if (self.tMin == -INFINITY) {
        start.x = start.x - 10000*dir.dx;
        start.y = start.y - 10000*dir.dy;
    }
    if (self.tMax == INFINITY) {
        end.x = end.x + 10000*dir.dx;
        end.y = end.y + 10000*dir.dy;
    }
    
    if (self.highlighted) {
        CGContextSetLineWidth(context, 3.0);
        CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
        CGContextSetRGBStrokeColor(context, kLineColorHighlighted.r, kLineColorHighlighted.g,
                                   kLineColorHighlighted.b, kLineColorHighlighted.a);
    } else {
        CGContextSetLineWidth(context, 1.0);
        CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
        CGContextSetRGBStrokeColor(context, kLineColor.r, kLineColor.g, kLineColor.b, kLineColor.a);
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
- (instancetype)initWithStart:(DHPoint *)start andEnd:(DHPoint *)end
{
    self = [self init];
    if (self) {
        self.start = start;
        self.end = end;
    }
    return self;
}
- (CGFloat)length
{
    return DistanceBetweenPoints(self.start.position, self.end.position);
}
@end

@implementation DHCircle
- (instancetype)initWithCenter:(DHPoint*)center andPointOnRadius:(DHPoint*)pointOnRadius
{
    self = [super init];
    if (self) {
        self.center = center;
        self.pointOnRadius = pointOnRadius;
    }
    return self;

}
- (void)drawInContext:(CGContextRef)context withTransform:(DHGeometricTransform*)transform
{
    CGFloat radius = self.radius * [transform scale];
    CGPoint position = [transform geoToView:self.center.position];
    
    CGRect rect = CGRectMake(position.x - radius, position.y - radius, radius*2, radius*2);    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
    CGContextSetRGBStrokeColor(context, kLineColor.r, kLineColor.g, kLineColor.b, kLineColor.a);
    CGContextStrokeEllipseInRect(context, rect);
}

- (CGFloat)radius
{
    return DistanceBetweenPoints(_center.position, _pointOnRadius.position);
}
@end


@implementation DHIntersectionPointCircleCircle
- (void)drawInContext:(CGContextRef)context withTransform:(DHGeometricTransform*)transform
{
    [super drawInContext:context withTransform:transform];
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
- (instancetype)initWithLine:(DHLineObject*)l1 andLine:(DHLineObject*)l2
{
    self = [super init];
    if (self) {
        self.l1 = l1;
        self.l2 = l2;
    }
    return self;
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
- (CGPoint)position
{
    DHIntersectionResult result = IntersectionTestLineCircle(_l, _c, _preferEnd);
    return result.intersectionPoint;
}

@end


@implementation DHMidPoint
- (CGPoint)position
{
    return MidPointFromPoints(self.start.position, self.end.position);
}
@end

@implementation DHTrianglePoint
- (instancetype)initWithPoint1:(DHPoint*)p1 andPoint2:(DHPoint*)p2
{
    self = [super init];
    if (self) {
        _start = p1;
        _end = p2;
    }
    return self;
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
- (CGPoint)position
{
    if (self.line == nil) {
        return CGPointMake(NAN, NAN);
    }
    
    CGPoint p1 = self.line.start.position;
    CGPoint p2 = self.line.end.position;
    return CGPointMake(p1.x + self.tValue * (p2.x - p1.x), p1.y + self.tValue * (p2.y - p1.y));
}
@end

@implementation DHPointOnCircle
- (CGPoint)position
{
    if (self.circle == nil) {
        return CGPointMake(NAN, NAN);
    }
    
    CGPoint center = self.circle.center.position;
    CGPoint onRadius = CGPointMake(center.x + self.circle.radius, center.y);
    CGVector toPoint = CGVectorRotateByAngle(CGVectorBetweenPoints(center, onRadius), self.angle);
    return CGPointFromPointByAddingVector(center, toPoint);
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
- (instancetype)initWithStart:(DHPoint *)start andEnd:(DHPoint *)end
{
    self = [self init];
    if (self) {
        self.start = start;
        self.end = end;
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
- (instancetype)initWithStart:(DHPoint *)start andEnd:(DHPoint *)end
{
    self = [self init];
    if (self) {
        self.start = start;
        self.end = end;
    }
    return self;
}

@end

@interface DHBisectLine (){
    DHPoint* _startPointCache;
    DHPoint* _endPointCache;
}
@end
@implementation DHBisectLine
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tMin = -INFINITY;// 1000.0;
        self.tMax = INFINITY; //1000.0;
        _startPointCache = [[DHPoint alloc] initWithPositionX:NAN andY:NAN];
        _endPointCache = [[DHPoint alloc] initWithPositionX:NAN andY:NAN];
    }
    return self;
}
- (DHPoint*)start
{
    // First, check if the assigned lines share a point, if so, use it
    if (self.line1.start == self.line2.start || self.line1.start == self.line2.end) return self.line1.start;
    if (self.line1.end == self.line2.start || self.line1.end == self.line2.end) return self.line1.end;
    
    DHIntersectionResult r = IntersectionTestLineLine(self.line1, self.line2);
    if (r.intersect) {
        _startPointCache.position = r.intersectionPoint;
        return _startPointCache;
    }
    
    return nil;
}
- (DHPoint*)end
{
    DHPoint* start = self.start;
    if (!start) {
        return nil;
    }
    
    CGPoint startPos = start.position;
    CGVector v1 = CGVectorNormalize(self.line1.vector);
    CGVector v2 = CGVectorNormalize(self.line2.vector);
    
    // Always use the smallest angle for the bisector and let the perpendicular line also added by the
    // Bisector-tool be other if the lines intersect
    if (CGVectorDotProduct(v1, v2) < 0 && !self.fixedDirection) {
        v2.dx = -v2.dx;
        v2.dy = -v2.dy;
    }
    
    _endPointCache.position = CGPointMake(startPos.x + v1.dx + v2.dx, startPos.y + v1.dy + v2.dy);
    return _endPointCache;
}
@end

@interface DHPerpendicularLine () {
    DHPoint* _endPointCache;
}
@end
@implementation DHPerpendicularLine
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tMin = -INFINITY;// 1000.0;
        self.tMax = INFINITY; //1000.0;
        _endPointCache = [[DHPoint alloc] initWithPositionX:NAN andY:NAN];
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
    _endPointCache.position = CGPointMake(start.position.x + v.dx, start.position.y + v.dy);
    
    return _endPointCache;
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


@implementation DHTranslatedPoint
- (CGPoint)position
{
    CGVector translation = CGVectorBetweenPoints(self.translationStart.position, self.translationEnd.position);
    return CGPointMake(self.startOfTranslation.position.x + translation.dx, self.startOfTranslation.position.y + translation.dy);
}
@end