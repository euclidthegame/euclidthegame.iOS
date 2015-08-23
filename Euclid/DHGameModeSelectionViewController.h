//
//  DHGameModeSelectionViewController.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-13.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <UIKit/UIKit.h>
#import "DHGameModeSelectionButton.h"

@interface DHGameModeSelectionViewController : UIViewController

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *layoutConstraintsPortrait;
@property (strong, nonatomic) NSMutableArray *layoutConstraintsLandscape;
@property (strong, nonatomic) NSMutableArray *layoutConstraintsiPhone;

@property (nonatomic, weak) IBOutlet UIImageView* logoImageView;
@property (nonatomic, weak) IBOutlet UILabel* logoLabel;
@property (nonatomic, weak) IBOutlet UILabel* logoSubtitleLabel;
@property (nonatomic, weak) IBOutlet UILabel* selectGameModelLabel;

@property (nonatomic, weak) IBOutlet DHGameModeSelectionButton* gameMode1View;
@property (nonatomic, weak) IBOutlet DHGameModeSelectionButton* gameMode2View;
@property (nonatomic, weak) IBOutlet DHGameModeSelectionButton* gameMode3View;
@property (nonatomic, weak) IBOutlet DHGameModeSelectionButton* gameMode4View;
@property (nonatomic, weak) IBOutlet DHGameModeSelectionButton* gameMode5View;
@property (nonatomic, weak) IBOutlet DHGameModeSelectionButton* gameMode6View;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* logoImageWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* logoImageHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* logoImageTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* logoImageLeadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* gameMode1ViewWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* gameMode1ViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* selectGameModeLabelDistanceConstraint;
@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *gameModeViewDistanceConstraints;

- (void)showLeaderboards:(id)sender;
- (void)closeSettings:(UIStoryboardSegue *)unwindSegue;

@end
