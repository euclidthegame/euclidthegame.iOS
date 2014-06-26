//
//  DHGeometricObjects.h
//  Principia
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;

@protocol DHGeometricObject <NSObject>
@property (nonatomic) BOOL highlighted;
- (void)drawInContext:(CGContextRef)context;
@end


@interface DHPoint : NSObject <DHGeometricObject>
@property (nonatomic) CGPoint position;
@property (nonatomic) BOOL highlighted;
- (instancetype) initWithPositionX:(CGFloat)x andY:(CGFloat)y;
- (void)drawInContext:(CGContextRef)context;
@end


@interface DHLine : NSObject <DHGeometricObject>
@property (nonatomic, weak) DHPoint* start;
@property (nonatomic, weak) DHPoint* end;
@property (nonatomic) BOOL highlighted;
@property (nonatomic, readonly) CGFloat length;
- (void)drawInContext:(CGContextRef)context;
@end


@interface DHCircle : NSObject <DHGeometricObject>
@property (nonatomic, weak) DHPoint* center;
@property (nonatomic, weak) DHPoint* pointOnRadius;
@property (nonatomic, readonly) CGFloat radius;
@property (nonatomic) BOOL highlighted;
- (void)drawInContext:(CGContextRef)context;
@end


@interface DHIntersectionPointCircleCircle : DHPoint
@property (nonatomic) DHCircle* c1;
@property (nonatomic) DHCircle* c2;
@property (nonatomic) BOOL highlighted;
@property (nonatomic) BOOL onPositiveY;
@property (nonatomic, readonly) CGPoint position;
- (void)drawInContext:(CGContextRef)context;
@end

@interface DHIntersectionPointLineLine : DHPoint
@property (nonatomic) DHLine* l1;
@property (nonatomic) DHLine* l2;
@property (nonatomic) BOOL highlighted;

- (CGPoint)position;
- (void)drawInContext:(CGContextRef)context;
@end


@interface DHIntersectionPointLineCircle : DHPoint
@property (nonatomic) DHLine* l;
@property (nonatomic) DHCircle* c;
@property (nonatomic) BOOL highlighted;

- (CGPoint)position;
- (void)drawInContext:(CGContextRef)context;
@end