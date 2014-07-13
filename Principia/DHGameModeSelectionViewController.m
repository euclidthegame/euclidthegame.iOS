//
//  DHGameModeSelectionViewController.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-13.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGameModeSelectionViewController.h"
#import "DHLevelViewController.h"
#import "DHLevelPlayground.h"
#import "DHLevelResults.h"

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
    
    self.gameMode1View.backgroundColor = [UIColor whiteColor];
    self.gameMode1View.layer.cornerRadius = 8.0;
    self.gameMode1View.layer.shadowColor = [UIColor blackColor].CGColor;
    self.gameMode1View.layer.shadowOffset = CGSizeMake(3, 3);
    self.gameMode1View.layer.shadowOpacity = 0.5;
    self.gameMode1View.layer.shadowRadius = 8.0;
    self.gameMode1PercentComplete.layer.cornerRadius = 8.0;
    self.gameMode1PercentComplete.percentComplete = 0.6;
    
    self.gameMode2View.backgroundColor = [UIColor whiteColor];
    self.gameMode2View.layer.cornerRadius = 8.0;
    self.gameMode2View.layer.shadowColor = [UIColor blackColor].CGColor;
    self.gameMode2View.layer.shadowOffset = CGSizeMake(3, 3);
    self.gameMode2View.layer.shadowOpacity = 0.5;
    self.gameMode2View.layer.shadowRadius = 8.0;

    self.gameMode3View.backgroundColor = [UIColor whiteColor];
    self.gameMode3View.layer.cornerRadius = 8.0;
    self.gameMode3View.layer.shadowColor = [UIColor blackColor].CGColor;
    self.gameMode3View.layer.shadowOffset = CGSizeMake(3, 3);
    self.gameMode3View.layer.shadowOpacity = 0.5;
    self.gameMode3View.layer.shadowRadius = 8.0;

    self.gameMode4View.backgroundColor = [UIColor whiteColor];
    self.gameMode4View.layer.cornerRadius = 8.0;
    self.gameMode4View.layer.shadowColor = [UIColor blackColor].CGColor;
    self.gameMode4View.layer.shadowOffset = CGSizeMake(3, 3);
    self.gameMode4View.layer.shadowOpacity = 0.5;
    self.gameMode4View.layer.shadowRadius = 8.0;

    
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
    if ([segue.identifier isEqualToString:@"LoadPlayground"]) {
        DHLevelViewController* vc = [segue destinationViewController];
        vc.currentLevel = [[DHLevelPlayground alloc] init];
        vc.levelArray = nil;
        vc.levelIndex = NSUIntegerMax;
        vc.title = @"Playground";
    }
}


#pragma mark Layout/appereance
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
}

@end
