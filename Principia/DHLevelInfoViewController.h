//
//  DHLevelInfoViewController.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-09.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHGeometryView.h"

@interface DHLevelInfoViewController : UIViewController

@property (nonatomic, strong) IBOutlet DHGeometryView* geometryView;
@property (nonatomic, strong) IBOutlet UIButton* startButton;
@property (nonatomic, strong) IBOutlet UILabel* objectiveLabel;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@end
