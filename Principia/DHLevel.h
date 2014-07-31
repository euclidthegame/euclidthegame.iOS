//
//  DHLevel.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHGeometricObjects.h"
#import "DHGeometricTools.h"
#import "DHMath.h"


@protocol DHLevel <NSObject>

@required
- (NSString*)subTitle;
- (NSString*)levelDescription;
- (void)createInitialObjects:(NSMutableArray*)geometricObjects;
- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects;
- (NSUInteger)minimumNumberOfMoves;

@optional
- (DHToolsAvailable)availableTools;
- (NSString*)additionalCompletionMessage;
- (void)createSolutionPreviewObjects:(NSMutableArray*)objects;
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly;
- (CGPoint)testObjectsForProgressHints:(NSArray*)objects;
- (void)tutorial:(NSMutableArray*)geometricObjects and:(UISegmentedControl*)toolControl and:(UILabel*)toolInstructions and:(UIView*)geometryView and:(UIView*)view and:(NSLayoutConstraint*)heighToolControl and:(BOOL)update;
- (void)animation:(NSMutableArray*)geometricObjects and:(UISegmentedControl*)toolControl and:(UILabel*)toolInstructions and:(UIView*)geometryView and:(UIView*)view;
@end

@interface DHLevel : NSObject
@property NSUInteger progress;

@end