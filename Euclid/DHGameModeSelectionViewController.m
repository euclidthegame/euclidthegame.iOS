//
//  DHGameModeSelectionViewController.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-13.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGameModeSelectionViewController.h"
#import "DHLevelViewController.h"
#import "DHLevelSelection2ViewController.h"
#import "DHLevelPlayground.h"
#import "DHLevelResults.h"
#import "DHLevels.h"
#import "DHGameModes.h"
#import "DHGameCenterManager.h"
#import "DHPopoverView.h"

@interface DHGameModeSelectionViewController () <DHPopoverViewDelegate>

@end

@implementation DHGameModeSelectionViewController {
    BOOL _iPhoneVersion;
    DHPopoverView* _popoverMenu;
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
    
    self.gameMode2View.difficultyDescription = @"Normal";
    self.gameMode3View.difficultyDescription = @"Hard";
    self.gameMode4View.difficultyDescription = @"Harder";
    self.gameMode5View.difficultyDescription = @"Insane";
    
    self.gameMode1View.gameModeDescription = @"Learn the basics";
    self.gameMode2View.gameModeDescription = @"Complete geometric challenges and unlock new tools";
    self.gameMode3View.gameModeDescription = @"Finish the levels using a minimum number of moves";
    self.gameMode4View.gameModeDescription = @"Take on the levels using only the primitive tools";
    self.gameMode5View.gameModeDescription = @"Limited to primitive tools and must use minimum number of moves";
    self.gameMode6View.gameModeDescription = @"Simply enjoy using all the available tools freely";
    
    if (_iPhoneVersion) {
        self.title = @"Euclid: The Game";
    }
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(showPopoverMenu:)];
    self.navigationItem.rightBarButtonItem = menuButton;
    self.navigationItem.leftBarButtonItem = nil;    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadProgressData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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
                                     multiplier:1 constant:80]];
        
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
    }
    
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
        self.selectGameModelLabel.font = [UIFont systemFontOfSize:12];
        
        self.gameMode1ViewWidthConstraint.constant = 310;
        self.gameMode1ViewHeightConstraint.constant = 60;
        
        CGFloat buttonSpacing = 8;
        CGFloat labelSpacing = 5;
        CGFloat topSpacing = 70;

        if ([[UIScreen mainScreen] bounds].size.height > 500) {
            buttonSpacing = 15;
            labelSpacing = 10;
            topSpacing = 90;
        }
        
        self.selectGameModeLabelDistanceConstraint.constant = labelSpacing;
        for (NSLayoutConstraint* constraint in self.gameModeViewDistanceConstraints) {
            constraint.constant = buttonSpacing;
        }
        
        self.layoutConstraintsiPhone = [[NSMutableArray alloc] initWithCapacity:10];
        self.logoImageView.hidden = YES;
        self.logoLabel.hidden = YES;
        self.logoSubtitleLabel.hidden = YES;
        
        // First game mode button
        [self.layoutConstraintsiPhone addObject:
         [NSLayoutConstraint constraintWithItem:self.gameMode1View attribute:NSLayoutAttributeTop
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.topLayoutGuide attribute:NSLayoutAttributeTop
                                     multiplier:1 constant:topSpacing]];
        
        [self.layoutConstraintsiPhone addObject:
         [NSLayoutConstraint constraintWithItem:self.gameMode1View attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.view attribute:NSLayoutAttributeCenterX
                                     multiplier:1 constant:0]];
        
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
    
    NSUInteger levelsCompleteNormal = 0;
    NSUInteger levelsCompleteMinimumMoves = 0;
    NSUInteger levelsCompletePrimitiveOnly = 0;
    NSUInteger levelsCompletePrimitiveOnlyMinimumMoves = 0;
    
    levelsCompleteNormal = [DHLevelResults numberOfLevesCompletedForGameMode:kDHGameModeNormal];
    levelsCompleteMinimumMoves = [DHLevelResults numberOfLevesCompletedForGameMode:kDHGameModeNormalMinimumMoves];
    levelsCompletePrimitiveOnly = [DHLevelResults numberOfLevesCompletedForGameMode:kDHGameModePrimitiveOnly];
    levelsCompletePrimitiveOnlyMinimumMoves = [DHLevelResults
                                               numberOfLevesCompletedForGameMode:kDHGameModePrimitiveOnlyMinimumMoves];
    
    self.gameMode2View.percentComplete = levelsCompleteNormal*1.0/levels.count;
    self.gameMode3View.percentComplete = levelsCompleteMinimumMoves*1.0/levels.count;
    self.gameMode4View.percentComplete = levelsCompletePrimitiveOnly*1.0/levels.count;
    self.gameMode5View.percentComplete = levelsCompletePrimitiveOnlyMinimumMoves*1.0/levels.count;
    
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

- (IBAction)closeAboutView:(UIStoryboardSegue *)unwindSegue
{
    if (!_iPhoneVersion) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Popover menu methods
- (void)showPopoverMenu:(id)sender
{
    if(!_popoverMenu) {
        UIView* targetView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        CGRect originFrame = [[sender view] convertRect:[sender view].bounds toView:targetView];
        
        DHPopoverView *popOverView = [[DHPopoverView alloc] initWithOriginFrame:originFrame
                                                                       delegate:self
                                                               firstButtonTitle:nil];
        popOverView.width = 260;
        
        [popOverView addButtonWithTitle:@"Settings"];
        [popOverView addButtonWithTitle:@"Leaderboards & Achievements"];
        [popOverView addButtonWithTitle:@"About"];
        [popOverView show];
        
        _popoverMenu = popOverView;
    } else {
        [self hidePopoverMenu];
    }
}

-(void)hidePopoverMenu
{
    [_popoverMenu dismissWithAnimation:YES];
    _popoverMenu = nil;
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
    switch (buttonIndex) {
        case 0:
            [self performSegueWithIdentifier:@"showSettings" sender:nil];
            break;
        case 1:
            [self showLeaderboards:nil];
            break;
        case 2:
            [self performSegueWithIdentifier:@"showAboutView" sender:nil];
            break;
        default:
            break;
    }
    
    [self hidePopoverMenu];
}
- (UIColor*)popOverTintColor
{
    return self.view.tintColor;
}

@end