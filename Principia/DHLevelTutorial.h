//
//  DHLevel1.h
//  Euclid
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHLevel.h"

@interface DHLevelTutorial : DHLevel <DHLevel>
- (NSString*)levelDescription;
- (void)createInitialObjects:(NSMutableArray *)geometricObjects;
- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects;
- (void)positionMessagesForOrientation:(UIInterfaceOrientation)orientation;

@end

@interface Message : UILabel
@property (nonatomic) CGPoint point;
- (instancetype)initWithMessage:(NSString*)message andPoint:(CGPoint)point;
- (void)text:(NSString*)string;
- (void)text:(NSString*)string position:(CGPoint)point;
@end
