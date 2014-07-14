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

@implementation DHGameModePercentCompleteView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    const CGPoint pieChartCenter = CGPointMake(self.bounds.size.width*0.5, 40);
    CGFloat pieChartRadius = 20.0;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0/self.contentScaleFactor);
    CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1.0);
    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1.0);
    
    if (self.percentComplete > 0) {
        CGContextMoveToPoint(context, pieChartCenter.x, pieChartCenter.y);
        CGContextAddLineToPoint(context, pieChartCenter.x+pieChartRadius, pieChartCenter.y);
        CGContextAddArc(context, pieChartCenter.x, pieChartCenter.y, pieChartRadius, 0, 2*M_PI*self.percentComplete, 0);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
    CGContextStrokeEllipseInRect(context, CGRectMake(pieChartCenter.x-pieChartRadius, pieChartCenter.y-pieChartRadius,
                                                     pieChartRadius*2, pieChartRadius*2));
    
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
    
    UITapGestureRecognizer* tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadTutorial)];
    [self.gameMode1View addGestureRecognizer:tap1];
    self.gameMode1View.backgroundColor = [UIColor whiteColor];
    self.gameMode1View.layer.cornerRadius = 8.0;
    self.gameMode1View.layer.shadowColor = [UIColor blackColor].CGColor;
    self.gameMode1View.layer.shadowOffset = CGSizeMake(3, 3);
    self.gameMode1View.layer.shadowOpacity = 0.5;
    self.gameMode1View.layer.shadowRadius = 8.0;
    self.gameMode1PercentComplete.layer.cornerRadius = 8.0;
    
    UITapGestureRecognizer* tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectGameMode1)];
    [self.gameMode2View addGestureRecognizer:tap2];
    self.gameMode2View.backgroundColor = [UIColor whiteColor];
    self.gameMode2View.layer.cornerRadius = 8.0;
    self.gameMode2View.layer.shadowColor = [UIColor blackColor].CGColor;
    self.gameMode2View.layer.shadowOffset = CGSizeMake(3, 3);
    self.gameMode2View.layer.shadowOpacity = 0.5;
    self.gameMode2View.layer.shadowRadius = 8.0;

    UITapGestureRecognizer* tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectGameMode2)];
    [self.gameMode3View addGestureRecognizer:tap3];
    self.gameMode3View.backgroundColor = [UIColor whiteColor];
    self.gameMode3View.layer.cornerRadius = 8.0;
    self.gameMode3View.layer.shadowColor = [UIColor blackColor].CGColor;
    self.gameMode3View.layer.shadowOffset = CGSizeMake(3, 3);
    self.gameMode3View.layer.shadowOpacity = 0.5;
    self.gameMode3View.layer.shadowRadius = 8.0;

    UITapGestureRecognizer* tap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectGameMode3)];
    [self.gameMode4View addGestureRecognizer:tap4];
    self.gameMode4View.backgroundColor = [UIColor whiteColor];
    self.gameMode4View.layer.cornerRadius = 8.0;
    self.gameMode4View.layer.shadowColor = [UIColor blackColor].CGColor;
    self.gameMode4View.layer.shadowOffset = CGSizeMake(3, 3);
    self.gameMode4View.layer.shadowOpacity = 0.5;
    self.gameMode4View.layer.shadowRadius = 8.0;

    UITapGestureRecognizer* tap5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectGameMode4)];
    [self.gameMode5View addGestureRecognizer:tap5];
    self.gameMode5View.backgroundColor = [UIColor whiteColor];
    self.gameMode5View.layer.cornerRadius = 8.0;
    self.gameMode5View.layer.shadowColor = [UIColor blackColor].CGColor;
    self.gameMode5View.layer.shadowOffset = CGSizeMake(3, 3);
    self.gameMode5View.layer.shadowOpacity = 0.5;
    self.gameMode5View.layer.shadowRadius = 8.0;

    UITapGestureRecognizer* tap6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadPlayground)];
    [self.gameMode6View addGestureRecognizer:tap6];
    self.gameMode6View.backgroundColor = [UIColor whiteColor];
    self.gameMode6View.layer.cornerRadius = 8.0;
    self.gameMode6View.layer.shadowColor = [UIColor blackColor].CGColor;
    self.gameMode6View.layer.shadowOffset = CGSizeMake(3, 3);
    self.gameMode6View.layer.shadowOpacity = 0.5;
    self.gameMode6View.layer.shadowRadius = 8.0;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset progress"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(clearLevelResults)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadProgressData];
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

#pragma mark - Select game modes
- (void)selectGameMode1
{
    [self performSegueWithIdentifier:@"ShowLevelSelection" sender:[NSNumber numberWithUnsignedInteger:kDHGameModeNormal]];
}
- (void)selectGameMode2
{
    [self performSegueWithIdentifier:@"ShowLevelSelection" sender:[NSNumber numberWithUnsignedInteger:kDHGameModeMinimumMoves]];
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
        NSString* resultKey = [NSStringFromClass([level class]) stringByAppendingFormat:@"/%lu", (unsigned long)kDHGameModeNormal];
        NSDictionary* levelResult = [levelResults objectForKey:resultKey];
        if (levelResult) {
            NSNumber* completed = [levelResult objectForKey:kLevelResultKeyCompleted];
            if (completed.boolValue) {
                ++levelsCompleteGameModeNormal;
            }
        }
    }
    for (id level in levels) {
        NSString* resultKey = [NSStringFromClass([level class]) stringByAppendingFormat:@"/%lu", (unsigned long)kDHGameModeMinimumMoves];
        NSDictionary* levelResult = [levelResults objectForKey:resultKey];
        if (levelResult) {
            NSNumber* completed = [levelResult objectForKey:kLevelResultKeyCompleted];
            if (completed.boolValue) {
                ++levelsCompleteGameModeMinimumMoves;
            }
        }
    }
    for (id level in levels) {
        NSString* resultKey = [NSStringFromClass([level class]) stringByAppendingFormat:@"/%lu", (unsigned long)kDHGameModePrimitiveOnly];
        NSDictionary* levelResult = [levelResults objectForKey:resultKey];
        if (levelResult) {
            NSNumber* completed = [levelResult objectForKey:kLevelResultKeyCompleted];
            if (completed.boolValue) {
                ++levelsCompleteGameModePrimitiveOnly;
            }
        }
    }
    for (id level in levels) {
        NSString* resultKey = [NSStringFromClass([level class]) stringByAppendingFormat:@"/%lu", (unsigned long)kDHGameModePrimitiveOnlyMinimumMoves];
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
}

@end