//
//  DHLevel1.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHLevel.h"

@interface DHLevelTutorial : NSObject <DHLevel>

- (NSString*)levelDescription;
- (void)createInitialObjects:(NSMutableArray *)geometricObjects;
- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects;

@end
