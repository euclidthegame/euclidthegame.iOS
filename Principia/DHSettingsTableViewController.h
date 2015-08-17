//
//  DHSettingsTableViewController.h
//  Euclid
//
//  Created by David Hallgren on 2014-08-02.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <UIKit/UIKit.h>

@interface DHSettingsTableViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UISwitch* unlockAllLevelsSwitch;
@property (nonatomic, weak) IBOutlet UISwitch* showWellDoneMessagesSwitch;
@property (nonatomic, weak) IBOutlet UISwitch* showProgressPercentageSwitch;
@property (nonatomic, weak) IBOutlet UISwitch* enableMagnifierSwitch;

@property BOOL showHiddenSettings;

- (IBAction)resetAllProgress:(id)sender;

@end

