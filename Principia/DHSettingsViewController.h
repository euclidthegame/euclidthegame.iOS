//
//  DHSettingsViewController.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-17.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHSettingsViewController : UIViewController

@property (nonatomic, weak) IBOutlet UISwitch* showWellDoneMessagesSwitch;
@property (nonatomic, weak) IBOutlet UISwitch* showProgressPercentageSwitch;

@property (nonatomic, weak) IBOutlet UISwitch* unlockAllLevelsSwitch;
@property (nonatomic, weak) IBOutlet UIView* developerSettingsView;

@end
