//
//  DHGeometryView.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHGeometricObjects.h"
#import "DHGeometricTransform.h"

@interface DHGeometryView : UIView

@property (nonatomic, strong) NSMutableArray* geometricObjects;
//@property (nonatomic) CGFloat geometryScale;
//@property (nonatomic) CGPoint geometryOffset;
@property (nonatomic) BOOL hideBorder;
@property (nonatomic, strong) DHGeometricTransform* geoViewTransform;
@property (nonatomic) BOOL keepContentCenteredAndZoomedIn;

@end