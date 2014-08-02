//
//  DHSettingsViewController.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-17.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHSettingsViewController.h"
#import "DHSettings.h"

@implementation DHSettingsViewController

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
    
#ifdef DEBUG
    self.developerSettingsView.hidden = NO;
#endif
    
    self.unlockAllLevelsSwitch.on = [DHSettings allLevelsUnlocked];
    [self.unlockAllLevelsSwitch addTarget:self action:@selector(unlockLevels:)
                         forControlEvents:UIControlEventValueChanged];

    self.showWellDoneMessagesSwitch.on = [DHSettings showWellDoneMessages];
    [self.showWellDoneMessagesSwitch addTarget:self action:@selector(setShowWellDoneMessages:)
                              forControlEvents:UIControlEventValueChanged];

    self.showProgressPercentageSwitch.on = [DHSettings showProgressPercentage];
    [self.showProgressPercentageSwitch addTarget:self action:@selector(setShowProgressPercentage:)
                                forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.view.layer.cornerRadius = 10;
    self.view.layer.masksToBounds = YES;
    self.view.superview.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Layout/appereance
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark Other
- (void)unlockLevels:(UISwitch*)sender
{
    [DHSettings setAllLevelsUnlocked:sender.isOn];
}
- (void)setShowWellDoneMessages:(UISwitch*)sender
{
    [DHSettings setShowWellDoneMessages:sender.isOn];
}
- (void)setShowProgressPercentage:(UISwitch*)sender
{
    [DHSettings setShowProgressPercentage:sender.isOn];
}


@end
