//
//  DHLevelViewController.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-26.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHGeometricTools.h"
#import "DHLevel.h"
#import "DHGeometryViewController.h"
#import "DHGeometryView.h"

@interface DHLevelViewController : UIViewController <DHGeometryToolDelegate>

@property (nonatomic, strong) id<DHLevel> currentLevel;

@property (nonatomic, weak) IBOutlet UISegmentedControl* toolControl;
@property (nonatomic, weak) IBOutlet UIView* levelObjectiveView;
@property (nonatomic, strong) IBOutlet UIView* levelCompletionMessage;
@property (nonatomic, strong) IBOutlet UILabel* levelCompletionMessageAdditional;
@property (nonatomic, strong) IBOutlet UIButton* nextChallengeButton;
@property (nonatomic, weak) IBOutlet UILabel* toolInstruction;
@property (nonatomic, weak) IBOutlet UILabel* levelInstruction;
@property (nonatomic, weak) IBOutlet UILabel* movesLabel;
@property (nonatomic, weak) IBOutlet UILabel* movesLeftLabel;
@property (nonatomic, weak) IBOutlet UILabel* progressLabel;
@property (nonatomic, weak) IBOutlet DHGeometryView* geometryView;

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

// Geometry tool delegate methods
- (NSArray*)geometryObjects;
- (void)toolTipDidChange:(NSString *)currentTip;
- (void)addGeometricObject:(id)object;
- (DHGeometricTransform*)geoViewTransform;


@end