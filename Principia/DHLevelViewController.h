//
//  DHLevelViewController.h
//  Principia
//
//  Created by David Hallgren on 2014-06-26.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHGeometricTools.h"
#import "DHLevel.h"
#import "DHGeometryViewController.h"
#import "DHGeometryView.h"

@interface DHLevelViewController : UIViewController <DHGeometryToolDelegate>

@property (nonatomic, strong) id<DHLevel> currentLevel;

@property (nonatomic, weak) IBOutlet UISegmentedControl* toolControl;
@property (nonatomic, weak) IBOutlet UILabel* toolInstruction;
@property (nonatomic, weak) IBOutlet UILabel* levelInstruction;
@property (nonatomic, weak) IBOutlet DHGeometryView* geometryView;
@property (nonatomic, weak) DHGeometryViewController* geometryViewController;

- (void)resetGeometricObjects;

//DHGeometryToolDelegate functions
- (NSArray*)geometryObjects;
- (void)toolTipDidChange:(NSString *)currentTip;
- (void)addNewGeometricObject:(id)object;

@end