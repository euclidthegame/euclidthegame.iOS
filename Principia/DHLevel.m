//
//  DHLevel.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-24.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevel.h"

@implementation DHLevel
@end

@implementation NSObject (Blocks)

- (void)performBlock:(void (^)())block
{
    block();
}

- (void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay
{
    void (^block_)() = [block copy]; // autorelease this if you're not using ARC
    [self performSelector:@selector(performBlock:) withObject:block_ afterDelay:delay];
}

@end

@implementation Message
- (instancetype)initWithMessage:(NSString*)message andPoint:(CGPoint)point
{
    self = [super init];
    if (self) {
        self.alpha = 0;
        self.text = message;
        self.textColor = [UIColor darkGrayColor];
        self.point = point;
        CGRect frame = self.frame;
        frame.origin = self.point;
        self.frame = frame;
        [self sizeToFit];
    }
    return self;
}

- (void)text:(NSString*)string{
    self.text = [NSString stringWithString:string];
    CGRect frame = self.frame;
    frame.origin = self.point;
    self.frame = frame;
    [self sizeToFit];
}
- (void)text:(NSString*)string position:(CGPoint)point{
    self.text = string;
    self.point = point;
    CGRect frame = self.frame;
    frame.origin = self.point;
    self.frame = frame;
    [self sizeToFit];
}
- (void)position:(CGPoint)point{
    self.point = point;
    CGRect frame = self.frame;
    frame.origin = self.point;
    self.frame = frame;
    [self sizeToFit];
}
@end