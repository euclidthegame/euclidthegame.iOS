//
//  DHLevel.h
//  Principia
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DHLevel <NSObject>

- (void)setUpLevel:(NSMutableArray*)geometricObjects;
- (BOOL)isLevelComplete;

@end
