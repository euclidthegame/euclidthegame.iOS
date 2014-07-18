//
//  DHSettings.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-17.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const kSettingKey_AllLevelsUnlocked = @"AllLevelsUnlocked";

@interface DHSettings : NSObject

+ (BOOL)allLevelsUnlocked;
+ (void)setAllLevelsUnlocked:(BOOL)unlocked;

@end
