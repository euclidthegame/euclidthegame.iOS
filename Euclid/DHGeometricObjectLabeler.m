//
//  DHGeometricObjectLabeler.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-02.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHGeometricObjectLabeler.h"

@implementation DHGeometricObjectLabeler {
    char _labelLetter;
    int _labelNumber;
}

- (id)init
{
    self = [super init];
    if (self) {
        _labelLetter = 'A';
        _labelNumber = 0;
    }
    return self;
}

- (NSString*)nextLabel
{
    NSString* label;
    
    if (_labelNumber == 0) {
        label = [NSString stringWithFormat:@"%c", _labelLetter];
    } else {
        label = [NSString stringWithFormat:@"%c%d", _labelLetter, _labelNumber];
    }
    
    if (_labelLetter == 'Z') {
        _labelLetter = 'A';
        ++_labelNumber;
    } else {
        ++_labelLetter;
    }
    
    return label;
}

- (void)reset
{
    _labelLetter = 'A';
    _labelNumber = 0;
}

@end
