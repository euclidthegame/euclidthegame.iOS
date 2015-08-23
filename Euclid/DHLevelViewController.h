//
//  DHLevelViewController.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-26.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <UIKit/UIKit.h>
#import "DHGeometricTools.h"
#import "DHLevel.h"
#import "DHGeometryViewController.h"
#import "DHGeometryView.h"

@interface DHLevelViewController : UIViewController <DHGeometryToolDelegate>

@property (nonatomic, strong) DHLevel<DHLevel>* currentLevel;

@property (nonatomic, weak) IBOutlet UISegmentedControl* toolControl;
@property (nonatomic, weak) IBOutlet UIView* levelObjectiveView;
@property (nonatomic, strong) IBOutlet UIView* levelCompletionMessage;
@property (nonatomic, strong) IBOutlet UILabel* levelCompletionMessageTitle;
@property (nonatomic, strong) IBOutlet UILabel* levelCompletionMessageAdditional;
@property (nonatomic, strong) IBOutlet UIButton* nextChallengeButton;
@property (nonatomic, strong) IBOutlet UIButton* detailedInstructions;
@property (nonatomic, weak) IBOutlet UILabel* toolInstruction;
@property (nonatomic, weak) IBOutlet UILabel* levelInstruction;
@property (nonatomic, weak) IBOutlet UILabel* movesLabel;
@property (nonatomic, weak) IBOutlet UILabel* movesLeftLabel;
@property (nonatomic, weak) IBOutlet UILabel* progressLabel;
@property (nonatomic, weak) IBOutlet DHGeometryView* geometryView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* toolbarLeadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* toolbarTrailingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* toolbarHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* heightLevelObjectiveView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* heightToolBar;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* levelInstructionLabelConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* levelInstructionButtonConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* levelCompletionMessageWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* levelCompletionMessageHeightConstraint;

@property (nonatomic, weak) DHGeometryViewController* geometryViewController;
@property (nonatomic, strong) NSMutableArray* levelArray;
@property (nonatomic) NSUInteger levelIndex;
@property (nonatomic) NSUInteger levelMoves;
@property (nonatomic) NSUInteger maxNumberOfMoves;

@property (nonatomic) BOOL firstMoveMade;
@property (nonatomic) BOOL levelCompleted;

@property (nonatomic) NSUInteger currentGameMode;

- (void)resetLevel;

- (IBAction)loadNextLevel:(id)sender;
- (IBAction)hideCompletionMessage:(id)sender;
- (void)showDetailedLevelInstruction:(id)sender;
- (void)hintFinished;

// Geometry tool delegate methods
- (NSArray*)geometryObjects;
- (void)toolTipDidChange:(NSString *)currentTip;
- (void)addGeometricObject:(id)object;
- (DHGeometricTransform*)geoViewTransform;


@end