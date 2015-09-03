//
//  DHLevelViewController.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-26.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
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
#import "DHPopoverView.h"
#import "DHTriangleView.h"

@interface DHLevelViewController () <UINavigationControllerDelegate, DHPopoverViewDelegate>

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
    UIBarButtonItem* _hintButton;
    UIBarButtonItem* _popoverMenuButton;
    
    CGPoint _tempGeoCenter;
    
    YLProgressBar* _progressBar;
    UILabel* _progressLabelPhone;
    
    BOOL _iPhoneVersion;
    
    DHPopoverView* _popoverMenu;
    DHPopoverView* _popoverToolMenu;
    
    DHTriangleView* _toolTriangleIndicator;
    
    UIView* _levelCompletionBackgroundView;
    
    NSDate* _levelStartTime;
}

#pragma mark Life-cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        _iPhoneVersion = YES;
    }
    
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
    _currentLevel.toolControl = self.toolControl;
    _currentLevel.heightToolbar = self.heightToolBar;
    
    [_toolControl addTarget:self
                     action:@selector(toolChanged:)
           forControlEvents:UIControlEventValueChanged];
    
    // Set up navigation toolbar
    UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain
                                                                 target:self action:nil];
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
    UIBarButtonItem *hintButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Hint"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(showHint:)];
    
    _undoButton = undoButtonItem;
    _redoButton = redoButtonItem;
    _resetButton = resetButtonItem;
    _hintButton = hintButtonItem;
    
    if (_currentGameMode != kDHGameModeTutorial) {
        if (_iPhoneVersion) {
            UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showPopoverMenu:)];
            self.navigationItem.rightBarButtonItem = menuButton;
            _popoverMenuButton = menuButton;
        } else {
            self.navigationItem.rightBarButtonItem = resetButtonItem;
            self.navigationItem.rightBarButtonItems = @[resetButtonItem, separator, redoButtonItem, undoButtonItem,
                                                        separator];
        }
    }
    
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
    
    if (_iPhoneVersion) {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.toolInstruction
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:-10.0]];
        
        if (_currentGameMode != kDHGameModeTutorial &&
            _currentGameMode != kDHGameModePlayground &&
            [DHSettings showProgressPercentage])
        {
            _progressLabelPhone = [[UILabel alloc] initWithFrame:CGRectMake(6, 5, 100, 100)];
            _progressLabelPhone.textColor = [UIColor darkGrayColor];
            _progressLabelPhone.font = [UIFont systemFontOfSize:14];
            [self.view addSubview:_progressLabelPhone];
        }
    }

    [self setupForLevel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        [self.geometryView centerContent];
        [self.geometryView setNeedsDisplay];
    }
    
    if (_toolTriangleIndicator) {
        CGFloat triLeft = _toolControl.frame.size.width*5.5/6 - 15;
        CGRect triRect = CGRectMake(triLeft, -4, 30, 4);
        [_toolTriangleIndicator setFrame:triRect];
    }
    
    if ([_currentLevel respondsToSelector:@selector(positionMessagesForOrientation:)]) {
        [(id)_currentLevel positionMessagesForOrientation:orientation];
    }
    
    self.navigationController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetLevelTimer:)
                                                 name:@"kDHNotificationResetLevelTimer"
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // Stop being the navigation controller's delegate
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

