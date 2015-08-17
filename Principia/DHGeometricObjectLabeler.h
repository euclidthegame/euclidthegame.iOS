//
//  DHGeometricObjectLabeler.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-02.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <Foundation/Foundation.h>

@interface DHGeometricObjectLabeler : NSObject

- (NSString*)nextLabel;
- (void)reset;

@end
