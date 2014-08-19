//
//  DHGameModeSelectionButton.h
//  Euclid
//
//  Created by David Hallgren on 2014-08-18.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHGameModePercentCompleteView : UIView
@property (nonatomic) CGFloat percentComplete;
@end


@interface DHGameModeSelectionButton : UIView
@property (nonatomic) CGFloat percentComplete;
@property (nonatomic) BOOL showPercentComplete;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* gameModeDescription;

- (void)setTouchActionWithTarget:(id)target andAction:(SEL)action;

@end