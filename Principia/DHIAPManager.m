//
//  DHIAPManager.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-17.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHIAPManager.h"
#import "DHSettings.h"

NSString *const DHIAPManagerProductPurchasedNotification = @"DHIAPManagerProductPurchasedNotification";
NSString *const DHIAPManagerBecameAvailableNotification = @"DHIAPManagerBecameAvailableNotification";

@interface DHIAPManager () <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
    NSMutableSet* _products;
}
@end

@implementation DHIAPManager

+ (void)startup
{
    [self sharedInstance];
}

+ (DHIAPManager *)sharedInstance {
    static dispatch_once_t once;
    static DHIAPManager* sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"DH_Euclid_LevelPack1",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        _products = [[NSMutableSet alloc] init];
        
        [self requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            
        }];
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    //NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        [_products addObject:skProduct];
        /*NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);*/
    }
    
    if (_products.count > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DHIAPManagerBecameAvailableNotification
                                                            object:nil userInfo:nil];
    }
    
    if(_completionHandler) _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    //NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    if(_completionHandler) _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    
    //NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    //NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    //NSLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    //NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    [_purchasedProductIdentifiers addObject:productIdentifier];
    
    if ([productIdentifier isEqualToString:@"DH_Euclid_LevelPack1"]) {
        [DHSettings setLevelPack1Purchased:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DHIAPManagerProductPurchasedNotification
                                                        object:productIdentifier userInfo:nil];
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)buyProductWithIdentifier:(NSString *)productIdentifier
{
    for (SKProduct* product in _products) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self buyProduct:product];
            return;
        }
    }
    //NSLog(@"Error, attept to buy unrecognized product: %@", productIdentifier);
}

- (BOOL)canMakePurchases
{
    return (_products.count > 0) && [SKPaymentQueue canMakePayments];
}

@end
