//
//  DHPopupView.h
//  Euclid
//
//  Created by David Hallgren on 2014-08-19.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DHPopoverViewVerticalDirection) {
    DHPopoverViewVerticalDirectionDown,
    DHPopoverViewVerticalDirectionUp
};

@class DHPopoverView;

@protocol DHPopoverViewDelegate
- (void)closePopoverView:(DHPopoverView *)popoverView;
- (void)popoverViewDidClose:(DHPopoverView *)popoverView;
- (void)popoverView:(DHPopoverView *)popoverView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (UIColor*)popOverTintColor;
@end

@interface DHPopoverView : UIView

@property (nonatomic) DHPopoverViewVerticalDirection verticalDirection;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat buttonHeight;
@property (nonatomic) CGFloat separatorInset;
@property (nonatomic, weak) UIViewController <DHPopoverViewDelegate> *delegate;

- (id)initWithOriginFrame:(CGRect)originFrame delegate:(UIViewController<DHPopoverViewDelegate>*)delegate firstButtonTitle:(NSString*)firstButtonTitle;
- (void)show;
- (void)dismissWithAnimation:(BOOL)animated;
- (NSInteger)addButtonWithTitle:(NSString*)title;
- (NSInteger)addButtonWithTitle:(NSString*)title enabled:(BOOL)enabled;
- (NSString*)titleForButton:(NSInteger)buttonIndex;

- (NSInteger)addButtonWithImage:(UIImage*)image enabled:(BOOL)enabled;
- (UIImage*)imageForButton:(NSInteger)buttonIndex;

@end
