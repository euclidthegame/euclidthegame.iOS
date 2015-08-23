//
//  DHLevelPlayground.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-13.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelPlayground.h"


@implementation DHLevelPlayground

- (NSString*)levelDescription
{
    return (@"None, simply enjoy geometric beauty!");
}

- (DHToolsAvailable)availableTools
{
    return (DHAllToolsAvailable);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 10;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{

}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    return NO;
}


@end


