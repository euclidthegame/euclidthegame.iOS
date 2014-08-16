//
//  DHIAPManager.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-17.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
@import StoreKit;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface DHIAPManager : NSObject

+ (void)startup;
+ (DHIAPManager*) sharedInstance;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

@end
