//
//  DHIAPManager.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-17.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <Foundation/Foundation.h>
@import StoreKit;

UIKIT_EXTERN NSString *const DHIAPTransactionFailedNotification;
UIKIT_EXTERN NSString *const DHIAPManagerProductPurchasedNotification;
UIKIT_EXTERN NSString *const DHIAPManagerBecameAvailableNotification;
UIKIT_EXTERN NSString *const DHIAPManagerLevelPack1ProductID;
UIKIT_EXTERN NSInteger const kDHIAPManagerTransactionFailed;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface DHIAPManager : NSObject

@property (nonatomic, readonly) BOOL canMakePurchases;

+ (void)startup;
+ (DHIAPManager*) sharedInstance;

- (SKProduct*)productWithIdentifier:(NSString*)productIdentifier;
- (void)buyProductWithIdentifier:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

- (NSString*)localizedPriceStringForProduct:(SKProduct*)product;

@end
