//
//  DHLevel5.h
//  Principia
//
//  Created by David Hallgren on 2014-07-02.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHLevel.h"

@interface DHLevelBisect : NSObject <DHLevel>

- (NSString*)levelDescription;
- (void)setUpLevel:(NSMutableArray *)geometricObjects;
- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects;

@end
