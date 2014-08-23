//
//  Message.h
//  Euclid
//
//  Created by David Hallgren on 2014-08-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
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
@end