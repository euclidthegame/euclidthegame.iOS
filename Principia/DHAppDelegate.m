//
//  DHAppDelegate.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHAppDelegate.h"
#import "DHGameCenterManager.h"
#import "DHSettings.h"

@implementation DHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self.window setTintColor:[UIColor colorWithRed:238/255.0 green:194/255.0 blue:16/255.0 alpha:1]];
    
    [[DHGameCenterManager sharedInstance] authenticateLocalPlayer];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDHNotificationResetLevelTimer" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

@end
