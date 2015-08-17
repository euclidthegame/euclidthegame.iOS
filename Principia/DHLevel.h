//
//  DHLevel.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <Foundation/Foundation.h>
#import "DHGeometricObjects.h"
#import "DHGeometricTools.h"
#import "DHMath.h"
#import "DHGeometryView.h"
#import "Message.h"

@class DHLevelViewController;

@protocol DHLevel <NSObject>

@required
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
- (void)tutorial:(NSMutableArray*)geometricObjects and:(UISegmentedControl*)toolControl and:(UILabel*)toolInstructions and:(DHGeometryView*)geometryView and:(UIView*)view and:(NSLayoutConstraint*)heighToolControl and:(BOOL)update;
- (void)animation:(NSMutableArray*)geometricObjects and:(UISegmentedControl*)toolControl and:(UILabel*)toolInstructions and:(DHGeometryView*)geometryView and:(UIView*)view;
- (NSString*)levelDescriptionExtra;
- (void)showHint;

@end

@interface DHLevel : NSObject
@property (nonatomic) NSUInteger progress;
@property (nonatomic) BOOL showingHint;
@property (nonatomic) BOOL iPhoneVersion;
@property (nonatomic, weak) DHLevelViewController* levelViewController;
@property (nonatomic, weak) DHGeometryView* geometryView;
@property (nonatomic, weak) UIView* view;
@property (nonatomic, weak) UIButton* hintButton;
@property (nonatomic, weak) UISegmentedControl* toolControl;
@property (nonatomic, weak) NSLayoutConstraint* heightToolbar;

- (void)showTemporaryMessage:(NSString*)message atPoint:(CGPoint)point withColor:(UIColor*)color andTime:(CGFloat)time;
- (void)fadeIn:(UIView*)view withDuration:(CGFloat)time;
- (void)fadeOut:(UIView*)view withDuration:(CGFloat)time;
- (void)fadeInViews:(NSArray*)array withDuration:(CGFloat)time;
- (void)movePoint:(DHPoint*)point toPosition:(CGPoint)end withDuration:(CGFloat)time inViews:(NSArray*)geometryViews;
- (void)movePointFrom:(DHPoint*)start to:(DHPoint*)end withDuration:(CGFloat)time inView:(DHGeometryView*)geometryView;
- (void)movePointOnCircle:(DHPointOnCircle*)point toAngle:(CGFloat)endAngle withDuration:(CGFloat)time inView:(DHGeometryView*)geometryView;
-(void)movePointOnCircle:(DHPointOnCircle*)point toAngle:(CGFloat)endAngle withDuration:(CGFloat)time inViews:(NSArray*)array;
-(void)movePointOnLine:(DHPointOnLine*)point toTValue:(CGFloat)tValue withDuration:(CGFloat)time inView:(DHGeometryView*)geometryView ;
- (void)slideOutToolbar;
- (void)slideInToolbar;
- (void)showEndHintMessageInView:(UIView*)view;
- (void)hideHint;

- (Message*)createUpperMessageWithSuperView:(UIView*)view;
- (Message*)createMiddleMessageWithSuperView:(UIView*)view;

@end

@interface NSObject (Blocks)
- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;
- (void)afterDelay:(NSTimeInterval)delay performBlock:(void (^)())block;
- (void)afterDelay:(NSTimeInterval)delay :(void (^)())block;
@end





