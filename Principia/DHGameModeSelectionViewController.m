//
//  DHGameModeSelectionViewController.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-13.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGameModeSelectionViewController.h"
#import "DHLevelViewController.h"
#import "DHLevelSelectionViewController.h"
#import "DHLevelSelection2ViewController.h"
#import "DHLevelPlayground.h"
#import "DHLevelResults.h"
#import "DHLevels.h"
#import "DHGameModes.h"
#import "DHGameCenterManager.h"




@implementation DHGameModeSelectionViewController {
    BOOL _iPhoneVersion;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        _iPhoneVersion = YES;
    }
    [self.gameMode1View setTouchActionWithTarget:self andAction:@selector(loadTutorial)];
    [self.gameMode2View setTouchActionWithTarget:self andAction:@selector(selectGameMode1)];
    [self.gameMode3View setTouchActionWithTarget:self andAction:@selector(selectGameMode2)];
    [self.gameMode4View setTouchActionWithTarget:self andAction:@selector(selectGameMode3)];
    [self.gameMode5View setTouchActionWithTarget:self andAction:@selector(selectGameMode4)];
    [self.gameMode6View setTouchActionWithTarget:self andAction:@selector(loadPlayground)];
    
    self.gameMode2View.showPercentComplete = YES;
    self.gameMode3View.showPercentComplete = YES;
    self.gameMode4View.showPercentComplete = YES;
    self.gameMode5View.showPercentComplete = YES;
    
    self.gameMode1View.title = @"Tutorial";
    self.gameMode2View.title = @"The Elements";
    self.gameMode3View.title = @"Perfectionist";
    self.gameMode4View.title = @"Ancient Greece";
    self.gameMode5View.title = @"Hardcore";
    self.gameMode6View.title = @"Playground";
    
    self.gameMode1View.gameModeDescription = @"Learn the basics";
    self.gameMode2View.gameModeDescription = @"Complete geometric challenges and unlock new tools";
    self.gameMode3View.gameModeDescription = @"Finish the levels using a minimum number of moves";
    self.gameMode4View.gameModeDescription = @"Take on the levels using only the primitive tools";
    self.gameMode5View.gameModeDescription = @"Limited to primitive tools and must use minimum number of moves";
    self.gameMode6View.gameModeDescription = @"Simply enjoy using all the available tools freely";
    
    if (_iPhoneVersion) {
        self.title = @"Euclid: The Game";
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([DHGameCenterManager sharedInstance].gameCenterAvailable) {
        self.gameCenterButton.enabled = YES;
    } else {
        self.gameCenterButton.enabled = NO;
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:DHGameCenterManagerUserDidAuthenticateNotification
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
    {
        self.gameCenterButton.enabled = YES;
    }];
    [self loadProgressData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowLevelSelection"]) {
        DHLevelSelectionViewController* vc = [segue destinationViewController];
        vc.currentGameMode = [sender unsignedIntegerValue];
    }
    if ([segue.identifier isEqualToString:@"ShowLevelSelection2"]) {
        DHLevelSelection2ViewController* vc = [segue destinationViewController];
        vc.currentGameMode = [sender unsignedIntegerValue];
    }
}


#pragma mark Layout/appereance
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    [self updateViewConstraintsToOrientation:self.interfaceOrientation];
}

- (void)updateViewConstraintsToOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    [super updateViewConstraints];
    
    if (_iPhoneVersion) {
        [self updateViewConstraintsToiPhone];
        return;
    }
    
    if (!self.layoutConstraintsLandscape) {
        self.layoutConstraintsLandscape = [[NSMutableArray alloc] initWithCapacity:10];
        
        // First game mode button
        [self.layoutConstraintsLandscape addObject:
         [NSLayoutConstraint constraintWithItem:self.gameMode1View attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.topLayoutGuide attribute:NSLayoutAttributeTop
                                     multiplier:1 constant:90]];
        
        [self.layoutConstraintsLandscape addObject:
         [NSLayoutConstraint constraintWithItem:self.gameMode1View attribute:NSLayoutAttributeRight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.view attribute:NSLayoutAttributeRight
                                     multiplier:1 constant:-30]];
        
        // Logo
        [self.layoutConstraintsLandscape addObject:
         [NSLayoutConstraint constraintWithItem:self.logoLabel attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.logoImageView attribute:NSLayoutAttributeCenterX
                                     multiplier:1 constant:0]];
        [self.layoutConstraintsLandscape addObject:
         [NSLayoutConstraint constraintWithItem:self.logoLabel attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.logoImageView attribute:NSLayoutAttributeBottom
                                     multiplier:1 constant:10]];
        [self.layoutConstraintsLandscape addObject:
         [NSLayoutConstraint constraintWithItem:self.logoLabel attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1 constant:self.logoImageView.frame.size.width]];
        
        // Game center button
        [self.layoutConstraintsLandscape addObject:
         [NSLayoutConstraint constraintWithItem:self.gameCenterButton attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.logoLabel attribute:NSLayoutAttributeCenterX
                                     multiplier:1 constant:0]];
        [self.layoutConstraintsLandscape addObject:
         [NSLayoutConstraint constraintWithItem:self.gameCenterButton attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.logoLabel attribute:NSLayoutAttributeBottom
                                     multiplier:1 constant:30]];    }
    
    [self.view removeConstraints:self.layoutConstraintsLandscape];
    [self.view removeConstraints:self.layoutConstraintsPortrait];
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        [self.view addConstraints:self.layoutConstraintsPortrait];
        self.selectGameModelLabel.hidden = NO;
    } else {
        [self.view addConstraints:self.layoutConstraintsLandscape];
        self.selectGameModelLabel.hidden = YES;
    }
}

