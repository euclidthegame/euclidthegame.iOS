//
//  DHAboutViewController.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-25.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHAboutViewController.h"

@implementation DHAboutViewController {
    BOOL _iPhoneVersion;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        _iPhoneVersion = YES;
    }
    
    if (!_iPhoneVersion) {
        self.navigationController.view.layer.cornerRadius = 10;
        self.navigationController.view.layer.masksToBounds = YES;
        self.navigationController.view.superview.backgroundColor = [UIColor clearColor];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
