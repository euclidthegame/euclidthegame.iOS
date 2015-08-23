//
//  DHGeometricObjects.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
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
static const size_t kDashPatternItems = 2;
static const CGFloat kDashPattern[kDashPatternItems] = {6 ,5};

@implementation DHGeometricObject

- (instancetype) init
{
    self = [super init];
    
    if (self) {
        _drawScale = 1.0;
    }
    
    return self;
}

@end

#pragma mark - Point types
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
- (instancetype) initWithPosition:(CGPoint)position
{
    self = [super init];
    
    if (self) {
        _position = position;
    }
    
    return self;
}
- (void)drawInContext:(CGContextRef)context withTransform:(DHGeometricTransform*)transform
{
    CGFloat scale = self.drawScale;
    CGFloat pointWidth = 10.0 * scale;
    CGPoint position = [transform geoToView:self.position];
    CGRect rect = CGRectMake(position.x - pointWidth*0.5f, position.y - pointWidth*0.5f,
                             pointWidth, pointWidth);
    
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
        
    } else if(self.temporary) {
        CGSize shadowSize = CGSizeMake(0, 0);
        //CGContextSetShadow(context, shadowSize, 8.0f);
        CGColorRef shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9].CGColor;
        CGContextSetShadowWithColor (context, shadowSize, 5.0f, shadowColor);
        CGContextSetLineWidth(context, 0.6);
        CGContextSetRGBFillColor(context, kLineColorHighlighted.r, kLineColorHighlighted.g,
                                 kLineColorHighlighted.b, kLineColorHighlighted.a);
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
        CGContextFillEllipseInRect(context, rect);
        CGContextStrokeEllipseInRect(context, rect);
    } else {
        CGContextSetLineWidth(context, 1.0);
        if (self.class == [DHPoint class] ||
            self.class == [DHPointOnCircle class] ||
            self.class == [DHPointOnLine class] ||
            self.class == [DHPointWithBlockConstraint class]) {
            CGContextSetRGBFillColor(context, kPointColor.r, kPointColor.g, kPointColor.b, kPointColor.a);
        } else {
            CGContextSetRGBFillColor(context, kPointColorFixed.r, kPointColorFixed.g,
                                     kPointColorFixed.b, kPointColorFixed.a);
        }
        CGContextFillEllipseInRect(context, rect);
        
        if (self.class == [DHPointOnCircle class] || self.class == [DHPointOnLine class])
        {
            BOOL hideBorder = NO;
            if (self.class == [DHPointOnCircle class]) {
                DHPointOnCircle* p = (DHPointOnCircle*)self;
                hideBorder = p.hideBorder;
            }
            if (self.class == [DHPointOnLine class]) {
                DHPointOnLine* p = (DHPointOnLine*)self;
                hideBorder = p.hideBorder;
            }
            if (!hideBorder) {
                CGContextSetRGBStrokeColor(context, kLineColor.r, kLineColor.g, kLineColor.b, 1.0);
                CGContextStrokeEllipseInRect(context, rect);
            }
        }
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
- (void)updatePosition
{
    
}
- (CGPoint)position
{
    if (!_updatesPositionAutomatically) {
        [self updatePosition];
    }
    
    return _position;
}
@end


@implementation DHIntersectionPointCircleCircle
- (instancetype)initWithCircle1:(DHCircle*)c1 andCircle2:(DHCircle*)c2 onPositiveY:(BOOL)onPositiveY
{
    self = [super init];
    if (self) {
        _c1 = c1;
        _c2 = c2;
        _onPositiveY = onPositiveY;
        [self updatePosition];
    }
    return self;
}
- (void)drawInContext:(CGContextRef)context withTransform:(DHGeometricTransform*)transform
{
    [super drawInContext:context withTransform:transform];
}
- (void)setC1:(DHCircle *)c1
{
    _c1 = c1;
    [self updatePosition];
}
- (void)setC2:(DHCircle *)c2
{
    _c2 = c2;
    [self updatePosition];
}
- (void)setOnPositiveY:(BOOL)onPositiveY
{
    _onPositiveY = onPositiveY;
    [self updatePosition];
}
- (void)updatePosition
{
    if (!_c1 || !_c2) {
        self.position = CGPointMake(NAN, NAN);
        return;
    }
    
    CGPoint c1CenterPos = self.c1.center.position;
    CGPoint c2CenterPos = self.c2.center.position;
    CGFloat r1 = _c1.radius;
    CGFloat r2 = _c2.radius;

    if (isnan(r1) || isnan(r2) ||
        isnan(c1CenterPos.x) || isnan(c1CenterPos.y) ||
        isnan(c2CenterPos.x) || isnan(c2CenterPos.y))
    {
        self.position = CGPointMake(NAN, NAN);
        return;
    }
    
    CGFloat d = DistanceBetweenPoints(c1CenterPos, c2CenterPos);
    if (d == 0) {
        self.position = CGPointMake(NAN, NAN);
        return;
    }
    
    CGVector vC1ToC2NonNormalized = CGVectorBetweenPoints(c1CenterPos, c2CenterPos);
    CGVector vC1ToC2 = CGVectorMultiplyByScalar(vC1ToC2NonNormalized, 1/d);
    CGVector vy = CGVectorMakePerpendicular(vC1ToC2);

    CGFloat x = (d*d + r1*r1 - r2*r2)/(2*d);
    CGFloat y = sqrt(r1*r1 - x*x);
    
    if (_onPositiveY) {
        y = -y;
    }
    
    self.position = CGPointMake(c1CenterPos.x + x * vC1ToC2.dx + y * vy.dx, c1CenterPos.y + x * vC1ToC2.dy + y * vy.dy);
}
@end


@implementation DHIntersectionPointLineLine
- (instancetype)initWithLine:(DHLineObject*)l1 andLine:(DHLineObject*)l2
{
    self = [super init];
    if (self) {
        self.l1 = l1;
        self.l2 = l2;
        [self updatePosition];
    }
    return self;
}
- (void)setL1:(DHLineObject *)l1
{
    _l1 = l1;
    [self updatePosition];
}
- (void)setL2:(DHLineObject *)l2
{
    _l2 = l2;
    [self updatePosition];
}
- (void)updatePosition
{
    CGPoint intersection = CGPointMake(NAN,NAN);
    
    if (!_l1 || !_l2) {
        self.position = intersection;
        return;
    }
    
    DHIntersectionResult r  = IntersectionTestLineLine(self.l1, self.l2);
    if (r.intersect) {
        intersection = r.intersectionPoint;
    }
    
    self.position = intersection;
}
@end


@implementation DHIntersectionPointLineCircle
- (instancetype)initWithLine:(DHLineObject*)l andCircle:(DHCircle*)c andPreferEnd:(BOOL)preferEnd
{
    self = [super init];
    if (self) {
        _l = l;
        _c = c;
        _preferEnd = preferEnd;
        [self updatePosition];
    }
    return self;
}
- (void)setL:(DHLineObject *)l
{
    _l = l;
    [self updatePosition];
}
- (void)setC:(DHCircle *)c
{
    _c = c;
    [self updatePosition];
}
- (void)setPreferEnd:(BOOL)preferEnd
{
    _preferEnd = preferEnd;
    [self updatePosition];
}
- (void)updatePosition
{
    CGPoint intersection = CGPointMake(NAN,NAN);

    if (!_l || !_c) {
        self.position = intersection;
        return;
    }
    
    // Special case for intersection with circle/line where circle is define to point on the line
    if (
        ([_c.pointOnRadius class] == [DHPointOnLine class] && ((DHPointOnLine*)_c.pointOnRadius).line == _l)
        
        ||
        
        ([_c.pointOnRadius class] == [DHIntersectionPointLineCircle class] &&
         ((DHIntersectionPointLineCircle*)_c.pointOnRadius).l == _l)
        
        ||
        
        ([_c.pointOnRadius class] == [DHIntersectionPointLineLine class] &&
         ((DHIntersectionPointLineLine*)_c.pointOnRadius).l1 == _l)
        
        ||
        
        ([_c.pointOnRadius class] == [DHIntersectionPointLineLine class] &&
         ((DHIntersectionPointLineLine*)_c.pointOnRadius).l2 == _l)

        )
    {
        // Interpret _preferEnd to define if overlap with pointOnRadius or not
        if (_preferEnd) {
            intersection = _c.pointOnRadius.position;
        } else {
            DHIntersectionResult result1 = IntersectionTestLineCircle(_l, _c, YES);
            DHIntersectionResult result2 = IntersectionTestLineCircle(_l, _c, NO);
            if (result1.intersect) {
                CGFloat dist1 = DistanceBetweenPoints(_c.pointOnRadius.position, result1.intersectionPoint);
                CGFloat dist2 = DistanceBetweenPoints(_c.pointOnRadius.position, result2.intersectionPoint);
                if (dist1 > dist2) {
                    intersection = result1.intersectionPoint;
                } else {
                    intersection = result2.intersectionPoint;
                }
            }
            
        }
    } else {
        //Normal case
        DHIntersectionResult result = IntersectionTestLineCircle(_l, _c, _preferEnd);
        if (result.intersect) {
            intersection = result.intersectionPoint;
        }
    }

    self.position = intersection;
}
@end


@implementation DHMidPoint
- (instancetype)initWithPoint1:(DHPoint*)p1 andPoint2:(DHPoint*)p2
{
    self = [super init];
    if (self) {
        _start = p1;
        _end = p2;
        [self updatePosition];
    }
    return self;
}
- (void)setStart:(DHPoint *)start
{
    _start = start;
    [self updatePosition];
}
- (void)setEnd:(DHPoint *)end
{
    _end = end;
    [self updatePosition];
}
-(void)updatePosition
{
    if (!_start || !_end) {
        self.position = CGPointMake(NAN, NAN);
        return;
    }
    
    self.position = MidPointFromPoints(self.start.position, self.end.position);
}
@end


@implementation DHTrianglePoint
- (instancetype)initWithPoint1:(DHPoint*)p1 andPoint2:(DHPoint*)p2
{
    self = [super init];
    if (self) {
        _start = p1;
        _end = p2;
        [self updatePosition];
    }
    return self;
}
- (void)setStart:(DHPoint *)start
{
    _start = start;
    [self updatePosition];
}
- (void)setEnd:(DHPoint *)end
{
    _end = end;
    [self updatePosition];
}
- (void)updatePosition
{
    if (!_start || !_end) {
        self.position = CGPointMake(NAN, NAN);
        return;
    }
    
    CGPoint startPoint = _start.position;
    CGPoint endPoint = _end.position;
    
    CGVector baseVector = CGVectorBetweenPoints(startPoint, endPoint);
    self.position = CGPointFromPointByAddingVector(startPoint, CGVectorRotateByAngle(baseVector, -M_PI/3));
}
@end


@implementation DHPointOnLine
- (instancetype)initWithLine:(DHLineObject*)line andTValue:(CGFloat)tValue;
{
    self = [super init];
    if (self) {
        _line = line;
        _tValue = tValue;
        [self updatePosition];
    }
    return self;
}
- (void)setLine:(DHLineObject *)line
{
    _line = line;
    [self updatePosition];
}
- (void)setTValue:(CGFloat)tValue
{
    _tValue = tValue;
    [self updatePosition];
}
- (void)updatePosition
{
    if (!self.line) {
        self.position = CGPointMake(NAN, NAN);
        return;
    }
    
    CGPoint p1 = self.line.start.position;
    CGPoint p2 = self.line.end.position;
    self.position = CGPointMake(p1.x + self.tValue * (p2.x - p1.x), p1.y + self.tValue * (p2.y - p1.y));
}
@end

@implementation DHPointOnCircle
- (instancetype)initWithCircle:(DHCircle *)circle andAngle:(CGFloat)angle
{
    self = [super init];
    if (self) {
        _circle = circle;
        _angle = angle;
        [self updatePosition];
    }
    return self;
}

- (void)setCircle:(DHCircle *)circle
{
    _circle = circle;
    [self updatePosition];
}
- (void)setAngle:(CGFloat)angle
{
    _angle = angle;
    [self updatePosition];
}
- (void)updatePosition
{
    if (!self.circle) {
        self.position = CGPointMake(NAN, NAN);
        return;
    }
    
    CGPoint center = self.circle.center.position;
    CGPoint onRadius = CGPointMake(center.x + self.circle.radius, center.y);
    CGVector toPoint = CGVectorRotateByAngle(CGVectorBetweenPoints(center, onRadius), self.angle);
    self.position = CGPointFromPointByAddingVector(center, toPoint);
}
@end


@implementation DHTranslatedPoint
- (instancetype)initWithPoint1:(DHPoint*)p1 andPoint2:(DHPoint*)p2 andOrigin:(DHPoint*)pO
{
    self = [super init];
    if (self) {
        _startOfTranslation = pO;
        _translationStart = p1;
        _translationEnd = p2;
        [self updatePosition];
    }
    return self;
}
- (instancetype)initStart:(DHPoint*)start end:(DHPoint*)end newStart:(DHPoint*)newStart
{
    self = [super init];
    if (self) {
        _startOfTranslation = newStart;
        _translationStart = start;
        _translationEnd = end;
    }
    return self;
}
- (void)setStartOfTranslation:(DHPoint *)startOfTranslation
{
    _startOfTranslation = startOfTranslation;
    [self updatePosition];
}
- (void)setTranslationStart:(DHPoint *)translationStart
{
    _translationStart = translationStart;
    [self updatePosition];
}
- (void)setTranslationEnd:(DHPoint *)translationEnd
{
    _translationEnd = translationEnd;
    [self updatePosition];
}
- (void)updatePosition
{
    CGVector translation = CGVectorBetweenPoints(self.translationStart.position, self.translationEnd.position);
    self.position = CGPointMake(self.startOfTranslation.position.x + translation.dx,
                                self.startOfTranslation.position.y + translation.dy);
}
@end


@implementation DHPointWithBlockConstraint {
    DHConstraintBlock _constraintBlock;
}

- (void)setConstraintBlock:(DHConstraintBlock)constraintBlock
{
    _constraintBlock = constraintBlock;
}

- (void)updatePosition
{
    if (_constraintBlock) {
        self.position = _constraintBlock();
    }
}

@end


#pragma mark - Line types

@implementation DHLineObject
- (CGVector)vector
{
    return CGVectorMake(self.end.position.x - self.start.position.x, self.end.position.y - self.start.position.y);
}
- (void)drawInContext:(CGContextRef)context withTransform:(DHGeometricTransform*)transform
{
    CGContextSaveGState(context);
    
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
    } else if(self.temporary) {
        CGContextSetLineDash(context,0,kDashPattern,kDashPatternItems);
        CGContextSetLineWidth(context, 1.0);
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
    
    CGContextRestoreGState(context);
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
- (instancetype)initWithLine:(DHLineObject*)line andPoint:(DHPoint*)point
{
    self = [self init];
    if (self) {
        self.line = line;
        self.point = point;
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


@implementation DHPerpendicularLine {
    DHPoint* _endPointCache;
}
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
- (instancetype)initWithLine:(DHLineObject*)line andPoint:(DHPoint*)point
{
    self = [self init];
    if (self) {
        self.line = line;
        self.point = point;
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


@implementation DHBisectLine {
    DHPoint* _startPointCache;
    DHPoint* _endPointCache;
    CGPoint _line1StartCache;
    CGPoint _line1EndCache;
    CGPoint _line2StartCache;
    CGPoint _line2EndCache;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tMin = -INFINITY;// 1000.0;
        self.tMax = INFINITY; //1000.0;
        _startPointCache = [[DHPoint alloc] initWithPositionX:NAN andY:NAN];
        _endPointCache = [[DHPoint alloc] initWithPositionX:NAN andY:NAN];
        _line1StartCache = CGPointMake(NAN, NAN);
        _line1EndCache = CGPointMake(NAN, NAN);
        _line2StartCache = CGPointMake(NAN, NAN);
        _line2EndCache = CGPointMake(NAN, NAN);
    }
    return self;
}
- (instancetype)initWithLine:(DHLineObject*)l1 andLine:(DHLineObject*)l2
{
    self = [self init];
    if (self) {
        _line1 = l1;
        _line2 = l2;
    }
    return self;
}
- (DHPoint*)start
{
    // First, check if the assigned lines share a point, if so, use it
    if (self.line1.start == self.line2.start || self.line1.start == self.line2.end) return self.line1.start;
    if (self.line1.end == self.line2.start || self.line1.end == self.line2.end) return self.line1.end;
    
    // If lines have not moved since caching intersection point, no need to recalculate intersection
    if (CGPointEqualToPoint(_line1StartCache, self.line1.start.position) &&
        CGPointEqualToPoint(_line1EndCache, self.line1.end.position) &&
        CGPointEqualToPoint(_line2StartCache, self.line2.start.position) &&
        CGPointEqualToPoint(_line2EndCache, self.line2.end.position)) {
        return _startPointCache;
    }
    
    DHIntersectionResult r = IntersectionTestLineLine(self.line1, self.line2);
    if (r.intersect) {
        _startPointCache.position = r.intersectionPoint;
        _line1StartCache = self.line1.start.position;
        _line1EndCache = self.line1.end.position;
        _line2StartCache = self.line2.start.position;
        _line2EndCache = self.line2.end.position;
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
    
    // If defined by two line segments sharing an end point, ensure to provide inner bisector
    if ([_line1 isKindOfClass:[DHLineSegment class]] && [_line2 isKindOfClass:[DHLineSegment class]]) {
        if (_line1.start == _line2.end) {
            v2 = CGVectorInvert(v2);
        }
        if (_line2.start == _line1.end) {
            v1 = CGVectorInvert(v1);
        }
        if (_line1.end == _line2.end) {
            v1 = CGVectorInvert(v1);
            v2 = CGVectorInvert(v2);
        }
    }
    
    _endPointCache.position = CGPointMake(startPos.x + v1.dx + v2.dx, startPos.y + v1.dy + v2.dy);
    return _endPointCache;
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


#pragma mark - Cicle

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
- (instancetype)initWithCenter:(DHPoint*)center andRadius:(CGFloat)radius
{
    self = [super init];
    if (self) {
        self.center = center;
        self.pointOnRadius = [[DHPoint alloc]initWithPositionX:self.center.position.x + radius andY:self.center.position.y];
    }
    return self;
}
- (void)drawInContext:(CGContextRef)context withTransform:(DHGeometricTransform*)transform
{
    CGContextSaveGState(context);
    
    CGFloat geoRadius = self.radius;
    CGPoint geoCenterPosition = self.center.position;
    
    // Do nothing if any part of the circle is undefined
    if (isnan(geoRadius) || isnan(geoCenterPosition.x) || isnan(geoCenterPosition.y)) {
        return;
    }
    
    CGFloat radius = geoRadius * [transform scale];
    CGPoint position = [transform geoToView:geoCenterPosition];
    
    CGRect rect = CGRectMake(position.x - radius, position.y - radius, radius*2, radius*2);
    
    if (self.highlighted) {
        CGContextSetLineWidth(context, 3.0);
        CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
        CGContextSetRGBStrokeColor(context, kLineColorHighlighted.r, kLineColorHighlighted.g,
                                   kLineColorHighlighted.b, kLineColorHighlighted.a);
    } else if(self.temporary) {
        CGContextSetLineDash(context,0,kDashPattern,kDashPatternItems);
        CGContextSetLineWidth(context, 1.0);
        CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
        CGContextSetRGBStrokeColor(context, kLineColorHighlighted.r, kLineColorHighlighted.g,
                                   kLineColorHighlighted.b, kLineColorHighlighted.a);
    } else {
        CGContextSetLineWidth(context, 1.0);
        CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
        CGContextSetRGBStrokeColor(context, kLineColor.r, kLineColor.g, kLineColor.b, kLineColor.a);
    }
    CGContextStrokeEllipseInRect(context, rect);
    
    CGContextRestoreGState(context);
}
- (CGFloat)radius
{
    return DistanceBetweenPoints(_center.position, _pointOnRadius.position);
}
@end

#pragma mark - Visual indicators

@implementation DHAngleIndicator
- (instancetype)initWithLine1:(DHLineObject *)line1 line2:(DHLineObject *)line2 andRadius:(CGFloat)radius
{
    self = [super init];
    if (self) {
        _line1 = line1;
        _line2 = line2;
        _radius = radius;
    }
    return self;
}
- (void)drawInContext:(CGContextRef)context withTransform:(DHGeometricTransform*)transform
{
    CGContextSaveGState(context);
    
    CGFloat geoRadius = self.radius;
    CGPoint geoCenterPosition = [self center];
    
    // Do nothing if any part of the circle is undefined
    if (isnan(geoRadius) || isnan(geoCenterPosition.x) || isnan(geoCenterPosition.y)) {
        return;
    }
    
    CGFloat radius = geoRadius; // * [transform scale];
    CGPoint position = [transform geoToView:geoCenterPosition];
    
    CGFloat startAngle = 0;
    CGFloat endAngle = 0;
    
    if (_anglePosition == 0) {
        startAngle = CGVectorAngle(_line1.vector);
        endAngle = CGVectorAngle(_line2.vector);
    }
    if (_anglePosition == 1) {
        startAngle = CGVectorAngle(CGVectorInvert(_line1.vector));
        endAngle = CGVectorAngle(CGVectorInvert(_line2.vector));
    }
    if (_anglePosition == 2) {
        startAngle = CGVectorAngle(_line1.vector);
        endAngle = CGVectorAngle(CGVectorInvert(_line2.vector));
    }
    if (_anglePosition == 3) {
        startAngle = CGVectorAngle(CGVectorInvert(_line1.vector));
        endAngle = CGVectorAngle(_line2.vector);
    }
    if (endAngle <= 0) {
        startAngle += 2*M_PI;
        endAngle += 2*M_PI;
    }
    if (startAngle>endAngle) {
        CGFloat startTemp = startAngle;
        startAngle = endAngle;
        endAngle = startTemp;
    }
    if (_alwaysInner && (endAngle - startAngle) > M_PI) {
        CGFloat startTemp = startAngle;
        startAngle = endAngle;
        endAngle = startTemp+2*M_PI;
    }
    
    CGFloat angle = fabs((endAngle-startAngle) / M_PI * 180.0);
    
    if (self.squareRightAngles && fabs(angle-90.0)<1) {
        CGContextSetRGBStrokeColor(context, 0.4, 0.4, 0.4, 1.0);
        CGContextSetLineWidth(context, 1.0);
        
        CGVector vCS = CGVectorRotateByAngle(CGVectorMake(radius, 0), startAngle);
        CGVector vCCorner;
        if (startAngle < endAngle) {
            vCCorner = CGVectorMultiplyByScalar(CGVectorRotateByAngle(vCS, M_PI/4),sqrt(2));
        } else {
            vCCorner = CGVectorMultiplyByScalar(CGVectorRotateByAngle(vCS, -M_PI/4),sqrt(2));
        }
        CGVector vCE = CGVectorRotateByAngle(CGVectorMake(radius, 0), endAngle);
        CGPoint pStart = CGPointFromPointByAddingVector(position, vCS);
        CGPoint pCorner = CGPointFromPointByAddingVector(position, vCCorner);
        CGPoint pEnd = CGPointFromPointByAddingVector(position, vCE);
        
        CGContextMoveToPoint(context, pStart.x, pStart.y);
        CGContextAddLineToPoint(context, pCorner.x, pCorner.y);
        CGContextAddLineToPoint(context, pEnd.x, pEnd.y);
        CGContextStrokePath(context);
    } else {
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        
        // Create our arc, with the correct angles
        [bezierPath addArcWithCenter:position
                              radius:radius
                          startAngle:startAngle
                            endAngle:endAngle
                           clockwise:YES];
        
        //[[UIColor lightGrayColor] setStroke];
        [[UIColor colorWithWhite:0.4 alpha:1] setStroke];
        CGContextAddPath(context, bezierPath.CGPath);
        CGContextSetLineWidth(context, 1.0);
        CGContextStrokePath(context);
    }
    
    CGContextRestoreGState(context);
    
    if (self.label || self.showAngleText) {
        NSString* labelString;
        if (self.label && !self.showAngleText) {
            labelString = self.label;
        } else if (!self.label && self.showAngleText) {
            labelString = [NSString stringWithFormat:@"%.0f°", angle];
        } else {
            labelString = [NSString stringWithFormat:@"%@: %.0f°", self.label, angle];
        }
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        CGVector v = CGVectorMake(radius+15, 0);
        v = CGVectorRotateByAngle(v, (startAngle+endAngle)*0.5);
        CGPoint labelCenter = CGPointFromPointByAddingVector(position, v);
        
        NSDictionary* attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:11],
                                     NSParagraphStyleAttributeName: paragraphStyle,
                                     NSForegroundColorAttributeName: [UIColor darkGrayColor]};
        CGSize textSize = [labelString sizeWithAttributes:attributes];
        CGRect labelRect = CGRectMake(labelCenter.x - textSize.width*0.5,
                                      labelCenter.y - textSize.height*0.5,
                                      textSize.width, textSize.height);
        [labelString drawInRect:labelRect withAttributes:attributes];
    }
}
- (CGPoint)center
{
    // First, check if the assigned lines share a point, if so, use it
    if (self.line1.start == self.line2.start || self.line1.start == self.line2.end) return self.line1.start.position;
    if (self.line1.end == self.line2.start || self.line1.end == self.line2.end) return self.line1.end.position;
    
    DHIntersectionResult r = IntersectionTestLineLine(self.line1, self.line2);
    if (r.intersect) {
        return r.intersectionPoint;
    }
    
    return CGPointMake(NAN, NAN);
}
- (CGFloat)angle
{
    CGVector v1 = CGVectorNormalize(self.line1.vector);
    CGVector v2 = CGVectorNormalize(self.line2.vector);
    
    // If defined by two line segments sharing an end point, ensure to provide inner bisector
    if ([_line1 isKindOfClass:[DHLineSegment class]] && [_line2 isKindOfClass:[DHLineSegment class]]) {
        if (_line1.start == _line2.end) {
            v2 = CGVectorInvert(v2);
        }
        if (_line2.start == _line1.end) {
            v1 = CGVectorInvert(v1);
        }
        if (_line1.end == _line2.end) {
            v1 = CGVectorInvert(v1);
            v2 = CGVectorInvert(v2);
        }
    }
    
    return CGVectorAngleBetween(v1, v2);
}

@end