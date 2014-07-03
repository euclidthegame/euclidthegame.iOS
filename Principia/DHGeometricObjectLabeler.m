//
//  DHGeometricObjectLabeler.m
//  Principia
//
//  Created by David Hallgren on 2014-07-02.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometricObjectLabeler.h"

static char labelLetter = 'A';
static int labelNumber = 0;

@implementation DHGeometricObjectLabeler

+ (NSString*)nextLabel
{
    NSString* label;
    
    if (labelNumber == 0) {
        label = [NSString stringWithFormat:@"%c", labelLetter];
    } else {
        label = [NSString stringWithFormat:@"%c%d", labelLetter, labelNumber];
    }
    
    if (labelLetter == 'Z') {
        labelLetter = 'A';
        ++labelNumber;
    } else {
        ++labelLetter;
    }
    
    return label;
}

+ (void)reset
{
    labelLetter = 'A';
    labelNumber = 0;
}

@end
