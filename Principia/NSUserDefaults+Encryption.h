//
//  NSUserDefaults+Encryption.m
//
//  Created by Ashutosh Desai on 11/6/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults(Encryption)

- (void)setEncryptionKey:(NSString*)encryptionKeyString;
- (void)setObjectEncrypted:(id)value forKey:(NSString *)defaultName;
- (id)objectEncryptedForKey:(NSString *)defaultName;
- (void)removeObjectEncryptedForKey:(NSString *)defaultName;

@end
