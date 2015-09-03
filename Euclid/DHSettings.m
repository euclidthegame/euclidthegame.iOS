//
//  DHSettings.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-17.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHSettings.h"
#import "NSUserDefaults+Encryption.h"

@implementation DHSettings
+ (void)initialize
{
    [[NSUserDefaults standardUserDefaults] setEncryptionKey:@"euclidthegameencryptionkey_irtbvfbh"];
}
#pragma mark Helper methods
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
+ (BOOL)getEncryptedBoolSettingForKey:(NSString*)key withDefault:(BOOL)defaultValue
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* valueObject = [userDefaults objectEncryptedForKey:key];
    if (!valueObject) {
        return defaultValue;
    }
    
    BOOL settingValue = [valueObject boolValue];
    return settingValue;
}
+ (void)setEncryptedBoolSettingForKey:(NSString*)key toValue:(BOOL)newValue
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* settingValue = [NSNumber numberWithBool:newValue];
    [userDefaults setObjectEncrypted:settingValue forKey:key];
    [userDefaults synchronize];
}
+ (NSUInteger)getEncryptedUIntSettingForKey:(NSString*)key withDefault:(NSUInteger)defaultValue
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* valueObject = [userDefaults objectEncryptedForKey:key];
    if (!valueObject) {
        return defaultValue;
    }
    
    NSUInteger settingValue = [valueObject unsignedIntegerValue];
    return settingValue;
}
+ (void)setEncryptedUIntSettingForKey:(NSString*)key toValue:(NSUInteger)newValue
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* settingValue = [NSNumber numberWithUnsignedInteger:newValue];
    [userDefaults setObjectEncrypted:settingValue forKey:key];
    [userDefaults synchronize];
}


#pragma mark Settings methods

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
    return [self getBoolSettingForKey:kSettingKey_ShowWellDoneMessages withDefault:YES];
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

+ (BOOL)magnifierEnabled
{
    return [self getBoolSettingForKey:kSettingKey_EnableMagnifier withDefault:NO];
}
+ (void)setMagnifierEnabled:(BOOL)value
{
    [self setBoolSettingForKey:kSettingKey_EnableMagnifier toValue:value];
}

+ (NSUInteger)numberOfObjectsMadeInPlayground
{
    return [self getEncryptedUIntSettingForKey:kSettingKey_ObjectsInPlayground withDefault:0];
}
+ (void)setNumberOfObjectsMadeInPlayground:(NSUInteger)value
{
    [self setEncryptedUIntSettingForKey:kSettingKey_ObjectsInPlayground toValue:value];
}

@end