#pragma mark Level related methods
- (void)setupForLevel
{
    _currentLevel.levelViewController = self;
    _currentLevel.geometryView = self.geometryView;
    _currentLevel.view = self.view;
    _currentLevel.toolControl = self.toolControl;
    _currentLevel.heightToolbar = self.heightToolBar;
    
    _levelStartTime = [NSDate date];
    
    self.firstMoveMade = NO;
    
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
    
    [self showOrHideHintButton];
    
    NSString* levelInstruction = [@"Objective: " stringByAppendingString:[_currentLevel levelDescription]];
    _levelInstruction.text = levelInstruction;
    
    [self showDetailedLevelInstruction:nil];
    [self resetLevel];
    
    if (self.currentGameMode == kDHGameModeTutorial) {
        self.movesLabel.hidden = YES;
        self.levelObjectiveView.hidden = YES;
        self.heightLevelObjectiveView.constant = 0;
        self.heightToolBar.constant = -20;
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

    if (_iPhoneVersion) {
        self.heightLevelObjectiveView.constant = 0;
        if(_currentGameMode != kDHGameModeTutorial) self.heightToolBar.constant = 70;
        self.levelObjectiveView.hidden = YES;
        self.toolbarLeadingConstraint.constant = 4;
        self.toolbarTrailingConstraint.constant = 4;
        //self.toolbarHeightConstraint.constant = 24;
        self.toolInstruction.font = [UIFont systemFontOfSize:11.0];
        self.toolInstruction.numberOfLines = 2;
        [self.toolInstruction setLineBreakMode:NSLineBreakByWordWrapping];
        self.toolInstruction.textAlignment = NSTextAlignmentCenter;
    }
    
    if ([DHSettings showProgressPercentage] == NO) {
        self.progressLabel.hidden = YES;
        _progressBar.hidden = YES;
        if ([DHSettings showHints] == NO) {
            self.levelInstructionLabelConstraint.constant = -self.levelInstruction.frame.size.height*0.5;
        }
    }
}

- (void)resetLevel
{
    [self.geometryView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    [self showOrHideHintButton];
    _hintButton.enabled = YES;
    
    [self.detailedInstructions setTitle:@"Full instruction" forState:UIControlStateNormal];
    [self.detailedInstructions removeTarget:self action:@selector(loadNextLevel:) forControlEvents:UIControlEventTouchUpInside];
    [self.detailedInstructions addTarget:self action:@selector(showDetailedLevelInstruction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupTools];
    if (_iPhoneVersion) {
        if (_currentGameMode == kDHGameModeTutorial) {
            [self.geometryView.geoViewTransform setOffset:CGPointMake(-30, -50)];
        } else {
            [self.geometryView.geoViewTransform setOffset:CGPointMake(-30, 0)];
        }
        [self.geometryView.geoViewTransform setScale:0.5];
        [self.geometryView.geoViewTransform setRotation:0];
    } else {
        [self.geometryView.geoViewTransform setOffset:CGPointMake(0, 0)];
        [self.geometryView.geoViewTransform setScale:1];
        [self.geometryView.geoViewTransform setRotation:0];
    }
    
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
    [self hideCompletionMessage:nil];
    
    _currentLevel.progress = 0;
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
    [self checkTimePlayed];
    
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
        
        if (self.currentGameMode == kDHGameModePlayground) {
            NSUInteger numberOfObjectsMade = [DHSettings numberOfObjectsMadeInPlayground] + 1;
            [DHSettings setNumberOfObjectsMadeInPlayground:numberOfObjectsMade];
            if (numberOfObjectsMade >= 100) {
                // TODO: Submit achievement
            }
        }
    }
    if (countMove && self.maxNumberOfMoves > 0 && self.maxNumberOfMoves - self.levelMoves == 0) {
        [self.geometryView setNeedsDisplay];
        [self showTemporaryMessage:(@"You are out of moves and can only create points\n"
                                    @"(or undo previous moves/reset the level)")
                           atPoint:CGPointMake(self.view.frame.size.width*0.5, self.view.frame.size.height*0.5)
                         withColor:[UIColor redColor] forDuration:5.0];
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
        [self levelWasCompleted];
    }
    
    // If level supports progress hints, check new objects towards them
    if([_currentLevel respondsToSelector:@selector(testObjectsForProgressHints:)])
    {
        CGPoint hintLocation = [_currentLevel testObjectsForProgressHints:objects];
        if (!isnan(hintLocation.x)) {
            CGPoint hintLocationInView = [self.geoViewTransform geoToView:hintLocation];
            if (_progressBar.progress < _currentLevel.progress/100.0 &&
                ([DHSettings showWellDoneMessages] || [DHSettings showHints])) {
                [self showTemporaryMessage:[NSString stringWithFormat:@"Well done!"] atPoint:hintLocationInView withColor:[UIColor darkGrayColor]];
            } else if ([DHSettings showHints] && self.currentGameMode == kDHGameModeNormal) {
                [self showTemporaryMessage:[NSString stringWithFormat:@"Good choice!"] atPoint:hintLocationInView withColor:[UIColor darkGrayColor]];
            }
        }
    }
    
    // Update the progress indicator
    [self setLevelProgress:_currentLevel.progress];
    
    if (self.currentGameMode == kDHGameModeTutorial) {
        [_currentLevel tutorial:_geometricObjects and:_toolControl and:_toolInstruction and:self.geometryView and:self.view and:self.heightToolBar and:NO];
    }
    
    if (!self.levelCompleted && countMove && self.maxNumberOfMoves > 0 && self.maxNumberOfMoves - self.levelMoves == 0)
    {
        [self.geometryView setNeedsDisplay];
        [self showTemporaryMessage:(@"You are out of moves and can only create points\n"
                                    @"(or undo previous moves/reset the level)")
                           atPoint:CGPointMake(self.view.frame.size.width*0.5, self.view.frame.size.height*0.5)
                         withColor:[UIColor redColor] forDuration:4.0];
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

- (BOOL)shouldAutorotate
{
    if (_currentLevel.showingHint) {
        return NO;
    } else {
        return YES;
    }
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
        self.currentGameMode != kDHGameModePrimitiveOnlyMinimumMoves && !_iPhoneVersion) {
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
    
    if (_iPhoneVersion && _currentGameMode != kDHGameModeTutorial &&
        !(_currentGameMode == kDHGameModePrimitiveOnly || _currentGameMode == kDHGameModePrimitiveOnlyMinimumMoves))
    {
        [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolTriangle"] atIndex:index++ animated:NO];
        [_tools addObject:[DHTriangleTool class]];
        if ((availableTools & DHTriangleToolAvailable) == NO) {
            [_toolControl setEnabled:NO forSegmentAtIndex:(index-1)];
        }
        
        if (!_toolTriangleIndicator) {
            CGRect triRect = CGRectMake(270, -4, 30, 4);
            _toolTriangleIndicator = [[DHTriangleView alloc] initWithFrame:triRect];
            _toolTriangleIndicator.color = [[UIApplication sharedApplication] delegate].window.tintColor;
            [_toolControl addSubview:_toolTriangleIndicator];
        }
        
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toolMenu:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        tap.cancelsTouchesInView = NO;
        [_toolControl addGestureRecognizer:tap];
    }
    
    _toolControl.contentMode = UIViewContentModeCenter;
    _toolControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    _currentTool = nil;
    self.geometryViewController.currentTool = _currentTool;
    self.geometryViewController.currentLevel = _currentLevel;
    _toolInstruction.text = nil;
    
}
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize,NO,2.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)toolMenu:(UITapGestureRecognizer*)tap
{
    if (_levelCompleted) {
        return;
    }
    
    CGPoint touchPoint = [tap locationInView:_toolControl];
    
    CGSize toolSegmentSize = CGSizeMake(_toolControl.frame.size.width/_toolControl.numberOfSegments,
                                        _toolControl.frame.size.height);
    CGRect toolRect;
    toolRect.origin = CGPointMake(CGRectGetMaxX(_toolControl.bounds)-toolSegmentSize.width,0);
    toolRect.size = toolSegmentSize;
    
    if(CGRectContainsPoint(toolRect, touchPoint)) {
        [self showPopoverToolMenu];
    }
}

- (void)toolChanged:(id)sender
{
    if (self.levelCompleted) {
        _currentTool = nil;
        _toolControl.selectedSegmentIndex = -1;
        _toolInstruction.text = @"";
        return;
    }
    
    if (_toolTriangleIndicator) [_toolControl bringSubviewToFront:_toolTriangleIndicator];
    
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

- (void)levelWasCompleted
{
    self.levelCompleted = YES;
    
    // Disable further edits
    _hintButton.enabled = NO;
    _undoButton.enabled = NO;
    _redoButton.enabled = NO;
    _toolControl.selectedSegmentIndex = 1;
    _toolControl.selectedSegmentIndex = -1;
    _toolInstruction.text = @"";
    self.geometryViewController.currentTool = nil;
    
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    [result setObject:[NSNumber numberWithBool:YES] forKey:kLevelResultKeyCompleted];
    
    NSString* resultKey = [NSStringFromClass([_currentLevel class]) stringByAppendingFormat:@"/%lu",
                           (unsigned long)self.currentGameMode];
    [DHLevelResults newResult:result forLevel:resultKey];
    
    if ((self.currentGameMode == kDHGameModeNormal || self.currentGameMode == kDHGameModeNormalMinimumMoves)
        && [_currentLevel respondsToSelector:@selector(animation:and:and:and:and:)]
        && !_iPhoneVersion)
    {
        [_currentLevel animation:_geometricObjects and:_toolControl and:_toolInstruction and:self.geometryView and:self.view];
        
        [self performBlock:^{
            [self showLevelCompleteMessage];
        } afterDelay:4];
    }
    else {
        [self showLevelCompleteMessage];
    }
    
    NSUInteger levelsCompleted = [DHLevelResults numberOfLevesCompletedForGameMode:self.currentGameMode];
    if (self.currentGameMode == kDHGameModeNormal) {
        [[DHGameCenterManager sharedInstance] reportScore:levelsCompleted
                                           forLeaderboard:kLeaderboardID_LevelsCompletedNormal];
    }
    if (self.currentGameMode == kDHGameModeNormalMinimumMoves) {
        [[DHGameCenterManager sharedInstance] reportScore:levelsCompleted
                                           forLeaderboard:kLeaderboardID_LevelsCompletedNormalMinimumMoves];
    }
    if (self.currentGameMode == kDHGameModePrimitiveOnly) {
        [[DHGameCenterManager sharedInstance] reportScore:levelsCompleted
                                           forLeaderboard:kLeaderboardID_LevelsCompletedPrimitiveOnly];
    }
    if (self.currentGameMode == kDHGameModePrimitiveOnlyMinimumMoves) {
        [[DHGameCenterManager sharedInstance] reportScore:levelsCompleted
                                           forLeaderboard:kLeaderboardID_LevelsCompletedPrimitiveOnlyMinimumMoves];
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

#pragma mark Undo/Redo
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
#pragma mark Hint related methods
- (void)showHint:(id)sender
{
    UIBarButtonItem *closeHintButton = [[UIBarButtonItem alloc] initWithTitle:@"Close hint"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(hideHint:)];

    [self.navigationItem setRightBarButtonItems:@[closeHintButton] animated:YES];
    _detailedInstructions.enabled = NO;
    
    if ([_currentLevel respondsToSelector:@selector(showHint)]) {
        [_currentLevel showHint];
        [_currentTool reset];
    }
    
    if (_progressLabelPhone) [_currentLevel fadeOut:_progressLabelPhone withDuration:1.0];
    if (_movesLabel) [_currentLevel fadeOut:_movesLabel withDuration:1.0];
}
- (void)hideHint:(id)sender
{
    if ([_currentLevel respondsToSelector:@selector(hideHint)]) {
        [_currentLevel hideHint];
    }
}
- (void)changeSwitch:(id)sender
{
    if([sender isOn]){
        [DHSettings setShowHints:YES];
    } else{
        [DHSettings setShowHints:NO];
    }
    [self showOrHideHintButton];
}
- (void)showOrHideHintButton
{
    // Only use hint button on iPad in normal game mode
    if (_iPhoneVersion || _currentGameMode != kDHGameModeNormal) {
        return;
    }
    
    NSMutableArray *buttons = [self.navigationItem.rightBarButtonItems mutableCopy];
    BOOL levelHintAnimations = [_currentLevel respondsToSelector:@selector(showHint)];
    
    if ([DHSettings showHints] && levelHintAnimations) {
        if (![buttons containsObject:_hintButton]) {
            [buttons addObject:_hintButton];
            [self.navigationItem setRightBarButtonItems:buttons animated:YES];
        }
    } else {
        if ([buttons containsObject:_hintButton]) {
            [buttons removeObject:_hintButton];
            [self.navigationItem setRightBarButtonItems:buttons animated:YES];
        }
    }
}
- (void)hintFinished
{
    if (_progressLabelPhone) [_currentLevel fadeIn:_progressLabelPhone withDuration:1.0];
    if (_movesLabel) [_currentLevel fadeIn:_movesLabel withDuration:1.0];
    
    _detailedInstructions.enabled = YES;
    UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain
                                                                 target:self action:nil];
    if (_iPhoneVersion) {
        self.navigationItem.rightBarButtonItem = _popoverMenuButton;
    } else {
        self.navigationItem.rightBarButtonItems = @[_resetButton, separator, _redoButton, _undoButton,
                                                    separator, _hintButton];
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
    UIView* background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2000, 2000)];
    background.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    [self.view addSubview:background];
    [self.view bringSubviewToFront:self.levelCompletionMessage];
    //[background addSubview:self.levelCompletionMessage];
    background.alpha = 0;
    _levelCompletionBackgroundView = background;
    
    NSMutableString* completionMessageText = [[NSMutableString alloc] init];
    
    if (_iPhoneVersion) {
        self.levelCompletionMessageWidthConstraint.constant = 300;
        self.levelCompletionMessageHeightConstraint.constant = 200;
        self.levelCompletionMessageTitle.font = [UIFont boldSystemFontOfSize:18.0];
        self.levelCompletionMessageAdditional.font = [UIFont systemFontOfSize:14.0];
    }

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
                         background.alpha = 1;
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
    [self hideCompletionMessage:nil];

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
    [_levelCompletionBackgroundView removeFromSuperview];
    _levelCompletionBackgroundView = nil;
    self.levelCompletionMessage.hidden = YES;
}

- (void)showTemporaryMessage:(NSString*)message atPoint:(CGPoint)point withColor:(UIColor*)color
{
    [self showTemporaryMessage:message atPoint:point withColor:color forDuration:2.5];
}

- (void)showTemporaryMessage:(NSString*)message atPoint:(CGPoint)point withColor:(UIColor*)color
                 forDuration:(CGFloat)duration
{
    UILabel* label = [[UILabel alloc] init];
    label.alpha = 0;
    label.text = message;
    label.textColor = color;
    if (_iPhoneVersion) {
        label.font = [UIFont systemFontOfSize:11];
    }
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 8.0;
    label.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
    
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
                                               delay:duration
                                             options: UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              label.alpha = 0;
                                          }
                                          completion:^(BOOL finished){
                                              [label removeFromSuperview];
                                          }];
                     }];
    
}

- (void)showDetailedLevelInstruction:(id)sender
{
    if (_detailedInstructions.enabled == NO) {
        return;
    }
    if (_levelInfoView != nil) {
        return;
    }
    if ([_currentLevel respondsToSelector:@selector(createSolutionPreviewObjects:)] == NO) {
        return;
    }
    
    const CGFloat levelInfoViewWidth = _iPhoneVersion ? 300.0 : 660.0;
    const CGFloat levelInfoViewHeight = _iPhoneVersion ? self.view.bounds.size.height*0.85 : levelInfoViewWidth;
    const CGFloat fontSizeTitle = _iPhoneVersion ? 14.0 : 17.0;
    const CGFloat fontSizeText = _iPhoneVersion ? 13.0 : 16.0;

    UIView* background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2000, 2000)];
    background.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    [self.view addSubview:background];
    _levelInfoView = background;
    
    UIView* detailedInstructionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIButton* startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UILabel* objectiveLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UILabel* turnHintOnLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
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
    
    if (!self.currentGameMode == kDHGameModeNormal || _levelIndex == 24) {
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
    titleLabel.font = [UIFont boldSystemFontOfSize:fontSizeTitle];

    solutionPreviewLabel.text = @"Solution preview:";
    solutionPreviewLabel.textColor = [UIColor darkGrayColor];
    solutionPreviewLabel.font = [UIFont boldSystemFontOfSize:fontSizeText];
    
    turnHintOnLabel.textAlignment = NSTextAlignmentLeft;
    turnHintOnLabel.textColor = [UIColor darkGrayColor];
    turnHintOnLabel.font = [UIFont systemFontOfSize:fontSizeText];
    if ([DHSettings showHints]){
        [hintSwitch setOn:YES];
        turnHintOnLabel.text = @"Show hints: ";
    }
    else{
        [hintSwitch setOn:NO];
        turnHintOnLabel.text = @"Show hints: ";
    }

    objectiveLabel.text = [_currentLevel levelDescription];
    objectiveLabel.textColor = [UIColor darkGrayColor];
    objectiveLabel.font = [UIFont systemFontOfSize:fontSizeText];
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
                                                        constant:levelInfoViewWidth]];
    
    // Height constraint
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:detailedInstructionView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:levelInfoViewHeight]];
    
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
                                                           constant:levelInfoViewWidth]];
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
    _popoverMenuButton.enabled = NO;
}

