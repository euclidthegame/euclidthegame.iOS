//
//  DHViewController.h
//  Principia
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHGeometricTools.h"
#import "DHLevel.h"

@interface DHGeometryViewController : UIViewController

@property (nonatomic, strong) id<DHGeometryTool> currentTool;

@end
