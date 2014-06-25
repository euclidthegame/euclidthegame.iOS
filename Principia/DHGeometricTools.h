//
//  DHGeometricTools.h
//  Principia
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHGeometricObjects.h"


@interface DHGeometricTools : NSObject

@end

@interface DHLineTool : NSObject
@property (nonatomic, weak) DHPoint* startPoint;
@end

@interface DHCircleTool : NSObject
@property (nonatomic, weak) DHPoint* center;
@end

@interface DHIntersectTool : NSObject

@end

@interface DHMoveTool : NSObject
@property (nonatomic, weak) DHPoint* point;
@property (nonatomic) CGPoint touchStart;
@end