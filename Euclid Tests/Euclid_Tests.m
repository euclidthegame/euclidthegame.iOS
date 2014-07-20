//
//  Euclid_Tests.m
//  Euclid Tests
//
//  Created by David Hallgren on 2014-07-20.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DHLevels.h"

@interface Euclid_Tests : XCTestCase

@end

@implementation Euclid_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLevelSolutionsAllTools
{
    NSMutableArray* levels = [[NSMutableArray alloc] init];
    NSMutableArray* geometricObjects = [[NSMutableArray alloc] init];
    FillLevelArray(levels);
    for (id<DHLevel> level in levels) {
        [level createInitialObjects:geometricObjects];
        [level createSolutionPreviewObjects:geometricObjects];
        XCTAssertTrue([level isLevelComplete:geometricObjects],
                      @"Level %@ solution incomplete",
                      NSStringFromClass([level class]));
    }
}

@end
