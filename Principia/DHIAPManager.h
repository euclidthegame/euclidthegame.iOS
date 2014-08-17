//
//  DHIAPManager.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-17.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
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

- (void)buyProductWithIdentifier:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

@end
