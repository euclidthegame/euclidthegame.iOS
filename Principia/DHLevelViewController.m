//
//  DHLevelViewController.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-26.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelViewController.h"
#import "DHGeometryView.h"
#import "DHMath.h"
#import "DHLevelResults.h"
#import "DHGeometricObjectLabeler.h"
#import "DHGeometricTransform.h"
#import "DHGameModes.h"
#import "DHGameCenterManager.h"
#import "DHLevels.h"
#import "DHSettings.h"
#import "DHTransitionFromLevel.h"
#import "DHLevelSelection2ViewController.h"
#import "YLProgressBar.h"

@interface DHLevelViewController () <UINavigationControllerDelegate>

@end


@implementation DHLevelViewController {
    NSMutableArray* _geometricObjects;
    NSMutableArray* _temporaryGeometricObjects;
    NSMutableArray* _geometricObjectsForUndo;
    NSMutableArray* _geometricObjectsForRedo;
    id<DHGeometryTool> _currentTool;
    NSMutableArray* _tools;
    UIView* _levelInfoView;
    DHGeometricObjectLabeler* _objectLabeler;
    
    UIBarButtonItem* _undoButton;
    UIBarButtonItem* _redoButton;
    UIBarButtonItem* _resetButton;
    
    UILabel* turnHintOnLabel;
    CGPoint _tempGeoCenter;
    
    YLProgressBar* _progressBar;
}

#pragma mark Life-cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // NOTE: This is necessary due to a bug with custom transitions messing up the top layout guide
    self.edgesForExtendedLayout = UIRectEdgeNone;

    _geometricObjects = [[NSMutableArray alloc] initWithCapacity:200];
    _temporaryGeometricObjects = [[NSMutableArray alloc] initWithCapacity:4];
    self.geometryView.geometricObjects = _geometricObjects;
    self.geometryView.temporaryGeometricObjects = _temporaryGeometricObjects;

    _geometricObjectsForUndo = [[NSMutableArray alloc] init];
    _geometricObjectsForRedo = [[NSMutableArray alloc] init];
    
    _objectLabeler = [[DHGeometricObjectLabeler alloc] init];
    
    _tools = [[NSMutableArray alloc] init];
    
    _currentLevel.geometryView = self.geometryView;
    _currentLevel.view = self.view;
    _currentLevel.hintButton = self.hintButton;
    _currentLevel.toolControl = self.toolControl;
    _currentLevel.heightToolbar = self.heightToolBar;
    
    
    [_toolControl addTarget:self
                     action:@selector(toolChanged:)
           forControlEvents:UIControlEventValueChanged];
    
    // Set up according to level
    UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *resetButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(askToResetLevel)];
    UIBarButtonItem *undoButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Undo"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(undoMove)];
    UIBarButtonItem *redoButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Redo"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(redoMove)];
    self.navigationItem.rightBarButtonItem = resetButtonItem;
    self.navigationItem.rightBarButtonItems = @[resetButtonItem, separator, redoButtonItem, undoButtonItem];
    _undoButton = undoButtonItem;
    _redoButton = redoButtonItem;
    _resetButton = resetButtonItem;
    

    _levelInstruction.layer.cornerRadius = 10.0f;
    
    // Set up completion message
    self.levelCompletionMessage.layer.cornerRadius = 10.0;
    self.levelCompletionMessage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.levelCompletionMessage.layer.shadowOffset = CGSizeMake(5, 5);
    self.levelCompletionMessage.layer.shadowOpacity = 0.5;
    self.levelCompletionMessage.layer.shadowRadius = 10.0;
    self.levelCompletionMessage.hidden = YES;
    
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetailedLevelInstruction:)];
    [self.levelObjectiveView setUserInteractionEnabled:YES];
    [self.levelObjectiveView addGestureRecognizer:gesture];
    
    _progressBar = [[YLProgressBar alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _progressBar.trackTintColor = [UIColor lightGrayColor];
    _progressBar.progressTintColor = [[UIApplication sharedApplication] delegate].window.tintColor;
    _progressBar.type = YLProgressBarTypeRounded;
    _progressBar.hideStripes = YES;
    [self.levelObjectiveView addSubview:_progressBar];
    _progressBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_progressBar
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.progressLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_progressBar
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.progressLabel
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:10.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_progressBar
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:12.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_progressBar
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.levelInstruction
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-30.0]];

    /*[self.view addConstraint:[NSLayoutConstraint constraintWithItem:_progressBar
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:450.0]];*/

    [self setupForLevel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        [self.geometryView centerContent];
        [self.geometryView setNeedsDisplay];
    }
    
    if ([_currentLevel respondsToSelector:@selector(positionMessagesForOrientation:)]) {
        [(id)_currentLevel positionMessagesForOrientation:orientation];
    }
    
    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Stop being the navigation controller's delegate
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

