//
//  DHSettings.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-17.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHSettings.h"

@implementation DHSettings

+ (BOOL)getBoolSettingForKey:(NSString*)key withDefault:(BOOL)defaultValue
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![userDefaults objectForKey:key]) {
        return defaultValue;
    }
    
    BOOL settingValue = [userDefaults boolForKey:key];
    return settingValue;
}
+ (void)setBoolSettingForKey:(NSString*)key toValue:(BOOL)newValue
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:newValue forKey:key];
    [userDefaults synchronize];
}

+ (BOOL)allLevelsUnlocked
{
    return [self getBoolSettingForKey:kSettingKey_AllLevelsUnlocked withDefault:NO];
}

+ (void)setAllLevelsUnlocked:(BOOL)unlocked
{
    [self setBoolSettingForKey:kSettingKey_AllLevelsUnlocked toValue:unlocked];
}


+ (BOOL)showWellDoneMessages
{
    return [self getBoolSettingForKey:kSettingKey_ShowWellDoneMessages withDefault:NO];
}
+ (void)setShowWellDoneMessages:(BOOL)value
{
    [self setBoolSettingForKey:kSettingKey_ShowWellDoneMessages toValue:value];
}

+ (BOOL)showProgressPercentage
{
    return [self getBoolSettingForKey:kSettingKey_ShowProgressPercentage withDefault:YES];
}
+ (void)setShowProgressPercentage:(BOOL)value
{
    [self setBoolSettingForKey:kSettingKey_ShowProgressPercentage toValue:value];
}

+ (BOOL)showHints
{
    return [self getBoolSettingForKey:kSettingKey_ShowHints withDefault:NO];
}
+ (void)setShowHints:(BOOL)value
{
    [self setBoolSettingForKey:kSettingKey_ShowHints toValue:value];
}


@end
