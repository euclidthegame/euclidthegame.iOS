//
//  DHGeometricObjects.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;
#import "DHGeometricTransform.h"

@protocol DHGeometricObject <NSObject>
- (void)drawInContext:(CGContextRef)context withTransform:(DHGeometricTransform*)transform;
@end


@interface DHGeometricObject : NSObject
@property (nonatomic) NSUInteger id;
@property (nonatomic) BOOL highlighted;
@property (nonatomic) BOOL temporary;
@property (nonatomic) CGFloat drawScale;
@end


@interface DHPoint : DHGeometricObject <DHGeometricObject>
@property (nonatomic, strong) NSString* label;
@property (nonatomic) CGPoint position;
@property (nonatomic) BOOL updatesPositionAutomatically;
- (instancetype) initWithPositionX:(CGFloat)x andY:(CGFloat)y;
- (instancetype) initWithPosition:(CGPoint)position;
- (void)updatePosition;
@end


@interface DHLineObject : DHGeometricObject <DHGeometricObject>
@property (nonatomic, strong) DHPoint* start;
@property (nonatomic, strong) DHPoint* end;
@property (nonatomic, readonly) CGVector vector;
@property (nonatomic) CGFloat tMin;
@property (nonatomic) CGFloat tMax;
@end


@interface DHLineSegment : DHLineObject <DHGeometricObject>
@property (nonatomic, readonly) CGFloat length;
- (instancetype)initWithStart:(DHPoint*)start andEnd:(DHPoint*)end;
@end


@interface DHLine : DHLineObject <DHGeometricObject>
- (instancetype)initWithStart:(DHPoint*)start andEnd:(DHPoint*)end;
@end


@interface DHRay : DHLineObject <DHGeometricObject>
- (instancetype)initWithStart:(DHPoint*)start andEnd:(DHPoint*)end;
@end


@interface DHCircle : DHGeometricObject <DHGeometricObject>
@property (nonatomic, strong) DHPoint* center;
@property (nonatomic, strong) DHPoint* pointOnRadius;
@property (nonatomic, readonly) CGFloat radius;
- (instancetype)initWithCenter:(DHPoint*)center andPointOnRadius:(DHPoint*)pointOnRadius;
- (instancetype)initWithCenter:(DHPoint*)center andRadius:(CGFloat)radius;
@end


@interface DHIntersectionPointCircleCircle : DHPoint
@property (nonatomic) DHCircle* c1;
@property (nonatomic) DHCircle* c2;
@property (nonatomic) BOOL onPositiveY;
- (instancetype)initWithCircle1:(DHCircle*)c1 andCircle2:(DHCircle*)c2 onPositiveY:(BOOL)onPositiveY;
@end


@interface DHIntersectionPointLineLine : DHPoint
@property (nonatomic,strong) DHLineObject* l1;
@property (nonatomic,strong) DHLineObject* l2;
- (instancetype)initWithLine:(DHLineObject*)l1 andLine:(DHLineObject*)l2;
@end


@interface DHIntersectionPointLineCircle : DHPoint
@property (nonatomic) DHLineObject* l;
@property (nonatomic) DHCircle* c;
@property (nonatomic) BOOL preferEnd;
- (instancetype)initWithLine:(DHLineObject*)l andCircle:(DHCircle*)c andPreferEnd:(BOOL)preferEnd;
@end


@interface DHTranslatedPoint : DHPoint
@property (nonatomic, strong) DHPoint* startOfTranslation;
@property (nonatomic, strong) DHPoint* translationStart;
@property (nonatomic, strong) DHPoint* translationEnd;
- (instancetype)initWithPoint1:(DHPoint*)p1 andPoint2:(DHPoint*)p2 andOrigin:(DHPoint*)pO;
- (instancetype)initStart:(DHPoint*)start end:(DHPoint*)end newStart:(DHPoint*)newStart;
@end


@interface DHMidPoint : DHPoint
- (instancetype)initWithPoint1:(DHPoint*)p1 andPoint2:(DHPoint*)p2;
@property (nonatomic) DHPoint* start;
@property (nonatomic) DHPoint* end;
@end


@interface DHTrianglePoint : DHPoint
@property (nonatomic) DHPoint* start;
@property (nonatomic) DHPoint* end;
- (instancetype)initWithPoint1:(DHPoint*)p1 andPoint2:(DHPoint*)p2;
@end


@interface DHPointOnLine : DHPoint
@property (nonatomic, strong) DHLineObject* line;
@property (nonatomic) CGFloat tValue; // Value between 0 and 1 indicating distance from start to end
@property (nonatomic) BOOL hideBorder;
- (instancetype)initWithLine:(DHLineObject*)line andTValue:(CGFloat)tValue;
@end

@interface DHPointOnCircle : DHPoint
@property (nonatomic, strong) DHCircle* circle;
@property (nonatomic) CGFloat angle; // Angle of rotation from positive x-axis to point
@property (nonatomic) BOOL hideBorder;
- (instancetype)initWithCircle:(DHCircle*)circle andAngle:(CGFloat)angle;
@end

typedef CGPoint(^DHConstraintBlock)();
@interface DHPointWithBlockConstraint : DHPoint
- (void)setConstraintBlock:(DHConstraintBlock)constraintBlock;
@end


@interface DHBisectLine : DHLineObject
@property (nonatomic, strong) DHLineObject* line1;
@property (nonatomic, strong) DHLineObject* line2;
- (instancetype)initWithLine:(DHLineObject*)l1 andLine:(DHLineObject*)l2;
@end


@interface DHPerpendicularLine : DHLineObject
@property (nonatomic, strong) DHLineObject* line;
@property (nonatomic, strong) DHPoint* point;
- (instancetype)initWithLine:(DHLineObject*)line andPoint:(DHPoint*)point;
@end

@interface DHParallelLine : DHLineObject
@property (nonatomic, strong) DHLineObject* line;
@property (nonatomic, strong) DHPoint* point;
- (instancetype)initWithLine:(DHLineObject*)line andPoint:(DHPoint*)point;
@end

@interface DHAngleIndicator : DHGeometricObject <DHGeometricObject>
@property (nonatomic, strong) DHLineObject* line1;
@property (nonatomic, strong) DHLineObject* line2;
@property (nonatomic, copy) NSString* label;
@property (nonatomic) CGFloat radius;
@property (nonatomic) NSUInteger anglePosition;
@property (nonatomic) BOOL showAngleText;
@property (nonatomic) BOOL squareRightAngles;
@property (nonatomic) BOOL alwaysInner;
- (instancetype)initWithLine1:(DHLineObject*)line1 line2:(DHLineObject*)line2 andRadius:(CGFloat)radius;
@end





