//
//  DHPopupView.h
//  Euclid
//
//  Created by David Hallgren on 2014-08-19.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DHPopoverView;

@protocol DHPopoverViewDelegate
- (void)closePopoverView:(DHPopoverView *)popoverView;
- (void)popoverViewDidClose:(DHPopoverView *)popoverView;
- (void)popoverView:(DHPopoverView *)popoverView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (UIColor*)popOverTintColor;
@end

@interface DHPopoverView : UIView

@property (nonatomic, weak) UIViewController <DHPopoverViewDelegate> *delegate;

- (id)initWithOriginFrame:(CGRect)originFrame delegate:(UIViewController<DHPopoverViewDelegate>*)delegate firstButtonTitle:(NSString*)firstButtonTitle;
- (void)show;
- (void)dismissWithAnimation:(BOOL)animated;
- (NSInteger)addButtonWithTitle:(NSString*)title;
- (NSInteger)addButtonWithTitle:(NSString*)title enabled:(BOOL)enabled;

@end
