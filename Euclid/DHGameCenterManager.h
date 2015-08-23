//
//  DHGameCenterManager.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-17.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <Foundation/Foundation.h>
@import GameKit;


// Achievement identifiers
static NSString* const kAchievementID_GameModeNormal_1_25 = @"Euclid_GameModeNormal_1_25";
static NSString* const kAchievementID_GameModeNormalMinimumMoves_1_25 = @"Euclid_GameModeNormalMinimumMoves_1_25";
static NSString* const kAchievementID_GameModePrimitiveOnly_1_25 = @"Euclid_GameModePrimitiveOnly_1_25";
static NSString* const kAchievementID_GameModePrimitiveOnlyMinimumMoves_1_25 = @"Euclid_GameModePrimitiveOnlyMinimumMoves_1_25";

static NSString* const kAchievementID_Persistence_30min = @"Euclid_Persistence1";


// Leaderboard identifiers
static NSString* const kLeaderboardID_LevelsCompletedNormal = @"DH.Euclid.LevelsCompleted_Normal";
static NSString* const kLeaderboardID_LevelsCompletedNormalMinimumMoves = @"DH.Euclid.LevelsCompleted_NormalMinimumMoves";
static NSString* const kLeaderboardID_LevelsCompletedPrimitiveOnly = @"DH.Euclid.LevelsCompleted_PrimitiveOnly";
static NSString* const kLeaderboardID_LevelsCompletedPrimitiveOnlyMinimumMoves = @"DH.Euclid.LevelsCompleted_PrimitiveOnlyMinimumMoves";
static NSString* const kLeaderboardID_LevelsCompletedTotal = @"DH.Euclid.LevelsCompleted_Total";

extern NSString * const DHGameCenterManagerUserDidAuthenticateNotification;

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
- (void)reportScore:(int64_t)score forLeaderboard:(NSString*)leaderboard;
- (void)showLeaderboard;

// Manage achievements
- (void) reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent;
- (void) resetAchievements;
- (void)showAchievements;


@end
