//
//  DHLevel2.h
//  Principia
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHLevel.h"

@interface DHLevel2 : NSObject <DHLevel>

- (void)setUpLevel:(NSMutableArray *)geometricObjects;
- (BOOL)isLevelComplete;

@end
