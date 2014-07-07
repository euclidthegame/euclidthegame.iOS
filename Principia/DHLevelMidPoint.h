//
//  DHLevel3.h
//  Principia
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHLevel.h"

@interface DHLevelMidPoint : NSObject <DHLevel>

- (NSString*)levelDescription;
- (void)setUpLevel:(NSMutableArray *)geometricObjects;
- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects;

@end
