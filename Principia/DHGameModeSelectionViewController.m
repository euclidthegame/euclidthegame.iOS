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
#import "DHLevelPlayground.h"
#import "DHLevelResults.h"
#import "DHLevels.h"
#import "DHGameModes.h"
#import "DHGameCenterManager.h"

@implementation DHGameModeSelectionButton {
    BOOL _selected;
    id _target;
    SEL _action;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _selected = NO;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8.0;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(3, 3);
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 8.0;
    }
    return self;
}
- (void)setTouchActionWithTarget:(id)target andAction:(SEL)action
{
    _target = target;
    _action = action;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self select];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if(!CGRectContainsPoint(self.bounds, touchPoint)) {
        [self deselect];
    } else {
        if (!_selected) [self select];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self deselect];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_selected && _target && _action) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_action];
#pragma clang diagnostic pop
    }
    [self deselect];
}
- (void)select
{
    self.layer.shadowOffset = CGSizeMake(1, 1);
    self.layer.shadowRadius = 3.0;
    _selected = YES;
}
- (void)deselect
{
    if (!_selected) return;
    
    _selected = NO;
    self.layer.shadowOffset = CGSizeMake(3, 3);
    CABasicAnimation* fadeAnim = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
    fadeAnim.fromValue = [NSNumber numberWithFloat:3.0];
    fadeAnim.toValue = [NSNumber numberWithFloat:8.0];
    fadeAnim.duration = 0.5;
    [self.layer addAnimation:fadeAnim forKey:@"shadowRadius"];
    
    // Change the actual data value in the layer to the final value.
    self.layer.shadowRadius = 8.0;
    
    //self.layer.shadowRadius = 8.0;
}

@end

@implementation DHGameModePercentCompleteView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    }
    return self;
}
- (void)tintColorDidChange
{
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect
{
    const CGPoint pieChartCenter = CGPointMake(self.bounds.size.width*0.5, 40);
    CGFloat pieChartRadius = 20.0;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0/self.contentScaleFactor);
    
    if (self.percentComplete == 1.0) {
        CGContextSetFillColorWithColor(context, self.tintColor.CGColor);
        CGContextSetStrokeColorWithColor(context, self.tintColor.CGColor);
    } else {
        CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1.0);
        CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1.0);
    }
    
    if (self.percentComplete > 0) {
        CGContextMoveToPoint(context, pieChartCenter.x, pieChartCenter.y);
        CGContextAddLineToPoint(context, pieChartCenter.x+pieChartRadius, pieChartCenter.y);
        CGContextAddArc(context, pieChartCenter.x, pieChartCenter.y, pieChartRadius, 0, 2*M_PI*self.percentComplete, 0);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
    CGContextStrokeEllipseInRect(context, CGRectMake(pieChartCenter.x-pieChartRadius, pieChartCenter.y-pieChartRadius,
                                                     pieChartRadius*2, pieChartRadius*2));
    
    if (self.percentComplete == 1.0) {
        // Draw checkmark
        CGContextSetLineWidth(context, 3.0);
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);

        CGContextMoveToPoint(context, pieChartCenter.x - pieChartRadius*0.5, pieChartCenter.y);
        CGContextAddLineToPoint(context, pieChartCenter.x - pieChartRadius*0.5 + 7, pieChartCenter.y + 7);
        CGContextAddLineToPoint(context, pieChartCenter.x - pieChartRadius*0.5 + 7 + 14, pieChartCenter.y + 7 - 14);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    
    // Draw percent complete text
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSString* percentLabelText = [NSString stringWithFormat:@"%d%% complete", (uint)(self.percentComplete*100)];
    NSDictionary* attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:11],
                                 NSParagraphStyleAttributeName: paragraphStyle,
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    CGSize textSize = [percentLabelText sizeWithAttributes:attributes];
    CGRect labelRect = CGRectMake(pieChartCenter.x - textSize.width*0.5f,
                                  pieChartCenter.y + pieChartRadius + 4, textSize.width, textSize.height);
    [percentLabelText drawInRect:labelRect withAttributes:attributes];
    

}
- (void)setPercentComplete:(CGFloat)percentComplete
{
    if (percentComplete > 1.0) {
        _percentComplete = 1.0;
    } else if (percentComplete < 0) {
        _percentComplete = 0.0;
    } else {
        _percentComplete = percentComplete;
    }
    [self setNeedsDisplay];
}

@end


@interface DHGameModeSelectionViewController ()

@end

@implementation DHGameModeSelectionViewController

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
    
    [self.gameMode1View setTouchActionWithTarget:self andAction:@selector(loadTutorial)];
    [self.gameMode2View setTouchActionWithTarget:self andAction:@selector(selectGameMode1)];
    [self.gameMode3View setTouchActionWithTarget:self andAction:@selector(selectGameMode2)];
    [self.gameMode4View setTouchActionWithTarget:self andAction:@selector(selectGameMode3)];
    [self.gameMode5View setTouchActionWithTarget:self andAction:@selector(selectGameMode4)];
    [self.gameMode6View setTouchActionWithTarget:self andAction:@selector(loadPlayground)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset progress"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(clearLevelResults)];
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
    
    //NSDictionary *views = NSDictionaryOfVariableBindings(_green, _orange, _labelContainer, _imageView);
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
    [self performSegueWithIdentifier:@"ShowLevelSelection" sender:[NSNumber numberWithUnsignedInteger:kDHGameModeNormal]];
}
- (void)selectGameMode2
{
    [self performSegueWithIdentifier:@"ShowLevelSelection" sender:[NSNumber numberWithUnsignedInteger:kDHGameModeNormalMinimumMoves]];
}
- (void)selectGameMode3
{
    [self performSegueWithIdentifier:@"ShowLevelSelection" sender:[NSNumber numberWithUnsignedInteger:kDHGameModePrimitiveOnly]];
}
- (void)selectGameMode4
{
    [self performSegueWithIdentifier:@"ShowLevelSelection"
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
- (void)clearLevelResults
{
    [DHLevelResults clearLevelResults];
    [[DHGameCenterManager sharedInstance] resetAchievements];
    [self loadProgressData];
}
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
    
    self.gameMode1PercentComplete.percentComplete = levelsCompleteGameModeNormal*1.0/levels.count;
    self.gameMode2PercentComplete.percentComplete = levelsCompleteGameModeMinimumMoves*1.0/levels.count;
    self.gameMode3PercentComplete.percentComplete = levelsCompleteGameModePrimitiveOnly*1.0/levels.count;
    self.gameMode4PercentComplete.percentComplete = levelsCompleteGameModePrimitiveOnlyMinimumMoves*1.0/levels.count;
    
    // Update achievements here if they were not awarded earlier
    if (self.gameMode1PercentComplete.percentComplete == 1.0) {
        [[DHGameCenterManager sharedInstance]
         reportAchievementIdentifier:kAchievementID_GameModeNormal_1_25 percentComplete:100];
    }
    if (self.gameMode2PercentComplete.percentComplete == 1.0) {
        [[DHGameCenterManager sharedInstance]
         reportAchievementIdentifier:kAchievementID_GameModeNormalMinimumMoves_1_25 percentComplete:100];
    }
    if (self.gameMode3PercentComplete.percentComplete == 1.0) {
        [[DHGameCenterManager sharedInstance]
         reportAchievementIdentifier:kAchievementID_GameModePrimitiveOnly_1_25 percentComplete:100];
    }
    if (self.gameMode4PercentComplete.percentComplete == 1.0) {
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end