//
//  DHGameModeSelectionViewController.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-13.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHGameModeSelectionButton : UIView
- (void)setTouchActionWithTarget:(id)target andAction:(SEL)action;
@end

@interface DHGameModePercentCompleteView : UIView
@property (nonatomic) CGFloat percentComplete;
@end

@interface DHGameModeSelectionViewController : UIViewController

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *layoutConstraintsPortrait;
@property (strong, nonatomic) NSMutableArray *layoutConstraintsLandscape;

@property (nonatomic, weak) IBOutlet UIImageView* logoImageView;
@property (nonatomic, weak) IBOutlet UILabel* logoLabel;
@property (nonatomic, weak) IBOutlet UILabel* selectGameModelLabel;
@property (nonatomic, weak) IBOutlet UIButton* gameCenterButton;

@property (nonatomic, weak) IBOutlet DHGameModeSelectionButton* gameMode1View;
@property (nonatomic, weak) IBOutlet DHGameModeSelectionButton* gameMode2View;
@property (nonatomic, weak) IBOutlet DHGameModeSelectionButton* gameMode3View;
@property (nonatomic, weak) IBOutlet DHGameModeSelectionButton* gameMode4View;
@property (nonatomic, weak) IBOutlet DHGameModeSelectionButton* gameMode5View;
@property (nonatomic, weak) IBOutlet DHGameModeSelectionButton* gameMode6View;

@property (nonatomic, weak) IBOutlet DHGameModePercentCompleteView* gameMode1PercentComplete;
@property (nonatomic, weak) IBOutlet DHGameModePercentCompleteView* gameMode2PercentComplete;
@property (nonatomic, weak) IBOutlet DHGameModePercentCompleteView* gameMode3PercentComplete;
@property (nonatomic, weak) IBOutlet DHGameModePercentCompleteView* gameMode4PercentComplete;


- (IBAction)showLeaderboards:(id)sender;
- (IBAction)closeSettings:(UIStoryboardSegue *)unwindSegue;

@end
