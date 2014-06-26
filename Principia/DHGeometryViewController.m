//
//  DHViewController.m
//  Principia
//
//  Created by David Hallgren on 2014-06-23.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHGeometryViewController.h"
#import "DHGeometryView.h"
#import "DHMath.h"

@interface DHGeometryViewController () {
    NSMutableArray* _geometricObjects;
    id<DHGeometryTool> _currentTool;
}

@end

@implementation DHGeometryViewController

#pragma mark Life-cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _geometricObjects = [[NSMutableArray alloc] init];
    ((DHGeometryView*)self.view).geometricObjects = _geometricObjects;
    
    _currentTool = [[DHPointTool alloc] init];
    _currentTool.delegate = self;
    _toolInstruction.text = _currentTool.initialToolTip;
    
    [_toolControl addTarget:self
                         action:@selector(toolChanged:)
               forControlEvents:UIControlEventValueChanged];
    
    // Set up according to level
    _levelTitle.text = [_currentLevel levelTitle];
    _levelInstruction.text = [_currentLevel levelDescription];
    [_currentLevel setUpLevel:_geometricObjects];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Manage input
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch* touch in touches) {
        [_currentTool touchBegan:touch];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch* touch in touches) {
        [_currentTool touchMoved:touch];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch* touch in touches) {
        [_currentTool touchEnded:touch];
    }
}

#pragma mark Helper functions for managing geometric objects
- (void)addGeometricObject:(id)object
{
    [_geometricObjects addObject:object];
    [self.view setNeedsDisplay];
    if ([_currentLevel isLevelComplete:_geometricObjects]) {
        // Manage level completion
        NSLog(@"Level competed");
    }
}

- (IBAction)resetGeometricObject:(id)sender
{
    [_geometricObjects removeAllObjects];
    [self.view setNeedsDisplay];
}

#pragma mark Layout/appereance
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark Toolbar functions
- (void)toolChanged:(id)sender
{
    _currentTool = nil;
    switch (_toolControl.selectedSegmentIndex) {
        case 0:
            _currentTool = [[DHPointTool alloc] init];
            break;
        case 1:
            _currentTool = [[DHLineTool alloc] init];
            break;
        case 2:
            _currentTool = [[DHCircleTool alloc] init];
            break;
        case 3:
            _currentTool = [[DHIntersectTool alloc] init];
            break;
        case 4:
            _currentTool = [[DHMoveTool alloc] init];
            break;
        default:
            break;
    }
    assert(_currentTool);
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

@end
