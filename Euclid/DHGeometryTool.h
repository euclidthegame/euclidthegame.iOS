//
//  DHGeometryTool.h
//  Euclid
//
//  Created by David Hallgren on 2014-08-06.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <Foundation/Foundation.h>
#import "DHGeometricTransform.h"

@protocol DHGeometryToolDelegate <NSObject>
- (NSArray*)geometryObjects;
- (DHGeometricTransform*)geoViewTransform;
- (void)toolTipDidChange:(NSString*)currentTip;
- (void)addGeometricObject:(id)object;
- (void)addGeometricObjects:(NSArray*)objects;
- (void)addTemporaryGeometricObjects:(NSArray*)objects;
- (void)removeTemporaryGeometricObjects:(NSArray *)objects;
- (void)showTemporaryMessage:(NSString*)message atPoint:(CGPoint)point withColor:(UIColor*)color;
- (void)updateAllPositions;
@end


@protocol DHGeometryTool <NSObject>
@property (nonatomic, weak) id<DHGeometryToolDelegate> delegate;
@property (nonatomic) intptr_t associatedTouch;
- (NSString*)initialToolTip;
- (void)touchBegan:(UITouch*)touch;
- (void)touchMoved:(UITouch*)touch;
- (void)touchEnded:(UITouch*)touch;
- (BOOL)active;
- (void)reset;
@end

@interface DHGeometryTool : NSObject
@property (nonatomic, weak) id<DHGeometryToolDelegate> delegate;
@property (nonatomic) intptr_t associatedTouch;
@end
