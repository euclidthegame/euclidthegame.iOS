//
//  Message.h
//  Euclid
//
//  Created by David Hallgren on 2014-08-23.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import <Foundation/Foundation.h>

@interface Message : UILabel
@property (nonatomic) CGPoint point;
@property (nonatomic) BOOL flash;
- (instancetype)initWithMessage:(NSString*)message andPoint:(CGPoint)point;
- (instancetype)initAtPoint:(CGPoint)point addTo:(UIView*)view;
- (void)text:(NSString*)string;
- (void)text:(NSString*)string position:(CGPoint)point;
- (void)position:(CGPoint)point;
- (void)positionFixed:(CGPoint)point;
- (void)positionAbove:(Message*)message;
- (void)positionBelow:(Message*)message;
- (void)appendLine:(NSString*)line withDuration:(CGFloat)duration;
- (void)appendLine:(NSString*)line withDuration:(CGFloat)duration forceNewLine:(BOOL)newLine;
@end