- (void)hideDetailedLevelInstruction
{
    _resetButton.enabled = YES;
    _popoverMenuButton.enabled = YES;
    
    if (!self.levelCompleted) {
        if (_geometricObjectsForUndo.count > 0) _undoButton.enabled = YES;
        if (_geometricObjectsForRedo.count > 0) _redoButton.enabled = YES;
    }

    [_levelInfoView removeFromSuperview];
    _levelInfoView = nil;
}

- (void)setLevelProgress:(NSUInteger)progress
{
    [_progressBar setProgress:progress/100.0 animated:YES];
    if (_progressLabelPhone) {
        _progressLabelPhone.text = [NSString stringWithFormat:@"Progress: %lu%%", (unsigned long)progress];
        [_progressLabelPhone sizeToFit];
    }
}

- (void)checkTimePlayed
{
    if (_currentGameMode == kDHGameModeTutorial || _currentGameMode == kDHGameModePlayground) {
        return;
    }
    
    // Calculate number of seconds played on level
    NSTimeInterval timePlayed = -[_levelStartTime timeIntervalSinceNow];
    
    if (timePlayed > 60*30) {
        [[DHGameCenterManager sharedInstance] reportAchievementIdentifier:kAchievementID_Persistence_30min
                                                          percentComplete:100.0];
    }
}

