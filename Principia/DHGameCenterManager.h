//
//  DHGameCenterManager.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-17.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GameKit;


// Achievement identifiers
static NSString* const kAchievementID_Euclid_GameModeNormal_1_25 = @"Euclid_GameModeNormal_1_25";

@protocol DHGameCenterManagerDelegate

- (BOOL)showAuthenticationHandler;
- (void)playerDidAuthenticate;
- (void)playerDidNotAuthenticate;

@end

@interface DHGameCenterManager : NSObject <GKGameCenterControllerDelegate>

@property (readonly) BOOL gameCenterAvailable;
@property (readonly) BOOL hasLoadedAchievements;
@property (weak, nonatomic) id<DHGameCenterManagerDelegate> delegate;

+ (DHGameCenterManager *)sharedInstance;
- (void)authenticateLocalPlayer;
- (void)showAuthenticationController:(UIViewController*)parent;
- (void)reportScore:(int64_t)score;
- (void)showLeaderboard;

// Manage achievements
- (void) reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent;
- (void) resetAchievements;
- (void)showAchievements;


@end
