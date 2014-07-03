//
//  DHLevelViewController.m
//  Principia
//
//  Created by David Hallgren on 2014-06-26.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelViewController.h"
#import "DHGeometryView.h"
#import "DHMath.h"
#import "DHLevelResults.h"
#import "DHGeometricObjectLabeler.h"

@interface DHLevelViewController () {
    NSMutableArray* _geometricObjects;
    id<DHGeometryTool> _currentTool;
    NSMutableArray* _tools;
}

@end

@implementation DHLevelViewController


#pragma mark Life-cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _geometricObjects = [[NSMutableArray alloc] init];
    self.geometryView.geometricObjects = _geometricObjects;

    _tools = [[NSMutableArray alloc] init];
    [self setupTools];
    _currentTool = [[DHPointTool alloc] init];
    _currentTool.delegate = self;
    self.geometryViewController.currentTool = _currentTool;
    _toolInstruction.text = _currentTool.initialToolTip;
    
    
    [_toolControl addTarget:self
                     action:@selector(toolChanged:)
           forControlEvents:UIControlEventValueChanged];
    
    // Set up according to level
    self.title = [_currentLevel title];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(resetGeometricObjects)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    _levelInstruction.text = [@"Challenge objective: " stringByAppendingString:[_currentLevel levelDescription]];
    _levelInstruction.layer.cornerRadius = 10.0f;
    [DHGeometricObjectLabeler reset];
    [_currentLevel setUpLevel:_geometricObjects];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Helper functions for managing geometric objects
- (void)addGeometricObject:(id)object
{
    [_geometricObjects addObject:object];
    [self.geometryView setNeedsDisplay];
    
    // Test if level matches completion objective
    if ([_currentLevel isLevelComplete:_geometricObjects]) {
        NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
        [result setObject:[NSNumber numberWithBool:YES] forKey:kLevelResultKeyCompleted];
        [DHLevelResults newResult:result forLevel:NSStringFromClass([_currentLevel class])];
        NSLog(@"Level competed");
    }
}

- (void)resetGeometricObjects
{
    [DHGeometricObjectLabeler reset];
    [_geometricObjects removeAllObjects];
    [_currentLevel setUpLevel:_geometricObjects];
    [self.geometryView setNeedsDisplay];
}

#pragma mark Layout/appereance
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark Toolbar functions
- (void)setupTools
{
    [_tools removeAllObjects];
    [_toolControl removeAllSegments];
    
    NSUInteger index = 0;
    
    DHToolsAvailable availableTools = DHAllToolsAvailable;
    
    if ([_currentLevel respondsToSelector:@selector(availableTools)]) {
        availableTools = [_currentLevel availableTools];
    }
    
    if (availableTools & DHPointToolAvailable) {
        [_toolControl insertSegmentWithTitle:@"Point" atIndex:index++ animated:NO];
        [_tools addObject:[DHPointTool class]];
    }

    if (availableTools & DHLineToolAvailable) {
        [_toolControl insertSegmentWithTitle:@"Line" atIndex:index++ animated:NO];
        [_tools addObject:[DHLineTool class]];
    }
    
    if (availableTools & DHRayToolAvailable) {
        [_toolControl insertSegmentWithTitle:@"Ray" atIndex:index++ animated:NO];
        [_tools addObject:[DHRayTool class]];
    }
    
    if (availableTools & DHCircleToolAvailable) {
        [_toolControl insertSegmentWithTitle:@"Circle" atIndex:index++ animated:NO];
        [_tools addObject:[DHCircleTool class]];
    }
    
    if (availableTools & DHIntersectToolAvailable) {
        [_toolControl insertSegmentWithTitle:@"Intersect" atIndex:index++ animated:NO];
        [_tools addObject:[DHIntersectTool class]];
    }
    
    if (availableTools & DHMidpointToolAvailable) {
        [_toolControl insertSegmentWithTitle:@"Midpoint" atIndex:index++ animated:NO];
        [_tools addObject:[DHMidPointTool class]];
    }
    
    if (availableTools & DHMoveToolAvailable) {
        [_toolControl insertSegmentWithTitle:@"Move" atIndex:index++ animated:NO];
        [_tools addObject:[DHMoveTool class]];
    }
    _toolControl.selectedSegmentIndex = 0;

}

- (void)toolChanged:(id)sender
{
    _currentTool = nil;
    _currentTool = [[[_tools objectAtIndex:_toolControl.selectedSegmentIndex] alloc] init];
    assert(_currentTool);
    self.geometryViewController.currentTool = _currentTool;
    _toolInstruction.text = [_currentTool initialToolTip];
    _currentTool.delegate = self;
    [self.view setNeedsDisplay];
}

#pragma mark Geometry tool delegate methods
- (NSArray*)geometryObjects
{
    return _geometricObjects;
}
- (void)toolTipDidChange:(NSString *)currentTip
{
    _toolInstruction.text = currentTip;
}
- (void)addNewGeometricObject:(id)object
{
    [self addGeometricObject:object];
}

#pragma mark Other
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"GeometryViewEmbed"]) {
        DHGeometryViewController * childViewController = (DHGeometryViewController *) [segue destinationViewController];
        self.geometryView = (DHGeometryView*)childViewController.view;
        self.geometryViewController = childViewController;
    }
}
@end
