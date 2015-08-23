//
//  DHGeometricTransform.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-10.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;

@interface DHGeometricTransform : NSObject
- (CGFloat)scale;
- (CGPoint)offset;
- (void)setScale:(CGFloat)scale;
- (void)setOffset:(CGPoint)offset;
- (void)offsetWithVector:(CGPoint)offset;
- (CGPoint)viewToGeo:(CGPoint)point;
- (CGPoint)geoToView:(CGPoint)point;
- (void)zoomAtPoint:(CGPoint)center scale:(CGFloat)scale;
- (void)rotateBy:(CGFloat)angle;
- (void)setRotation:(CGFloat)angle;
@end