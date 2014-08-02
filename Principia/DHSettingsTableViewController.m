//
//  DHSettingsTableViewController.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-02.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
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

@end
