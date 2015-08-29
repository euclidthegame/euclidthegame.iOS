//
//  DHSettingsTableViewController.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-02.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHSettingsTableViewController.h"
#import "DHSettings.h"
#import "DHLevelResults.h"
#import "DHGameCenterManager.h"

static const NSUInteger kResetProgressAlertView = 1;

@interface DHSettingsTableViewController ()

@end

@implementation DHSettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showWellDoneMessagesSwitch.on = [DHSettings showWellDoneMessages];
    [self.showWellDoneMessagesSwitch addTarget:self action:@selector(setShowWellDoneMessages:)
                              forControlEvents:UIControlEventValueChanged];
    
    self.showProgressPercentageSwitch.on = [DHSettings showProgressPercentage];
    [self.showProgressPercentageSwitch addTarget:self action:@selector(setShowProgressPercentage:)
                                forControlEvents:UIControlEventValueChanged];
    
    self.unlockAllLevelsSwitch.on = [DHSettings allLevelsUnlocked];
    [self.unlockAllLevelsSwitch addTarget:self action:@selector(unlockLevels:)
                         forControlEvents:UIControlEventValueChanged];

    self.enableMagnifierSwitch.on = [DHSettings magnifierEnabled];
    [self.enableMagnifierSwitch addTarget:self action:@selector(enableMagnifier:)
                         forControlEvents:UIControlEventValueChanged];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    #if TARGET_IPHONE_SIMULATOR
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(enableHiddenSettings)];
        tap.numberOfTapsRequired = 2;
        tap.numberOfTouchesRequired = 2;
        [self.view addGestureRecognizer:tap];
    #endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setShowWellDoneMessages:(UISwitch*)sender
{
    [DHSettings setShowWellDoneMessages:sender.isOn];
}
- (void)setShowProgressPercentage:(UISwitch*)sender
{
    [DHSettings setShowProgressPercentage:sender.isOn];
}
- (void)enableMagnifier:(UISwitch*)sender
{
    [DHSettings setMagnifierEnabled:sender.isOn];
}
- (void)unlockLevels:(UISwitch*)sender
{
    [DHSettings setAllLevelsUnlocked:sender.isOn];
}


- (IBAction)resetAllProgress:(id)sender
{
    NSString* resetMessage = @"Reset progress for all game modes and achievements";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reset progress"
                                                        message:resetMessage
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Reset", nil];
    alertView.tag = kResetProgressAlertView;
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kResetProgressAlertView && buttonIndex == 1) {
        [DHLevelResults clearLevelResults];
        [[DHGameCenterManager sharedInstance] resetAchievements];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!self.showHiddenSettings && section == 2)
    {
        return 0;
    }

    return [super tableView:tableView numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!self.showHiddenSettings && section == 2) {
        return nil;
    }

    return [super tableView:tableView titleForHeaderInSection:section];
}

- (void)enableHiddenSettings
{
    self.showHiddenSettings = YES;
    [self.tableView reloadData];
}

@end
