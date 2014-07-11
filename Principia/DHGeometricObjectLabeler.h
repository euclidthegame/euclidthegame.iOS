//
//  DHGeometricObjectLabeler.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-02.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHGeometricObjectLabeler : NSObject

- (NSString*)nextLabel;
- (void)reset;

@end
