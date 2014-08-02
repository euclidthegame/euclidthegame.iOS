//
//  DHLevelSelection2LevelCell.h
//  Euclid
//
//  Created by David Hallgren on 2014-08-02.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHLevel.h"

@interface DHLevelSelection2LevelCell : UICollectionViewCell

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) DHLevel<DHLevel>* level;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL levelCompleted;

- (void)setTouchActionWithTarget:(id)target andAction:(SEL)action;

@end