- (void)updateViewConstraintsToiPhone
{
    if (!self.layoutConstraintsiPhone) {
        self.logoImageTopConstraint.constant = 5;
        self.logoImageHeightConstraint.constant = 40;
        self.logoImageLeadingConstraint.constant = 8;
        self.logoImageWidthConstraint.constant = 40;
        self.selectGameModelLabel.hidden = NO;
        self.selectGameModeLabelDistanceConstraint.constant = 5;
        self.selectGameModelLabel.font = [UIFont systemFontOfSize:12];
        
        self.gameMode1ViewWidthConstraint.constant = 310;
        self.gameMode1ViewHeightConstraint.constant = 60;
        
        for (NSLayoutConstraint* constraint in self.gameModeViewDistanceConstraints) {
            constraint.constant = 8;
        }
        
        self.layoutConstraintsiPhone = [[NSMutableArray alloc] initWithCapacity:10];
        self.logoImageView.hidden = YES;
        self.logoLabel.hidden = YES;
        self.gameCenterButton.hidden = YES;
        self.logoSubtitleLabel.hidden = YES;
        
        // First game mode button
        [self.layoutConstraintsiPhone addObject:
         [NSLayoutConstraint constraintWithItem:self.gameMode1View attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.topLayoutGuide attribute:NSLayoutAttributeTop
                                     multiplier:1 constant:70]];
        
        [self.layoutConstraintsiPhone addObject:
         [NSLayoutConstraint constraintWithItem:self.gameMode1View attribute:NSLayoutAttributeLeft
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.view attribute:NSLayoutAttributeLeft
                                     multiplier:1 constant:5]];
        
        // Logo
        [self.layoutConstraintsiPhone addObject:
         [NSLayoutConstraint constraintWithItem:self.logoLabel attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.logoImageView attribute:NSLayoutAttributeCenterY
                                     multiplier:1 constant:0]];
        [self.layoutConstraintsiPhone addObject:
         [NSLayoutConstraint constraintWithItem:self.logoLabel attribute:NSLayoutAttributeLeft
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.logoImageView attribute:NSLayoutAttributeRight
                                     multiplier:1 constant:10]];
        [self.layoutConstraintsiPhone addObject:
         [NSLayoutConstraint constraintWithItem:self.logoLabel attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1 constant:self.logoImageView.frame.size.width]];
        
        // Game center button
        [self.layoutConstraintsiPhone addObject:
         [NSLayoutConstraint constraintWithItem:self.gameCenterButton attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.logoLabel attribute:NSLayoutAttributeCenterX
                                     multiplier:1 constant:0]];
        [self.layoutConstraintsiPhone addObject:
         [NSLayoutConstraint constraintWithItem:self.gameCenterButton attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.logoLabel attribute:NSLayoutAttributeBottom
                                     multiplier:1 constant:30]];
        
        [self.view removeConstraints:self.layoutConstraintsPortrait];
        [self.view addConstraints:self.layoutConstraintsiPhone];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateViewConstraintsToOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //[self updateViewConstraints];
}

#pragma mark - Select game modes
- (void)selectGameMode1
{
    [self performSegueWithIdentifier:@"ShowLevelSelection2"
                              sender:[NSNumber numberWithUnsignedInteger:kDHGameModeNormal]];
}
- (void)selectGameMode2
{
    [self performSegueWithIdentifier:@"ShowLevelSelection2"
                              sender:[NSNumber numberWithUnsignedInteger:kDHGameModeNormalMinimumMoves]];
}
- (void)selectGameMode3
{
    [self performSegueWithIdentifier:@"ShowLevelSelection2"
                              sender:[NSNumber numberWithUnsignedInteger:kDHGameModePrimitiveOnly]];
}
- (void)selectGameMode4
{
    [self performSegueWithIdentifier:@"ShowLevelSelection2"
                              sender:[NSNumber numberWithUnsignedInteger:kDHGameModePrimitiveOnlyMinimumMoves]];
}
- (void)loadPlayground
{
    NSString* storyboardName = @"Main";
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    DHLevelViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"GeometryView"];
    vc.currentLevel = [[DHLevelPlayground alloc] init];
    vc.levelArray = nil;
    vc.levelIndex = 0;
    vc.title = @"Playground";
    vc.currentGameMode = kDHGameModePlayground;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)loadTutorial
{
    NSString* storyboardName = @"Main";
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    DHLevelViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"GeometryView"];
    vc.currentLevel = [[DHLevelTutorial alloc] init];
    vc.levelArray = nil;
    vc.levelIndex = NSUIntegerMax;
    vc.title = @"Tutorial";
    vc.currentGameMode = kDHGameModeTutorial;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Other
