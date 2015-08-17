//
//  DHGameCenterManager.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-17.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGameCenterManager.h"


NSString* const DHGameCenterManagerUserDidAuthenticateNotification = @"DHGameCenterManagerUserDidAuthenticateNotification";

@interface DHGameCenterManager() {
    BOOL _userAuthenticated;
    UIViewController *_gcAuthenticationController;
    
    NSMutableDictionary* _achievementsDictionary;
}
@end

@implementation DHGameCenterManager

#pragma mark Initialization

+ (DHGameCenterManager *) sharedInstance {
    static DHGameCenterManager *sharedHelper = nil;
    
    if (!sharedHelper) {
        sharedHelper = [[DHGameCenterManager alloc] init];
    }
    return sharedHelper;
}

- (id)init {
    if ((self = [super init])) {
        _achievementsDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark Player functions

- (void)authenticateLocalPlayer {
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        if (viewController != nil)
        {
            _gcAuthenticationController = viewController;
            if ([self.delegate showAuthenticationHandler] || YES) {
                [self showAuthenticationController:[self topViewController]];
            }
        }
        else if ([GKLocalPlayer localPlayer].isAuthenticated)
        {
            _userAuthenticated = YES;
            _gameCenterAvailable = YES;
            [self loadAchievements];
            [self.delegate playerDidAuthenticate];
            
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:DHGameCenterManagerUserDidAuthenticateNotification object:nil];
        }
        else
        {
            _userAuthenticated = NO;
            _gameCenterAvailable = NO;
            [self.delegate playerDidNotAuthenticate];
        }
    };
}

- (void)showAuthenticationController:(UIViewController*)parent
{
    if(_gcAuthenticationController) {
        [parent presentViewController: _gcAuthenticationController animated: YES completion:nil];
        _gcAuthenticationController = nil;
    }
}

#pragma mark - Manage leaderboard
- (void)reportScore:(int64_t)score forLeaderboard:(NSString*)leaderboard
{
    // Check if Game Center features are enabled, else do nothing
    if (!_gameCenterAvailable) {
        return;
    }
    
    NSString* leaderBoardIdentifier = leaderboard;
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier: leaderBoardIdentifier];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    
    NSArray *scores = @[scoreReporter];
    [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
    }];
}

- (void) showLeaderboard
{
    if (!_gameCenterAvailable) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Game Center" message:@"Leaderboards require that you are signed in to Game Center" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
        
        UIViewController* mainController = [self topViewController];
        [mainController presentViewController: gameCenterController animated: YES completion:nil];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    UIViewController* mainController = [self topViewController];
    [mainController dismissViewControllerAnimated:YES completion:nil];
}

- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

#pragma mark - Manage achievements

- (void) loadAchievements
{
    [_achievementsDictionary removeAllObjects];
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error)
     {
         if (error == nil)
         {
             for (GKAchievement* achievement in achievements)
                 [_achievementsDictionary setObject: achievement forKey: achievement.identifier];
             
             _hasLoadedAchievements = YES;
         }
     }];
}

- (GKAchievement*) getAchievementForIdentifier: (NSString*) identifier
{
    GKAchievement *achievement = [_achievementsDictionary objectForKey:identifier];
    if (achievement == nil)
    {
        achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        [_achievementsDictionary setObject:achievement forKey:achievement.identifier];
    }
    return achievement;
}

- (void) reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent
{
    // Check if Game Center features are enabled, else do nothing
    if (!_gameCenterAvailable) {
        return;
    }
    
    GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
    if (achievement && achievement.percentComplete != percent)
    {
        achievement.percentComplete = percent;
        achievement.showsCompletionBanner = YES;
        NSArray *achievements = @[achievement];
        [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"Error in reporting achievements: %@", error);
            }
        }];
    }
}

- (void) resetAchievements
{
    // Clear all locally saved achievement objects.
    _achievementsDictionary = [[NSMutableDictionary alloc] init];
    // Clear all progress saved on Game Center.
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
     {
         if (error != nil) {
             // handle the error.
         }
     }];
}

- (void) showAchievements
{
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        gameCenterController.viewState = GKGameCenterViewControllerStateAchievements;
        
        UIViewController* mainController = [self topViewController];
        [mainController presentViewController: gameCenterController animated: YES completion:nil];
    }
}


@end
