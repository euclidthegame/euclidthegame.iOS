//
//  DHViewController.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHGeometricTools.h"
#import "DHLevel.h"
#import "DHGeometryView.h"

@interface DHGeometryViewController : UIViewController

@property (nonatomic, strong) id<DHGeometryTool> currentTool;
@property (nonatomic, strong) IBOutlet DHGeometryView* geometryView;

@end
