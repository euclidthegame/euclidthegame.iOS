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
#import "DHGeometryView.h"

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
- (void)animation:(NSMutableArray*)geometricObjects and:(UISegmentedControl*)toolControl and:(UILabel*)toolInstructions and:(DHGeometryView*)geometryView and:(UIView*)view;
- (void)hint:(NSMutableArray*)geometricObjects and:(UISegmentedControl*)toolControl and:(UILabel*)toolInstructions and:(DHGeometryView*)geometryView and:(UIView*)view and:(NSLayoutConstraint*)heightToolBar and:(UIButton*)hintButton;
- (NSString*)levelDescriptionExtra;

@end

@interface DHLevel : NSObject
@property NSUInteger progress;
@property (nonatomic, weak) DHGeometryView* geometryView;
@property (nonatomic, weak) UIView* view;
- (void)showTemporaryMessage:(NSString*)message atPoint:(CGPoint)point withColor:(UIColor*)color andTime:(CGFloat)time;
- (void)fadeIn:(DHGeometryView*)view withDuration:(CGFloat)time;
- (void)fadeOut:(DHGeometryView*)view withDuration:(CGFloat)time;
- (void)movePointFrom:(DHPoint*)start to:(DHPoint*)end withDuration:(CGFloat)time inView:(DHGeometryView*)geometryView;
- (void)movePointOnCircle:(DHPointOnCircle*)point toAngle:(CGFloat)endAngle withDuration:(CGFloat)time inView:(DHGeometryView*)geometryView;
@end

@interface NSObject (Blocks)
- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay;
- (void)afterDelay:(NSTimeInterval)delay performBlock:(void (^)())block;
@end

@interface Message : UILabel
@property (nonatomic) CGPoint point;
- (instancetype)initWithMessage:(NSString*)message andPoint:(CGPoint)point;
- (void)text:(NSString*)string;
- (void)text:(NSString*)string position:(CGPoint)point;
- (void)position:(CGPoint)point;
@end



