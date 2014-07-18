//
//  DHSettings.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-17.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHSettings.h"

@implementation DHSettings

+ (BOOL)allLevelsUnlocked
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL allUnlocked = [userDefaults boolForKey:kSettingKey_AllLevelsUnlocked];
    return allUnlocked;
}

+ (void)setAllLevelsUnlocked:(BOOL)unlocked
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:unlocked forKey:kSettingKey_AllLevelsUnlocked];
    [userDefaults synchronize];
}


@end