#pragma mark Level related methods
- (void)setupForLevel
{
    _currentLevel.geometryView = self.geometryView;
    _currentLevel.view = self.view;
    _currentLevel.hintButton = self.hintButton;
    _currentLevel.toolControl = self.toolControl;
    _currentLevel.heightToolbar = self.heightToolBar;
    
    self.firstMoveMade = NO;
    
    //turn hints off every new level
    [DHSettings setShowWellDoneMessages:NO];
    self.geometryViewController.currentLevel = _currentLevel;
    
    [self.geometryView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    if (self.currentGameMode == kDHGameModeTutorial) {
        self.title = @"Tutorial";
    } else if (self.currentGameMode == kDHGameModePlayground) {
        self.title = @"Playground";
    } else {
        self.title = [NSString stringWithFormat:@"Level %lu", (unsigned long)(self.levelIndex+1)];
    }
    
    if (self.currentGameMode == kDHGameModeNormalMinimumMoves) {
        self.maxNumberOfMoves = [_currentLevel minimumNumberOfMoves];
        self.movesLeftLabel.hidden = NO;
    } else if (self.currentGameMode == kDHGameModePrimitiveOnlyMinimumMoves) {
        self.maxNumberOfMoves = [_currentLevel minimumNumberOfMovesPrimitiveOnly];
        self.movesLeftLabel.hidden = NO;
    } else {
        self.maxNumberOfMoves = 0;
        self.movesLeftLabel.hidden = YES;
    }
    
    [self.hintButton addTarget:self action:@selector(showHint:) forControlEvents:UIControlEventTouchUpInside];
    
    if (!([_currentLevel respondsToSelector:@selector(hint:and:and:and:and:and:and:)] && [DHSettings showWellDoneMessages] && self.currentGameMode == kDHGameModeNormal )) {
        self.hintButton.hidden = YES;
    }
    
    NSString* levelInstruction = [@"Objective: " stringByAppendingString:[_currentLevel levelDescription]];
    _levelInstruction.text = levelInstruction;
    
    [self showDetailedLevelInstruction:nil];
    [self resetLevel];
    
    if (self.currentGameMode == kDHGameModeTutorial) {
        self.movesLabel.hidden = YES;
        self.levelObjectiveView.hidden = YES;
        self.heightLevelObjectiveView.constant = 0;
        self.heightToolBar.constant = -20;
        _redoButton.title = nil;
        _undoButton.title = nil;
        _resetButton.title = nil;
        [_currentLevel tutorial:_geometricObjects and:_toolControl and:_toolInstruction and:self.geometryView and:self.view and:self.heightToolBar and:NO];
    } else if (self.currentGameMode == kDHGameModePlayground) {
        self.levelObjectiveView.hidden = YES;
        self.heightLevelObjectiveView.constant = 0;
    } else {
        self.heightLevelObjectiveView.constant = 60;
        self.heightToolBar.constant = 70;
        self.levelObjectiveView.hidden = NO;
        self.movesLabel.hidden = NO;
    }
    
    if ([DHSettings showProgressPercentage] == NO) {
        self.progressLabel.hidden = YES;
        _progressBar.hidden = YES;
        self.levelInstructionLabelConstraint.constant = -self.levelInstruction.frame.size.height*0.5;
    }
}

- (void)resetLevel
{
    [self.geometryView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    [self.hintButton setTitle:@"Show hint" forState:UIControlStateNormal];
    
     if (!([_currentLevel respondsToSelector:@selector(hint:and:and:and:and:and:and:)] && [DHSettings showWellDoneMessages] && self.currentGameMode == kDHGameModeNormal )) {
         self.hintButton.hidden = YES;
     }
    
    [self.detailedInstructions setTitle:@"Full instruction" forState:UIControlStateNormal];
    [self.detailedInstructions removeTarget:self action:@selector(loadNextLevel:) forControlEvents:UIControlEventTouchUpInside];
    [self.detailedInstructions addTarget:self action:@selector(showDetailedLevelInstruction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupTools];
    [self.geometryView.geoViewTransform setOffset:CGPointMake(0, 0)];
    [self.geometryView.geoViewTransform setScale:1];
    [self.geometryView.geoViewTransform setRotation:0];
    
    [_objectLabeler reset];
    [_geometricObjects removeAllObjects];
    [_temporaryGeometricObjects removeAllObjects];
    
    NSMutableArray* levelObjects = [[NSMutableArray alloc] init];
    [_currentLevel createInitialObjects:levelObjects];
    for (id object in levelObjects) {
        // Sort objects to ensure points are last in the array to be drawn last
        if ([[object class] isSubclassOfClass:[DHPoint class]]) {
            DHPoint* p = object;
            if (p.label == nil) {
                p.label = [_objectLabeler nextLabel];
            }
            p.updatesPositionAutomatically = YES;
            [_geometricObjects addObject:object];
        } else {
            [_geometricObjects insertObject:object atIndex:0];
        }
    }
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        [self.geometryView centerContent];
    }
    
    self.levelCompleted = NO;
    self.levelMoves = 0;
    self.movesLabel.text = [NSString stringWithFormat:@"Moves: %lu", (unsigned long)self.levelMoves];
    if (self.maxNumberOfMoves > 0) {
        self.movesLeftLabel.text = [NSString stringWithFormat:@"Moves left: %lu",
                                    (unsigned long)(self.maxNumberOfMoves - self.levelMoves)];
        self.movesLeftLabel.textColor = [UIColor darkGrayColor];
    }
    
    [self.geometryView setNeedsDisplay];
    self.levelCompletionMessage.hidden = YES;
    
    [self setLevelProgress:0];

    [_geometricObjectsForRedo removeAllObjects];
    [_geometricObjectsForUndo removeAllObjects];
    
    // Disable undo/redo button
    _redoButton.enabled = false;
    _undoButton.enabled = false;
    
    // Reset current tool
    _currentTool = [[[_currentTool class] alloc] init];
    self.toolInstruction.text = [_currentTool initialToolTip];
    
    [_currentLevel isLevelComplete:_geometricObjects];
    [self.geometryView setUserInteractionEnabled:YES];
    

}

#pragma mark Helper functions for managing geometric objects
- (void)addGeometricObject:(id)object
{
    [self addGeometricObjects:@[object]];
}
- (void)addGeometricObjects:(NSArray*)objects_
{
    NSMutableArray* tempobjects = [[NSMutableArray alloc]initWithArray:objects_];
    for (id newobject in objects_) {
        for (id oldobject in _geometricObjects) {
            if (EqualCircles(oldobject, newobject) || EqualLines(oldobject, newobject) || EqualLineSegments(oldobject, newobject)|| EqualPoints(oldobject, newobject)){
                [tempobjects removeObject:newobject];
            }
        }
    }
    NSArray* objects = [[NSArray alloc] initWithArray:tempobjects];
    self.firstMoveMade = YES;
    BOOL countMove = NO;

    for (id object in objects) {
        if ([[object class] isSubclassOfClass:[DHMidPoint class]] ||
            [[object class] isSubclassOfClass:[DHPoint class]] == NO) {
            countMove = YES;
        }
    }
    if (countMove && self.maxNumberOfMoves > 0 && self.maxNumberOfMoves - self.levelMoves == 0) {
        [self.geometryView setNeedsDisplay];
        [self showTemporaryMessage:@"You are out of moves, undo or reset the level."
                           atPoint:CGPointMake(self.view.frame.size.width*0.5, self.view.frame.size.height*0.5)
                         withColor:[UIColor redColor]];
        return;
    }
    
    if ([_geometricObjectsForRedo containsObject:objects] == NO) {
        // New item(s), clear redo-list
        [_geometricObjectsForRedo removeAllObjects];
        _redoButton.enabled = false;
    }
    [_geometricObjectsForUndo addObject:[objects copy]];
    _undoButton.enabled = true;
    
    for (DHGeometricObject* object in objects) {
        object.temporary = NO;
        // Sort objects to ensure points are last in the array to be drawn last
        if ([[object class] isSubclassOfClass:[DHPoint class]]) {
            DHPoint* p = (DHPoint*)object;
            if (p.label == nil) {
                p.label = [_objectLabeler nextLabel];
            }
            p.updatesPositionAutomatically = YES;
            [_geometricObjects addObject:object];
            
            // Mid point is only point-type counted as a move
            if ([[object class] isSubclassOfClass:[DHMidPoint class]]) {
                countMove = YES;
            }
        } else {
            countMove = YES;
            [_geometricObjects insertObject:object atIndex:0];
        }
    }

    if (countMove) {
        self.levelMoves++;
        self.movesLabel.text = [NSString stringWithFormat:@"Moves: %lu", (unsigned long)self.levelMoves];
        if (self.maxNumberOfMoves > 0) {
            self.movesLeftLabel.text = [NSString stringWithFormat:@"Moves left: %lu",
                                    (unsigned long)(self.maxNumberOfMoves - self.levelMoves)];
            if (self.maxNumberOfMoves - self.levelMoves == 0) {
                self.movesLeftLabel.textColor = [UIColor redColor];
            } else {
                self.movesLeftLabel.textColor = [UIColor darkGrayColor];
            }
        }
    }
    
    [self.geometryView setNeedsDisplay];
    
    // Test if level matches completion objective
    if (self.levelCompleted == NO && [_currentLevel isLevelComplete:_geometricObjects])
    {
        self.levelCompleted = YES;
        
        // Disable further edits
        _undoButton.enabled = false;
        _redoButton.enabled = false;
        _toolControl.selectedSegmentIndex = -1;
        _toolInstruction.text = @"";
        self.geometryViewController.currentTool = nil;
        
        NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
        [result setObject:[NSNumber numberWithBool:YES] forKey:kLevelResultKeyCompleted];
        
        NSString* resultKey = [NSStringFromClass([_currentLevel class]) stringByAppendingFormat:@"/%lu", (unsigned long)self.currentGameMode];
        [DHLevelResults newResult:result forLevel:resultKey];
        
        if ((self.currentGameMode == kDHGameModeNormal || self.currentGameMode == kDHGameModeNormalMinimumMoves)
            && [_currentLevel respondsToSelector:@selector(animation:and:and:and:and:)])
        {
            [_currentLevel animation:_geometricObjects and:_toolControl and:_toolInstruction and:self.geometryView and:self.view];
            
            [self performBlock:^{
                [self showLevelCompleteMessage];
            } afterDelay:4];
        }
        else {
            [self showLevelCompleteMessage];
        }
        
        if (self.currentGameMode == kDHGameModeNormal) {
            [[DHGameCenterManager sharedInstance] reportScore:(self.levelIndex+1) forLeaderboard:kLeaderboardID_LevelsCompletedNormal];
        }
        if (self.currentGameMode == kDHGameModeNormalMinimumMoves) {
            [[DHGameCenterManager sharedInstance] reportScore:(self.levelIndex+1) forLeaderboard:kLeaderboardID_LevelsCompletedNormalMinimumMoves];
        }
        if (self.currentGameMode == kDHGameModePrimitiveOnly) {
            [[DHGameCenterManager sharedInstance] reportScore:(self.levelIndex+1) forLeaderboard:kLeaderboardID_LevelsCompletedPrimitiveOnly];
        }
        if (self.currentGameMode == kDHGameModePrimitiveOnlyMinimumMoves) {
            [[DHGameCenterManager sharedInstance] reportScore:(self.levelIndex+1) forLeaderboard:kLeaderboardID_LevelsCompletedPrimitiveOnlyMinimumMoves];
        }
        
        // If this is the last level, give achievements
        if (self.levelIndex == self.levelArray.count - 1) {
            if (self.currentGameMode == kDHGameModeNormal) {
                [[DHGameCenterManager sharedInstance]
                 reportAchievementIdentifier:kAchievementID_GameModeNormal_1_25 percentComplete:1.0];
            }
            if (self.currentGameMode == kDHGameModeNormalMinimumMoves) {
                [[DHGameCenterManager sharedInstance]
                 reportAchievementIdentifier:kAchievementID_GameModeNormalMinimumMoves_1_25 percentComplete:1.0];
            }
            if (self.currentGameMode == kDHGameModePrimitiveOnly) {
                [[DHGameCenterManager sharedInstance]
                 reportAchievementIdentifier:kAchievementID_GameModePrimitiveOnly_1_25 percentComplete:1.0];
            }
            if (self.currentGameMode == kDHGameModePrimitiveOnlyMinimumMoves) {
                [[DHGameCenterManager sharedInstance]
                 reportAchievementIdentifier:kAchievementID_GameModePrimitiveOnlyMinimumMoves_1_25 percentComplete:1.0];
            }
        }
    }
    
    // Update the progress indicator
    [self setLevelProgress:_currentLevel.progress];
    
    // If level supports progress hints, check new objects towards them
    if([_currentLevel respondsToSelector:@selector(testObjectsForProgressHints:)])
    {
        CGPoint hintLocation = [_currentLevel testObjectsForProgressHints:objects];
        if (!isnan(hintLocation.x)) {
            CGPoint hintLocationInView = [self.geoViewTransform geoToView:hintLocation];
            if (_progressBar.progress < _currentLevel.progress/100.0) {
                [self showTemporaryMessage:[NSString stringWithFormat:@"Well done !"] atPoint:hintLocationInView withColor:[UIColor darkGrayColor]];
            }
            else if ([DHSettings showWellDoneMessages] && self.currentGameMode == kDHGameModeNormal ) {
                [self showTemporaryMessage:[NSString stringWithFormat:@"Good choice !"] atPoint:hintLocationInView withColor:[UIColor darkGrayColor]];
            }
        }
    }
    
    if (self.currentGameMode == kDHGameModeTutorial) {
        [_currentLevel tutorial:_geometricObjects and:_toolControl and:_toolInstruction and:self.geometryView and:self.view and:self.heightToolBar and:NO];
    }
    
    if (!self.levelCompleted && countMove && self.maxNumberOfMoves > 0 && self.maxNumberOfMoves - self.levelMoves == 0)
    {
        [self.geometryView setNeedsDisplay];
        [self showTemporaryMessage:@"You are out of moves and can only create points, undo or reset the level"
                           atPoint:CGPointMake(self.view.frame.size.width*0.5, self.view.frame.size.height*0.5)
                         withColor:[UIColor redColor]];
    }
}

- (void)addTemporaryGeometricObjects:(NSArray *)objects
{
    /*
    for (DHGeometricObject* object in objects) {
        object.temporary = YES;
    }
    */
    [_temporaryGeometricObjects addObjectsFromArray:objects];
}

- (void)removeTemporaryGeometricObjects:(NSArray *)objects
{
    [_temporaryGeometricObjects removeObjectsInArray:objects];
}

#pragma mark Layout/appereance
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _tempGeoCenter = [self.geometryView getCenterInGeoCoordinates];
    [UIView animateWithDuration:0.2 animations:^{self.geometryView.alpha=0;}];
    
    if ([_currentLevel respondsToSelector:@selector(positionMessagesForOrientation:)]) {
        [(id)_currentLevel positionMessagesForOrientation:toInterfaceOrientation];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.geometryView centerOnGeoCoordinate:_tempGeoCenter];
    [self.geometryView setNeedsDisplay];
    [UIView animateWithDuration:0.3 animations:^{self.geometryView.alpha=1;}];
}

#pragma mark Toolbar functions
- (void)setupTools
{
    [_tools removeAllObjects];
    [_toolControl removeAllSegments];
    
    NSUInteger index = 0;
    
    DHToolsAvailable availableTools = DHAllToolsAvailable;
    
    if ([_currentLevel respondsToSelector:@selector(availableTools)]) {
        availableTools = [_currentLevel availableTools];
    }
    
    if (self.currentGameMode == kDHGameModePrimitiveOnly) {
        availableTools = (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
                          DHCircleToolAvailable);
    }

    //[_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolZoomPan"] atIndex:index++ animated:NO];
    //[_tools addObject:[DHZoomPanTool class]];
    
    [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolPoint"] atIndex:index++ animated:NO];
    [_tools addObject:[DHPointTool class]];
    if ((availableTools & DHPointToolAvailable) == NO) {
        [_toolControl setEnabled:NO forSegmentAtIndex:(index-1)];
    }

    [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolIntersect"] atIndex:index++ animated:NO];
    [_tools addObject:[DHIntersectTool class]];
    if ((availableTools & DHIntersectToolAvailable) == NO) {
        [_toolControl setEnabled:NO forSegmentAtIndex:(index-1)];
    }
    
    [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolLineSegment"] atIndex:index++ animated:NO];
    [_tools addObject:[DHLineSegmentTool class]];
    if ((availableTools & DHLineSegmentToolAvailable) == NO) {
        [_toolControl setEnabled:NO forSegmentAtIndex:(index-1)];
    }

    [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolLine"] atIndex:index++ animated:NO];
    [_tools addObject:[DHLineTool class]];
    if ((availableTools & DHLineToolAvailable) == NO) {
        [_toolControl setEnabled:NO forSegmentAtIndex:(index-1)];
    }
    
    [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolCircle"] atIndex:index++ animated:NO];
    [_tools addObject:[DHCircleTool class]];
    if ((availableTools & DHCircleToolAvailable) == NO) {
        [_toolControl setEnabled:NO forSegmentAtIndex:(index-1)];
    }

    if (self.currentGameMode != kDHGameModePrimitiveOnly &&
        self.currentGameMode != kDHGameModePrimitiveOnlyMinimumMoves) {
        [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolTriangle"] atIndex:index++ animated:NO];
        [_tools addObject:[DHTriangleTool class]];
        if ((availableTools & DHTriangleToolAvailable) == NO) {
            [_toolControl setEnabled:NO forSegmentAtIndex:(index-1)];
        }
        
        if (availableTools & DHMidpointToolAvailable) {
            [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolMidpointImproved"]
                                         atIndex:index++ animated:NO];
        } else {
            [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolMidpoint"]
                                         atIndex:index++ animated:NO];
        }
        
        [_tools addObject:[DHMidPointTool class]];
        if ((availableTools & (DHMidpointToolAvailable | DHMidpointToolAvailable_Weak)) == NO) {
            [_toolControl setEnabled:NO forSegmentAtIndex:(index-1)];
        }
        
        [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolBisect"] atIndex:index++ animated:NO];
        [_tools addObject:[DHBisectTool class]];
        if ((availableTools & DHBisectToolAvailable) == NO) {
            [_toolControl setEnabled:NO forSegmentAtIndex:(index-1)];
        }
        
        [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolPerpendicular"] atIndex:index++ animated:NO];
        [_tools addObject:[DHPerpendicularTool class]];
        if ((availableTools & DHPerpendicularToolAvailable) == NO) {
            [_toolControl setEnabled:NO forSegmentAtIndex:(index-1)];
        }
        
        [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolParallel"] atIndex:index++ animated:NO];
        [_tools addObject:[DHParallelTool class]];
        if ((availableTools & DHParallelToolAvailable) == NO) {
            [_toolControl setEnabled:NO forSegmentAtIndex:(index-1)];
        }
        
        [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolTranslateSegment"] atIndex:index++ animated:NO];
        [_tools addObject:[DHTranslateSegmentTool class]];
        if ((availableTools & DHTranslateToolAvailable || availableTools & DHTranslateToolAvailable_Weak) == NO) {
            [_toolControl setEnabled:NO forSegmentAtIndex:(index-1)];
        }
        
        [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolCompass"] atIndex:index++ animated:NO];
        [_tools addObject:[DHCompassTool class]];
        if ((availableTools & DHCompassToolAvailable) == NO) {
            [_toolControl setEnabled:NO forSegmentAtIndex:(index-1)];
        }
    }
    
    _toolControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    _currentTool = nil;
    self.geometryViewController.currentTool = _currentTool;
    self.geometryViewController.currentLevel = _currentLevel;
    _toolInstruction.text = nil;
    
}

- (void)toolChanged:(id)sender
{
    if (self.levelCompleted) {
        _currentTool = nil;
        _toolControl.selectedSegmentIndex = -1;
        _toolInstruction.text = @"";
        return;
    }
    
    _currentTool = nil;
    _currentTool = [[[_tools objectAtIndex:_toolControl.selectedSegmentIndex] alloc] init];
    assert(_currentTool);
    self.geometryViewController.currentTool = _currentTool;
    _currentTool.delegate = self;
    [self.geometryView setNeedsDisplay];
    
    DHToolsAvailable availableTools = DHAllToolsAvailable;
    if ([_currentLevel respondsToSelector:@selector(availableTools)]) {
        availableTools = [_currentLevel availableTools];
    }
    if (availableTools & DHTranslateToolAvailable_Weak && availableTools != DHAllToolsAvailable) {
        if ([_currentTool class] == [DHTranslateSegmentTool class]) {
            DHTranslateSegmentTool* tool = _currentTool;
            tool.disableWhenOnSameLine = YES;
        }
    }
    if (availableTools & DHMidpointToolAvailable_Weak && availableTools != DHAllToolsAvailable) {
        if ([_currentTool class] == [DHMidPointTool class]) {
            DHMidPointTool* tool = _currentTool;
            tool.disableCircles = YES;
        }
    }
    
    _toolInstruction.text = [_currentTool initialToolTip];    
    
    if (self.currentGameMode == kDHGameModeTutorial) {
        [_currentLevel tutorial:_geometricObjects and:_toolControl and:_toolInstruction and:self.geometryView and:self.view and:self.heightToolBar and:YES];
    }

    
}

#pragma mark Geometry tool delegate methods
- (NSArray*)geometryObjects
{
    return _geometricObjects;
}
- (void)toolTipDidChange:(NSString *)currentTip
{
    if (self.levelCompleted) {
        return;
    }
    
    _toolInstruction.text = currentTip;
    if ([_currentTool active]) {
        _undoButton.enabled = YES;
    }
}
- (DHGeometricTransform*)geoViewTransform
{

    return self.geometryView.geoViewTransform;
}
- (void)updateAllPositions
{
    for (id object in _geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    if (self.currentGameMode == kDHGameModeTutorial) {
        [_currentLevel tutorial:_geometricObjects and:_toolControl and:_toolInstruction and:self.geometryView and:self.view and:self.heightToolBar and:YES];
    }
    
}

#pragma mark - Undo/Redo
- (void)undoMove
{
    if ([_currentTool active]) {
        [_currentTool reset];
        [self.geometryView setNeedsDisplay];
        if (_geometricObjectsForUndo.count == 0) {
            _undoButton.enabled = NO;
        }        
        return;
    }
    
    id objectsToUndo = [_geometricObjectsForUndo lastObject];
    if (!objectsToUndo) {
        return;
    }
    
    BOOL undoMove = NO;
    for (id object in objectsToUndo) {
        [_geometricObjects removeObject:object];
        if ([[object class] isSubclassOfClass:[DHPoint class]] == NO ||
            [[object class] isSubclassOfClass:[DHMidPoint class]]) {
            undoMove = YES;
        }
    }
    if (undoMove) {
        self.levelMoves--;
        self.movesLabel.text = [NSString stringWithFormat:@"Moves: %lu", (unsigned long)self.levelMoves];
        if (self.maxNumberOfMoves > 0) {
            self.movesLeftLabel.text = [NSString stringWithFormat:@"Moves left: %lu",
                                    (unsigned long)(self.maxNumberOfMoves - self.levelMoves)];
            self.movesLeftLabel.textColor = [UIColor darkGrayColor];
        }
    }
    [_geometricObjectsForUndo removeObject:objectsToUndo];
    [_geometricObjectsForRedo addObject:objectsToUndo];
    _redoButton.enabled = YES;
    
    if (_geometricObjectsForUndo.count == 0) {
        _undoButton.enabled = NO;
    }
    
    BOOL complete = [_currentLevel isLevelComplete:_geometricObjects];
    if (!complete) {
        self.levelCompleted = NO;
    }
    [self setLevelProgress:_currentLevel.progress];
    
    [self.geometryView setNeedsDisplay];
}

- (void)redoMove
{
    id objectToRedo = [_geometricObjectsForRedo lastObject];
    if (!objectToRedo) {
        return;
    }
    
    [self addGeometricObjects:objectToRedo];

    [_geometricObjectsForRedo removeObject:objectToRedo];
    if (_geometricObjectsForRedo.count == 0) {
        _redoButton.enabled = false;
    }
    
}

#pragma mark Other
- (void) askToResetLevel
{
    NSString* resetMessage = @"Resetting the level will remove all items you have constructed";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reset level"
                                                        message:resetMessage
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Reset", nil];
    [alertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self resetLevel];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"GeometryViewEmbed"]) {
        DHGeometryViewController * childViewController = (DHGeometryViewController *) [segue destinationViewController];
        self.geometryView = (DHGeometryView*)childViewController.view;
        self.geometryViewController = childViewController;
    }
}

- (void)showLevelCompleteMessage
{
    NSMutableString* completionMessageText = [[NSMutableString alloc] init];

    // Only display messages about unlocking tools in non-primitive only game modes
    if (self.currentGameMode == kDHGameModeNormal || self.currentGameMode == kDHGameModeNormalMinimumMoves) {
        if ([_currentLevel respondsToSelector:@selector(additionalCompletionMessage)]) {
            [completionMessageText setString:[_currentLevel additionalCompletionMessage]];
        }
    }
    
    if (self.currentGameMode == kDHGameModeTutorial) {
        // Special message for tutorial
        [completionMessageText setString:@"Well done! You are now ready to begin with Level 1."];
        self.nextChallengeButton.hidden = NO;
        [self.nextChallengeButton setTitle:@"Go to Level 1." forState:UIControlStateNormal];
        [self.nextChallengeButton addTarget:self action:@selector(loadNextLevel:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        // If this is the last level, show special completion message and hide the "Next level" button
        if (self.levelIndex >= self.levelArray.count - 1) {
            self.nextChallengeButton.hidden = YES;
            [completionMessageText appendString:@"\n\nEuclid would be proud of you. You completed ALL levels !!!"];
        } else {
            self.nextChallengeButton.hidden = NO;
            [self.nextChallengeButton setTitle:@"Continue to next level" forState:UIControlStateNormal];
            [self.nextChallengeButton addTarget:self action:@selector(loadNextLevel:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    if (completionMessageText.length == 0) {
        [completionMessageText setString:@"Well done, you completed the level!"];
    }
    
    self.levelCompletionMessageAdditional.text = completionMessageText;
    
    // Fade in the completion pop-up
    self.levelCompletionMessage.alpha = 0;
    self.levelCompletionMessage.hidden = NO;
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.levelCompletionMessage.alpha = 1;
                     }
                     completion:^(BOOL finished){
                     }];
    
    [self.detailedInstructions setTitle:@"Next Level" forState:UIControlStateNormal];
    [self.detailedInstructions removeTarget:self action:@selector(showDetailedLevelInstruction:) forControlEvents:UIControlEventTouchUpInside];
    [self.detailedInstructions addTarget:self action:@selector(loadNextLevel:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)loadNextLevel:(id)sender
{
    [DHSettings setShowWellDoneMessages:NO];

    if (self.levelArray) {
        self.levelIndex = self.levelIndex + 1;
        id<DHLevel> nextLevel = [[[[self.levelArray objectAtIndex:self.levelIndex] class] alloc] init];
        if (nextLevel) {
            _currentLevel = nextLevel;
            [self setupForLevel];
        }
    }
    if (self.currentGameMode == kDHGameModeTutorial) {
        self.levelIndex = 0;
        self.currentGameMode = kDHGameModeNormal;
        id<DHLevel> nextLevel = [[DHLevelEquiTri alloc] init];
        _currentLevel = nextLevel;
        NSMutableArray* levels = [[NSMutableArray alloc] init];
        FillLevelArray(levels);
        self.levelArray =  levels;
        [self viewDidLoad];
    }
    
}

- (IBAction)hideCompletionMessage:(id)sender
{
    self.levelCompletionMessage.hidden = YES;
}

- (void)showTemporaryMessage:(NSString*)message atPoint:(CGPoint)point withColor:(UIColor*)color
{
    UILabel* label = [[UILabel alloc] init];
    label.alpha = 0;
    label.text = message;
    label.textColor = color;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary* attributes = @{NSFontAttributeName: label.font,
                                 NSParagraphStyleAttributeName: paragraphStyle};
    CGSize textSize = [message sizeWithAttributes:attributes];
    
    CGRect frame = label.frame;
    CGFloat originX = point.x - textSize.width*0.5;
    if (originX < 0) {
        originX = 0;
    }
    if (originX + textSize.width > self.view.frame.size.width) {
        originX = self.view.frame.size.width - textSize.width;
    }
    CGFloat originY = point.y - 20 - textSize.height;
    if (originY < self.geometryView.frame.origin.y) {
        originY = self.geometryView.frame.origin.y;
    }
    frame.origin = CGPointMake(roundf(originX), roundf(originY));
    frame.size = textSize;
    label.frame = frame;
    [self.geometryView addSubview:label];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         label.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.5
                                               delay:2.5
                                             options: UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              label.alpha = 0;
                                          }
                                          completion:^(BOOL finished){
                                              [label removeFromSuperview];
                                          }];
                     }];
    
}


- (void)showHint:(id)sender {
    if ([_currentLevel respondsToSelector:@selector(hint:and:and:and:and:and:and:)]) {

        [_currentLevel hint:_geometricObjects and:_toolControl and:_toolInstruction and:self.geometryView and:self.view and:self.heightToolBar and:self.hintButton];
        [_currentTool reset];
    }
}

- (void)showDetailedLevelInstruction:(id)sender
{
    if (_levelInfoView != nil) {
        return;
    }
    if ([_currentLevel respondsToSelector:@selector(createSolutionPreviewObjects:)] == NO) {
        return;
    }
    
    const CGFloat levelInfoViewSize = 660.0;

    UIView* background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2000, 2000)];
    background.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    [self.view addSubview:background];
    _levelInfoView = background;
    
    UIView* detailedInstructionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIButton* startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UILabel* objectiveLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    turnHintOnLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UILabel* solutionPreviewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    DHGeometryView* geoView = [[DHGeometryView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UISwitch *hintSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0,0)];
    [hintSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    
    [startButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [objectiveLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [geoView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [detailedInstructionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [solutionPreviewLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [turnHintOnLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [hintSwitch setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    detailedInstructionView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];

    [background addSubview:detailedInstructionView];
    [detailedInstructionView addSubview:startButton];
    [detailedInstructionView addSubview:titleLabel];
    [detailedInstructionView addSubview:objectiveLabel];
    [detailedInstructionView addSubview:geoView];
    [detailedInstructionView addSubview:solutionPreviewLabel];
    [detailedInstructionView addSubview:turnHintOnLabel];
    [detailedInstructionView addSubview:hintSwitch];
    
    if (!self.currentGameMode == kDHGameModeNormal) {
        turnHintOnLabel.hidden = YES;
        hintSwitch.hidden  = YES;
    }
    [startButton addTarget:self action:@selector(hideDetailedLevelInstruction)
                             forControlEvents:UIControlEventTouchUpInside];
    
    if (self.firstMoveMade == 0) {
        [startButton setTitle:@"Start Game" forState:UIControlStateNormal];
    } else {
        [startButton setTitle:@"Resume Game" forState:UIControlStateNormal];
    }
    
    startButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    
    titleLabel.text = [self.title stringByAppendingString:@" - Objective"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];

    solutionPreviewLabel.text = @"Solution preview:";
    solutionPreviewLabel.textColor = [UIColor darkGrayColor];
    solutionPreviewLabel.font = [UIFont boldSystemFontOfSize:16.0];
    
    turnHintOnLabel.textAlignment = NSTextAlignmentLeft;
    turnHintOnLabel.textColor = [UIColor darkGrayColor];
    turnHintOnLabel.font = [UIFont boldSystemFontOfSize:16.0];
    if ([DHSettings showWellDoneMessages]){
        [hintSwitch setOn:YES];
        turnHintOnLabel.text = @"Show hints: ";
    }
    else{
        [hintSwitch setOn:NO];
        turnHintOnLabel.text = @"Show hints: ";
    }

    objectiveLabel.text = [_currentLevel levelDescription];
    objectiveLabel.textColor = [UIColor darkGrayColor];
    objectiveLabel.font = [UIFont systemFontOfSize:16.0];
    objectiveLabel.numberOfLines = 0;
    [objectiveLabel setLineBreakMode:NSLineBreakByWordWrapping];
    
    if ([_currentLevel respondsToSelector:@selector(levelDescriptionExtra)]) {
        //NSAttributedStringMarkdownParser* parser = [[NSAttributedStringMarkdownParser alloc]init];
        //parser.paragraphFont = [UIFont systemFontOfSize:16];
        //objectiveLabel.attributedText = [parser mdString:[_currentLevel levelDescriptionExtra]];
        objectiveLabel.text = [_currentLevel levelDescriptionExtra];
    }
    else {
        objectiveLabel.text = [_currentLevel levelDescription];
    }
    
    
    // Constraints for pop-up view
    
    // Width constraint
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:detailedInstructionView
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1.0
                                                        constant:levelInfoViewSize]];
    
    // Height constraint
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:levelInfoViewSize]];
    
    // Center horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // Center vertically
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];

    // Constraints for title label
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:levelInfoViewSize]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:20.0]];

    // Constraints for objective label
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:objectiveLabel
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:20.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:objectiveLabel
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-20.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:objectiveLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:objectiveLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:titleLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:8.0]];

    // Constraints for start button
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:startButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:startButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-8.0]];

    // Constraints for "Show again" label
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:turnHintOnLabel
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:20.0]];
    /*[self.view addConstraint:[NSLayoutConstraint constraintWithItem:turnHintOnLabel
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                            constant:-20.0]];
     */
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:turnHintOnLabel
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:startButton
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:-8.0]];
    
    
    // Constraints for "Solution preview" label
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:solutionPreviewLabel
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:20.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:solutionPreviewLabel
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-20.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:solutionPreviewLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:objectiveLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:15.0]];
    
    // Constraints for geo view
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:geoView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:20.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:geoView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:-20.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:geoView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:solutionPreviewLabel
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:8.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:geoView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:turnHintOnLabel
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:-8.0]];
    
    // Constraints for hintswitch
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:hintSwitch
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:turnHintOnLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:hintSwitch
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:turnHintOnLabel
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:10.0]];

    
    detailedInstructionView.layer.cornerRadius = 10.0;
    detailedInstructionView.layer.shadowColor = [UIColor blackColor].CGColor;
    detailedInstructionView.layer.shadowOffset = CGSizeMake(5, 5);
    detailedInstructionView.layer.shadowOpacity = 0.5;
    detailedInstructionView.layer.shadowRadius = 10.0;
    
    geoView.hideBorder = YES;
    geoView.keepContentCenteredAndZoomedIn = YES;
    geoView.backgroundColor = [UIColor whiteColor];
    
    if ([_currentLevel respondsToSelector:@selector(createSolutionPreviewObjects:)]) {
        id<DHLevel> level = [[[_currentLevel class] alloc] init];

        NSMutableArray* objects = [[NSMutableArray alloc] init];
        [level createInitialObjects:objects];
        
        DHGeometricObjectLabeler* labeler = [[DHGeometricObjectLabeler alloc] init];
        for (id object in objects) {
            if ([[object class] isSubclassOfClass:[DHPoint class]]) {
                DHPoint* p = object;
                p.label = [labeler nextLabel];
            }
        }
        
        NSMutableArray* solutionObjects = [[NSMutableArray alloc] init];
        [level createSolutionPreviewObjects:solutionObjects];
        for (DHGeometricObject* object in solutionObjects) {
            object.temporary = YES;
            if ([[object class] isSubclassOfClass:[DHPoint class]]) {
                [objects addObject:object];
            } else {
                [objects insertObject:object atIndex:0];
            }
        }
        geoView.geometricObjects = objects;
        
    }
    
    [geoView setNeedsDisplay];
    
    _resetButton.enabled = NO;
    _undoButton.enabled = NO;
    _redoButton.enabled = NO;
}

- (void)hideDetailedLevelInstruction
{
    _resetButton.enabled = YES;
    
    if (!self.levelCompleted) {
        if (_geometricObjectsForUndo.count > 0) _undoButton.enabled = YES;
        if (_geometricObjectsForRedo.count > 0) _redoButton.enabled = YES;
    }

    [_levelInfoView removeFromSuperview];
    _levelInfoView = nil;
}

- (void)changeSwitch:(id)sender{

    if([sender isOn]){
        [DHSettings setShowWellDoneMessages:YES];
        self.hintButton.hidden = NO;

    } else{
        [DHSettings setShowWellDoneMessages:NO];
        self.hintButton.hidden = YES;
    }
    
}

- (void)setLevelProgress:(NSUInteger)progress
{
    [_progressBar setProgress:progress/100.0 animated:YES];
}

#pragma mark Transition delegate methods
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    if (fromVC == self && [toVC isKindOfClass:[DHLevelSelection2ViewController class]]) {
        return [[DHTransitionFromLevel alloc] init];
    }
    else {
        return nil;
    }
}

@end
