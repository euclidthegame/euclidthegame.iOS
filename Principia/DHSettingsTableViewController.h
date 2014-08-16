//
//  DHSettingsTableViewController.h
//  Euclid
//
//  Created by David Hallgren on 2014-08-02.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHSettingsTableViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UISwitch* unlockAllLevelsSwitch;
@property (nonatomic, weak) IBOutlet UISwitch* showWellDoneMessagesSwitch;
@property (nonatomic, weak) IBOutlet UISwitch* showProgressPercentageSwitch;

@property BOOL showHiddenSettings;

- (IBAction)resetAllProgress:(id)sender;
- (IBAction)restorePurchases:(id)sender;


@end

