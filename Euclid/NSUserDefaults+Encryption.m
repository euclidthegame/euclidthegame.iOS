//
//  NSUserDefaults+Encryption.m
//
//  Created by Ashutosh Desai on 11/6/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "NSUserDefaults+Encryption.h"

@implementation NSUserDefaults(Encryption)

static NSString *encryptionKey = @"nsusdefencryption";

- (void)setEncryptionKey:(NSString*)encryptionKeyString
{
	encryptionKey = encryptionKeyString;
}

- (void)setObjectEncrypted:(id)value forKey:(NSString *)defaultName
{
	if (!value || !defaultName)
		return;
	
	NSData *k = [encryptionKey dataUsingEncoding:NSUTF8StringEncoding];
	NSData *valueData = [NSKeyedArchiver archivedDataWithRootObject:value];
	NSData *defaultData = [NSKeyedArchiver archivedDataWithRootObject:defaultName];
	NSData *valueCrypt = [self symmetricEncrypt:valueData withKey:k];
	NSData *defaultCrypt = [self symmetricEncrypt:defaultData withKey:k];
	NSString *defaultCryptName = [defaultCrypt base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
	
	[[NSUserDefaults standardUserDefaults] setObject:valueCrypt forKey:defaultCryptName];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)objectEncryptedForKey:(NSString *)defaultName
{
	if (!defaultName)
		return nil;
	
	NSData *k = [encryptionKey dataUsingEncoding:NSUTF8StringEncoding];
	NSData *defaultData = [NSKeyedArchiver archivedDataWithRootObject:defaultName];
	NSData *defaultCrypt = [self symmetricEncrypt:defaultData withKey:k];
	NSString *defaultCryptName = [defaultCrypt base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
	
	NSData *valueCrypt = [[NSUserDefaults standardUserDefaults] objectForKey:defaultCryptName];
	if (!valueCrypt)
		return nil;
	NSData *d = [self symmetricDecrypt:valueCrypt withKey:k];
	return [NSKeyedUnarchiver unarchiveObjectWithData:d];
}

- (void)removeObjectEncryptedForKey:(NSString *)defaultName
{
	NSData *k = [encryptionKey dataUsingEncoding:NSUTF8StringEncoding];
	NSData *defaultData = [NSKeyedArchiver archivedDataWithRootObject:defaultName];
	NSData *defaultCrypt = [self symmetricEncrypt:defaultData withKey:k];
	NSString *defaultCryptName = [defaultCrypt base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:defaultCryptName];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSData *)symmetricEncrypt: (NSData *) d withKey: (NSData *) k
{
	size_t l;
	void *e = malloc([d length] + kCCBlockSizeAES128);
	if(CCCrypt(kCCEncrypt,
			   kCCAlgorithmAES128,
			   kCCOptionPKCS7Padding,
			   [k bytes],
			   kCCKeySizeAES128,
			   NULL,
			   [d bytes],
			   [d length],
			   e,
			   [d length] + kCCBlockSizeAES128,
			   &l)
	   != kCCSuccess)
	{
		free(e);
		return nil;
	}
	
	NSData *o = [NSData dataWithBytes: e length: l];
	free(e);
	
	return o;
}

- (NSData *)symmetricDecrypt: (NSData *) d withKey: (NSData *) k
{
	size_t l;
	void *e = malloc([d length] + kCCBlockSizeAES128);
	
	if(CCCrypt(kCCDecrypt,
			   kCCAlgorithmAES128,
			   kCCOptionPKCS7Padding,
			   [k bytes],
			   kCCKeySizeAES128,
			   NULL,
			   [d bytes],
			   [d length],
			   e,
			   [d length] + kCCBlockSizeAES128,
			   &l)
	   != kCCSuccess)
	{
		free(e);
		return nil;
	}
	
	NSData *o = [NSData dataWithBytes: e length: l];
	free(e);
	
	return o;
}

@end
