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
- (void)drawInContext:(CGContextRef)context;
@end

@interface DHGeometricObject : NSObject

@property (nonatomic) NSUInteger id;
@property (nonatomic) BOOL highlighted;

@end

@interface DHPoint : DHGeometricObject <DHGeometricObject>
@property (nonatomic, strong) NSString* label;
@property (nonatomic) CGPoint position;
- (instancetype) initWithPositionX:(CGFloat)x andY:(CGFloat)y;
- (void)drawInContext:(CGContextRef)context;
@end


@interface DHLine : DHGeometricObject <DHGeometricObject>
@property (nonatomic, weak) DHPoint* start;
@property (nonatomic, weak) DHPoint* end;
@property (nonatomic, readonly) CGFloat length;
@property (nonatomic, readonly) CGVector vector;

- (void)drawInContext:(CGContextRef)context;
@end


@interface DHCircle : DHGeometricObject <DHGeometricObject>
@property (nonatomic, weak) DHPoint* center;
@property (nonatomic, weak) DHPoint* pointOnRadius;
@property (nonatomic, readonly) CGFloat radius;
- (void)drawInContext:(CGContextRef)context;
@end


@interface DHIntersectionPointCircleCircle : DHPoint
@property (nonatomic) DHCircle* c1;
@property (nonatomic) DHCircle* c2;
@property (nonatomic) BOOL onPositiveY;

- (CGPoint)position;
- (void)drawInContext:(CGContextRef)context;
@end

@interface DHIntersectionPointLineLine : DHPoint
@property (nonatomic) DHLine* l1;
@property (nonatomic) DHLine* l2;

- (CGPoint)position;
- (void)drawInContext:(CGContextRef)context;
@end


@interface DHIntersectionPointLineCircle : DHPoint
@property (nonatomic) DHLine* l;
@property (nonatomic) DHCircle* c;
@property (nonatomic) BOOL preferEnd;

- (CGPoint)position;
- (void)drawInContext:(CGContextRef)context;
@end

@interface DHMidPoint : DHPoint
@property (nonatomic) DHPoint* start;
@property (nonatomic) DHPoint* end;

- (CGPoint)position;
- (void)drawInContext:(CGContextRef)context;
@end


@interface DHPointOnLine : DHPoint
@property (nonatomic, weak) DHLine* line;
@property (nonatomic) CGFloat tValue; // Value between 0 and 1 indicating distance from start to end

- (CGPoint)position;
- (void)drawInContext:(CGContextRef)context;
@end


@interface DHRay : DHGeometricObject <DHGeometricObject>
@property (nonatomic) DHPoint* start;
@property (nonatomic) DHPoint* direction;
@property (nonatomic) NSUInteger id;
@property (nonatomic) BOOL highlighted;

- (void)drawInContext:(CGContextRef)context;
@end