- (void)loadProgressData
{
    NSMutableArray* levels = [[NSMutableArray alloc] initWithCapacity:30];
    FillLevelArray(levels);
    
    NSDictionary* levelResults = [DHLevelResults levelResults];
    
    NSUInteger levelsCompleteGameModeNormal = 0;
    NSUInteger levelsCompleteGameModeMinimumMoves = 0;
    NSUInteger levelsCompleteGameModePrimitiveOnly = 0;
    NSUInteger levelsCompleteGameModePrimitiveOnlyMinimumMoves = 0;
    
    for (id level in levels) {
        NSString* resultKey = [NSStringFromClass([level class])
                               stringByAppendingFormat:@"/%lu", (unsigned long)kDHGameModeNormal];
        NSDictionary* levelResult = [levelResults objectForKey:resultKey];
        if (levelResult) {
            NSNumber* completed = [levelResult objectForKey:kLevelResultKeyCompleted];
            if (completed.boolValue) {
                ++levelsCompleteGameModeNormal;
            }
        }
    }
    for (id level in levels) {
        NSString* resultKey = [NSStringFromClass([level class])
                               stringByAppendingFormat:@"/%lu", (unsigned long)kDHGameModeNormalMinimumMoves];
        NSDictionary* levelResult = [levelResults objectForKey:resultKey];
        if (levelResult) {
            NSNumber* completed = [levelResult objectForKey:kLevelResultKeyCompleted];
            if (completed.boolValue) {
                ++levelsCompleteGameModeMinimumMoves;
            }
        }
    }
    for (id level in levels) {
        NSString* resultKey = [NSStringFromClass([level class])
                               stringByAppendingFormat:@"/%lu", (unsigned long)kDHGameModePrimitiveOnly];
        NSDictionary* levelResult = [levelResults objectForKey:resultKey];
        if (levelResult) {
            NSNumber* completed = [levelResult objectForKey:kLevelResultKeyCompleted];
            if (completed.boolValue) {
                ++levelsCompleteGameModePrimitiveOnly;
            }
        }
    }
    for (id level in levels) {
        NSString* resultKey = [NSStringFromClass([level class])
                               stringByAppendingFormat:@"/%lu", (unsigned long)kDHGameModePrimitiveOnlyMinimumMoves];
        NSDictionary* levelResult = [levelResults objectForKey:resultKey];
        if (levelResult) {
            NSNumber* completed = [levelResult objectForKey:kLevelResultKeyCompleted];
            if (completed.boolValue) {
                ++levelsCompleteGameModePrimitiveOnlyMinimumMoves;
            }
        }
    }
    
    self.gameMode2View.percentComplete = levelsCompleteGameModeNormal*1.0/levels.count;
    self.gameMode3View.percentComplete = levelsCompleteGameModeMinimumMoves*1.0/levels.count;
    self.gameMode4View.percentComplete = levelsCompleteGameModePrimitiveOnly*1.0/levels.count;
    self.gameMode5View.percentComplete = levelsCompleteGameModePrimitiveOnlyMinimumMoves*1.0/levels.count;
    
    // Update achievements here if they were not awarded earlier
    if (self.gameMode2View.percentComplete == 1.0) {
        [[DHGameCenterManager sharedInstance]
         reportAchievementIdentifier:kAchievementID_GameModeNormal_1_25 percentComplete:100];
    }
    if (self.gameMode3View.percentComplete == 1.0) {
        [[DHGameCenterManager sharedInstance]
         reportAchievementIdentifier:kAchievementID_GameModeNormalMinimumMoves_1_25 percentComplete:100];
    }
    if (self.gameMode4View.percentComplete == 1.0) {
        [[DHGameCenterManager sharedInstance]
         reportAchievementIdentifier:kAchievementID_GameModePrimitiveOnly_1_25 percentComplete:100];
    }
    if (self.gameMode5View.percentComplete == 1.0) {
        [[DHGameCenterManager sharedInstance]
         reportAchievementIdentifier:kAchievementID_GameModePrimitiveOnlyMinimumMoves_1_25 percentComplete:100];
    }
}

- (IBAction)showLeaderboards:(id)sender
{
    [[DHGameCenterManager sharedInstance] showLeaderboard];
}

- (IBAction)closeSettings:(UIStoryboardSegue *)unwindSegue
{
    [self loadProgressData];
    if (!_iPhoneVersion) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end