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
@property NSUInteger progress;

@end
