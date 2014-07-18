//
//  DHSettingsViewController.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-17.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHSettingsViewController.h"
#import "DHSettings.h"

@interface DHSettingsViewController ()

@end

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
    // Do any additional setup after loading the view.
    self.unlockAllLevelsSwitch.on = [DHSettings allLevelsUnlocked];
    [self.unlockAllLevelsSwitch addTarget:self action:@selector(unlockLevels:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
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

@end
