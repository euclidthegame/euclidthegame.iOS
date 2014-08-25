//
//  DHAboutViewController.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-25.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHAboutViewController.h"

@implementation DHAboutViewController {
    BOOL _iPhoneVersion;
}

- (void)viewDidLoad
{
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
