//
//  DHViewController.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <UIKit/UIKit.h>
#import "DHGeometricTools.h"
#import "DHLevel.h"
#import "DHGeometryView.h"

@interface DHGeometryViewController : UIViewController

@property (nonatomic, strong) DHLevel<DHLevel>* currentLevel;
@property (nonatomic, strong) id<DHGeometryTool> currentTool;
@property (nonatomic, strong) IBOutlet DHGeometryView* geometryView;

@end