- (void)resetLevelTimer:(id)sender
{
    _levelStartTime = [NSDate date];
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

#pragma mark Popover menu methods
- (void)showPopoverMenu:(id)sender
{
    if(!_popoverMenu) {
        UIView* targetView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        CGRect originFrame = [[sender view] convertRect:[sender view].bounds toView:targetView];
        
        DHPopoverView *popOverView = [[DHPopoverView alloc] initWithOriginFrame:originFrame
                                                                       delegate:self
                                                               firstButtonTitle:nil];
        if (_currentGameMode != kDHGameModePlayground) {
            if (!_levelCompleted) {
                [popOverView addButtonWithTitle:@"Show level instruction"];
            } else {
                // Unless this is the last level, show a button to go the next level
                if (self.levelIndex >= self.levelArray.count - 1) {
                } else {
                    [popOverView addButtonWithTitle:@"Go to next level"];
                }
            }
            if ([DHSettings showHints] && _currentGameMode == kDHGameModeNormal) {
                [popOverView addButtonWithTitle:@"Show hint" enabled:YES];
            }
        }
        [popOverView addButtonWithTitle:@"Undo move" enabled:_undoButton.enabled];
        [popOverView addButtonWithTitle:@"Redo move" enabled:_redoButton.enabled];
        [popOverView addButtonWithTitle:@"Reset level"];
        [popOverView show];
        
        _popoverMenu = popOverView;
    } else {
        [self hidePopoverMenu];
    }
}

- (void)showPopoverToolMenu
{
    if(!_popoverMenu) {
        DHToolsAvailable availableTools = DHAllToolsAvailable;
        
        if ([_currentLevel respondsToSelector:@selector(availableTools)]) {
            availableTools = [_currentLevel availableTools];
        }
        
        UIView* targetView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        CGSize toolSegmentSize = CGSizeMake(_toolControl.frame.size.width/_toolControl.numberOfSegments,
                                            _toolControl.frame.size.height);
        CGRect toolRect;
        toolRect.origin = CGPointMake(CGRectGetMaxX(_toolControl.frame)-toolSegmentSize.width,
                                      _toolControl.frame.origin.y);
        toolRect.size = toolSegmentSize;
        CGRect originFrame = [self.view convertRect:toolRect toView:targetView];
        
        DHPopoverView *toolMenu = [[DHPopoverView alloc] initWithOriginFrame:originFrame
                                                                       delegate:self
                                                               firstButtonTitle:nil];
        toolMenu.verticalDirection = DHPopoverViewVerticalDirectionUp;
        toolMenu.width = 65;
        toolMenu.buttonHeight = 50;
        toolMenu.separatorInset = 5;

        NSString* midPointImg = (availableTools & DHMidpointToolAvailable) ? @"toolMidpointImproved" : @"toolMidpoint";
        
        [toolMenu addButtonWithImage:[UIImage imageNamed:@"toolTriangle"]
                             enabled:(availableTools & DHTriangleToolAvailable) != 0];
        [toolMenu addButtonWithImage:[UIImage imageNamed:midPointImg]
                             enabled:(availableTools & (DHMidpointToolAvailable | DHMidpointToolAvailable_Weak)) != 0];
        [toolMenu addButtonWithImage:[UIImage imageNamed:@"toolBisect"]
                             enabled:(availableTools & DHBisectToolAvailable) != 0];
        [toolMenu addButtonWithImage:[UIImage imageNamed:@"toolPerpendicular"]
                             enabled:(availableTools & DHPerpendicularToolAvailable) != 0];
        [toolMenu addButtonWithImage:[UIImage imageNamed:@"toolParallel"]
                             enabled:(availableTools & DHParallelToolAvailable) != 0];
        [toolMenu addButtonWithImage:[UIImage imageNamed:@"toolTranslateSegment"]
                             enabled:(availableTools & (DHTranslateToolAvailable | DHTranslateToolAvailable_Weak)) != 0];
        [toolMenu addButtonWithImage:[UIImage imageNamed:@"toolCompass"]
                             enabled:(availableTools & DHCompassToolAvailable) != 0];
        
        [toolMenu show];
        
        _popoverToolMenu = toolMenu;
    } else {
        [self hidePopoverMenu];
    }
}

-(void)hidePopoverMenu
{
    [_popoverMenu dismissWithAnimation:YES];
    _popoverMenu = nil;
    [_popoverToolMenu dismissWithAnimation:YES];
    _popoverToolMenu = nil;
}

- (void)closePopoverView:(DHPopoverView *)popoverView
{
    [self hidePopoverMenu];
}
- (void)popoverViewDidClose:(DHPopoverView *)popoverView
{
    
}
- (void)popoverView:(DHPopoverView *)popoverView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (popoverView == _popoverMenu) {
        NSString* title = [popoverView titleForButton:buttonIndex];
        if ([title isEqualToString:@"Show level instruction"]) {
            [self showDetailedLevelInstruction:nil];
        }
        if ([title isEqualToString:@"Reset level"]) {
            [self askToResetLevel];
        }
        if ([title isEqualToString:@"Undo move"]) {
            [self undoMove];
        }
        if ([title isEqualToString:@"Redo move"]) {
            [self redoMove];
        }
        if ([title isEqualToString:@"Show hint"]) {
            [self showHint:nil];
        }
        if ([title isEqualToString:@"Go to next level"]) {
            [self loadNextLevel:nil];
        }
    }
    
    if (popoverView == _popoverToolMenu) {
        NSUInteger lastIndex = _toolControl.numberOfSegments-1;
        [_toolControl setImage:[popoverView imageForButton:buttonIndex] forSegmentAtIndex:lastIndex];
        _toolControl.selectedSegmentIndex = lastIndex;
        [self.view setNeedsLayout];
        
        switch (buttonIndex) {
            case 0:
                [_tools setObject:[DHTriangleTool class] atIndexedSubscript:lastIndex];
                break;
            case 1:
                [_tools setObject:[DHMidPointTool class] atIndexedSubscript:lastIndex];
                break;
            case 2:
                [_tools setObject:[DHBisectTool class] atIndexedSubscript:lastIndex];
                break;
            case 3:
                [_tools setObject:[DHPerpendicularTool class] atIndexedSubscript:lastIndex];
                break;
            case 4:
                [_tools setObject:[DHParallelTool class] atIndexedSubscript:lastIndex];
                break;
            case 5:
                [_tools setObject:[DHTranslateSegmentTool class] atIndexedSubscript:lastIndex];
                break;
            case 6:
                [_tools setObject:[DHCompassTool class] atIndexedSubscript:lastIndex];
                break;
                
            default:
                break;
        }
        
        [self toolChanged:nil];
    }

    [self hidePopoverMenu];
}
- (UIColor*)popOverTintColor
{
    return self.view.tintColor;
}

@end
