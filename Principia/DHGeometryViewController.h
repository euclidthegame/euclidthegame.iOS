//
//  DHViewController.h
//  Principia
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHLevel.h"

@interface DHGeometryViewController : UIViewController

@property (nonatomic, weak) IBOutlet UISegmentedControl* toolControl;
@property (nonatomic, weak) IBOutlet UILabel* toolInstruction;
@property (nonatomic, weak) IBOutlet UILabel* levelTitle;
@property (nonatomic, weak) IBOutlet UILabel* levelInstruction;

- (IBAction)resetGeometricObject:(id)sender;

@end
