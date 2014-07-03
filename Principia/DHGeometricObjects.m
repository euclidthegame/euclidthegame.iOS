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
        _label = [DHGeometricObjectLabeler nextLabel];
    }
    
    return self;
}

- (instancetype) initWithPositionX:(CGFloat)x andY:(CGFloat)y
{
    self = [super init];
    
    if (self) {
        _position = CGPointMake(x, y);
        _label = [DHGeometricObjectLabeler nextLabel];
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
        CGRect labelRect = CGRectMake(self.position.x - textSize.width*0.5f,
                                      self.position.y - pointWidth*0.5f - 5 - textSize.height,
                                      textSize.width, textSize.height);
        [self.label drawInRect:labelRect withAttributes:attributes];

    }
}
@end

@implementation DHLine
- (CGFloat)length
{
    return DistanceBetweenPoints(_start.position, _end.position);
}
- (CGVector)vector
{
    return CGVectorMake(_end.position.x - _start.position.x, _end.position.y - _start.position.y);
}
- (void)drawInContext:(CGContextRef)context
{
    //CGFloat pointWidth = 10.0f;
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);

    CGContextMoveToPoint(context, self.start.position.x, self.start.position.y);
    CGContextAddLineToPoint(context, self.end.position.x, self.end.position.y);
    CGContextStrokePath(context);
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
    
    CGPoint p1 = self.l1.start.position;
    CGPoint p2 = self.l1.end.position;
    CGPoint p3 = self.l2.start.position;
    CGPoint p4 = self.l2.end.position;
    
    // Ensure intersection through checking winding of triangles
    CGFloat a1 = Signed2DTriArea(p1, p2, p4);
    CGFloat a2 = Signed2DTriArea(p1, p2, p3);
    if (a1 * a2 < 0) {
        CGFloat a3 = Signed2DTriArea(p3, p4, p1);
        CGFloat a4 = a3 + a2 - a1;
        
        if (a3 * a4 < 0.0f) {
            CGFloat t = a3 / (a3 - a4);
            intersection.x = p1.x + t * (p2.x - p1.x);
            intersection.y = p1.y + t * (p2.y - p1.y);
        }
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
- (void)drawInContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1.0);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
    
    CGPoint endPoint;
    endPoint.x = self.start.position.x + 1000*(self.direction.position.x - self.start.position.x);
    endPoint.y = self.start.position.y + 1000*(self.direction.position.y - self.start.position.y);
    
    CGContextMoveToPoint(context, self.start.position.x, self.start.position.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
}
@end