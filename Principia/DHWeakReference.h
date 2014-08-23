//
//  DHWeakReference.h
//  Euclid
//
//  Created by David Hallgren on 2014-08-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHWeakReference : NSObject {
    __weak id nonretainedObjectValue;
    __unsafe_unretained id originalObjectValue;
}

+ (DHWeakReference *) weakReferenceWithObject:(id) object;

- (id) nonretainedObjectValue;
- (void *) originalObjectValue;

@end
