//
//  DHGeometricTools.h
//  Principia
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHGeometricObjects.h"

typedef NS_OPTIONS(NSUInteger, DHToolsAvailable)
{
    DHPointToolAvailable = 1 << 0,
    DHLineToolAvailable = 1 << 1,
    DHRayToolAvailable = 1 << 2,
    DHCircleToolAvailable = 1 << 3,
    DHIntersectToolAvailable = 1 << 4,
    DHMidpointToolAvailable = 1 << 5,
    DHMoveToolAvailable = 1 << 6,
    DHAllToolsAvailable = NSUIntegerMax
};


@protocol DHGeometryToolDelegate <NSObject>
- (NSArray*)geometryObjects;
- (void)toolTipDidChange:(NSString*)currentTip;
- (void)addNewGeometricObject:(id)object;
@end


@protocol DHGeometryTool <NSObject>
@property (nonatomic, weak) id<DHGeometryToolDelegate> delegate;
- (NSString*)initialToolTip;
- (void)touchBegan:(UITouch*)touch;
- (void)touchMoved:(UITouch*)touch;
- (void)touchEnded:(UITouch*)touch;
@end


@interface DHPointTool : NSObject <DHGeometryTool>
@property (nonatomic, weak) id<DHGeometryToolDelegate> delegate;
- (NSString*)initialToolTip;
- (void)touchBegan:(UITouch*)touch;
- (void)touchMoved:(UITouch*)touch;
- (void)touchEnded:(UITouch*)touch;
@end


@interface DHLineTool : NSObject <DHGeometryTool>
@property (nonatomic, weak) id<DHGeometryToolDelegate> delegate;
- (NSString*)initialToolTip;
- (void)touchBegan:(UITouch*)touch;
- (void)touchMoved:(UITouch*)touch;
- (void)touchEnded:(UITouch*)touch;

@property (nonatomic, weak) DHPoint* startPoint;
@end


@interface DHCircleTool : NSObject <DHGeometryTool>
@property (nonatomic, weak) id<DHGeometryToolDelegate> delegate;
- (NSString*)initialToolTip;
- (void)touchBegan:(UITouch*)touch;
- (void)touchMoved:(UITouch*)touch;
- (void)touchEnded:(UITouch*)touch;

@property (nonatomic, weak) DHPoint* center;
@end

@interface DHIntersectTool : NSObject <DHGeometryTool>
@property (nonatomic, weak) id<DHGeometryToolDelegate> delegate;
- (NSString*)initialToolTip;
- (void)touchBegan:(UITouch*)touch;
- (void)touchMoved:(UITouch*)touch;
- (void)touchEnded:(UITouch*)touch;
@end

@interface DHMoveTool : NSObject <DHGeometryTool>
@property (nonatomic, weak) id<DHGeometryToolDelegate> delegate;
- (NSString*)initialToolTip;
- (void)touchBegan:(UITouch*)touch;
- (void)touchMoved:(UITouch*)touch;
- (void)touchEnded:(UITouch*)touch;

@property (nonatomic, weak) DHPoint* point;
@property (nonatomic) CGPoint touchStart;
@end

@interface DHMidPointTool : NSObject <DHGeometryTool>
@property (nonatomic, weak) id<DHGeometryToolDelegate> delegate;
- (NSString*)initialToolTip;
- (void)touchBegan:(UITouch*)touch;
- (void)touchMoved:(UITouch*)touch;
- (void)touchEnded:(UITouch*)touch;

@property (nonatomic, weak) DHPoint* startPoint;
@end

@interface DHRayTool : NSObject <DHGeometryTool>
@property (nonatomic, weak) id<DHGeometryToolDelegate> delegate;
- (NSString*)initialToolTip;
- (void)touchBegan:(UITouch*)touch;
- (void)touchMoved:(UITouch*)touch;
- (void)touchEnded:(UITouch*)touch;

@property (nonatomic, weak) DHPoint* startPoint;
@end