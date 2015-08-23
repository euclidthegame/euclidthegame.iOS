//
//  DHLevel2.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <Foundation/Foundation.h>
#import "DHLevel.h"

@interface DHLevelEquiTri : DHLevel <DHLevel>

- (NSString*)levelDescription;
- (void)createInitialObjects:(NSMutableArray *)geometricObjects;
- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects;
@end
