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
@end


@interface DHLineObject : DHGeometricObject <DHGeometricObject>
@property (nonatomic, weak) DHPoint* start;
@property (nonatomic, weak) DHPoint* end;
@property (nonatomic, readonly) CGVector vector;
@property (nonatomic) CGFloat tMin;
@property (nonatomic) CGFloat tMax;
@end


@interface DHLineSegment : DHLineObject <DHGeometricObject>
@property (nonatomic, readonly) CGFloat length;
@end


@interface DHLine : DHLineObject <DHGeometricObject>
@end


@interface DHRay : DHLineObject <DHGeometricObject>
@end


@interface DHCircle : DHGeometricObject <DHGeometricObject>
@property (nonatomic, weak) DHPoint* center;
@property (nonatomic, strong) DHPoint* pointOnRadius;
@property (nonatomic, readonly) CGFloat radius;
@end


@interface DHIntersectionPointCircleCircle : DHPoint
@property (nonatomic) DHCircle* c1;
@property (nonatomic) DHCircle* c2;
@property (nonatomic) BOOL onPositiveY;

- (CGPoint)position;
@end


@interface DHIntersectionPointLineLine : DHPoint
@property (nonatomic) DHLineObject* l1;
@property (nonatomic) DHLineObject* l2;

- (CGPoint)position;
@end


@interface DHIntersectionPointLineCircle : DHPoint
@property (nonatomic) DHLineObject* l;
@property (nonatomic) DHCircle* c;
@property (nonatomic) BOOL preferEnd;
- (CGPoint)position;
@end


@interface DHTranslatedPoint : DHPoint
@property (nonatomic, strong) DHPoint* startOfTranslation;
@property (nonatomic, strong) DHPoint* translationStart;
@property (nonatomic, strong) DHPoint* translationEnd;
@end


@interface DHMidPoint : DHPoint
@property (nonatomic) DHPoint* start;
@property (nonatomic) DHPoint* end;
- (CGPoint)position;
@end


@interface DHTrianglePoint : DHPoint
@property (nonatomic) DHPoint* start;
@property (nonatomic) DHPoint* end;
- (CGPoint)position;
@end


@interface DHPointOnLine : DHPoint
@property (nonatomic, weak) DHLineObject* line;
@property (nonatomic) CGFloat tValue; // Value between 0 and 1 indicating distance from start to end
- (CGPoint)position;
@end


@interface DHBisectLine : DHLineObject
@property (nonatomic, weak) DHLineObject* line1;
@property (nonatomic, weak) DHLineObject* line2;
@end


@interface DHPerpendicularLine : DHLineObject
@property (nonatomic, weak) DHLineObject* line;
@property (nonatomic, weak) DHPoint* point;
@end

@interface DHParallelLine : DHLineObject
@property (nonatomic, weak) DHLineObject* line;
@property (nonatomic, weak) DHPoint* point;
@end

@interface DHTranslatedLine : DHLineObject
@property (nonatomic, weak) DHLineSegment* line;
@property (nonatomic, weak) DHPoint* point;
@end





