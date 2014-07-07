//
//  DHLevelPerpendicularB.h
//  Principia
//
//  Created by David Hallgren on 2014-07-04.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHLevel.h"

@interface DHLevelPerpendicularB : NSObject <DHLevel>

- (NSString*)levelDescription;
- (void)setUpLevel:(NSMutableArray *)geometricObjects;
- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects;

@end