//
//  DHWeakReference.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-23.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHWeakReference.h"

@implementation DHWeakReference 
- (id) initWithObject:(id) object {
    if (self = [super init]) {
        nonretainedObjectValue = originalObjectValue = object;
    }
    return self;
}

+ (DHWeakReference *) weakReferenceWithObject:(id) object {
    return [[self alloc] initWithObject:object];
}

- (id) nonretainedObjectValue { return nonretainedObjectValue; }
- (void *) originalObjectValue { return (__bridge void *) originalObjectValue; }

// To work appropriately with NSSet
- (BOOL) isEqual:(DHWeakReference *) object {
    if (![object isKindOfClass:[DHWeakReference class]]) return NO;
    return object.originalObjectValue == self.originalObjectValue;
}


@end
