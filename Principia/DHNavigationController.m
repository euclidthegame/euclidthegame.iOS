//
//  DHNavigationController.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-12.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHNavigationController.h"

@interface DHNavigationController ()

@end

@implementation DHNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return [self.visibleViewController shouldAutorotate];
}

@end
