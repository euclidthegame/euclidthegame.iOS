//
//  DHGeometryView.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <UIKit/UIKit.h>
#import "DHGeometricObjects.h"
#import "DHGeometricTransform.h"

@interface DHGeometryView : UIView

@property (nonatomic, strong) NSMutableArray* geometricObjects;
@property (nonatomic, strong) NSMutableArray* temporaryGeometricObjects;
@property (nonatomic) BOOL hideBorder;
@property (nonatomic) BOOL hideBottomBorder;
@property (nonatomic, strong) DHGeometricTransform* geoViewTransform;
@property (nonatomic) BOOL keepContentCenteredAndZoomedIn;
- (instancetype)initWithObjects:(NSArray*)objects andSuperView:(DHGeometryView*)geometryView;
- (instancetype)initWithObjects:(NSArray*)objects supView:(DHGeometryView*)geometryView addTo:(UIView*)view;
- (instancetype)initWithObjects:(NSArray*)objects andSuperView:(UIView*)view andGeometryView:(DHGeometryView*)geometryView;
- (CGPoint)getCenterInGeoCoordinates;
- (void)centerOnGeoCoordinate:(CGPoint)geoCoord;
- (void)centerContent;

@end