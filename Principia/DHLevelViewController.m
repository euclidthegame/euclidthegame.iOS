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
    NSMutableArray* _geometricObjectsForUndo;
    NSMutableArray* _geometricObjectsForRedo;
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
    self.geometryView.geometryScale = 1.0;

    _geometricObjectsForUndo = [[NSMutableArray alloc] init];
    _geometricObjectsForRedo = [[NSMutableArray alloc] init];
    
    _tools = [[NSMutableArray alloc] init];
    
    [_toolControl addTarget:self
                     action:@selector(toolChanged:)
           forControlEvents:UIControlEventValueChanged];
    
    // Set up according to level
    UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem *resetButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(resetLevel)];
    UIBarButtonItem *undoButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Undo"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(undoMove)];
    UIBarButtonItem *redoButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Redo"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(redoMove)];
    self.navigationItem.rightBarButtonItem = resetButtonItem;
    self.navigationItem.rightBarButtonItems = @[resetButtonItem, separator, redoButtonItem, undoButtonItem];
    _levelInstruction.layer.cornerRadius = 10.0f;
    [self resetLevel];
    
    // Set up completion message
    self.levelCompletionMessage.layer.cornerRadius = 10.0;
    self.levelCompletionMessage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.levelCompletionMessage.layer.shadowOffset = CGSizeMake(5, 5);
    self.levelCompletionMessage.layer.shadowOpacity = 0.5;
    self.levelCompletionMessage.layer.shadowRadius = 10.0;
    [self.levelCompletionMessage removeFromSuperview];
    
    [self setupForLevel];
}

- (void)setupForLevel
{
    if (self.levelIndex == 0) {
        self.title = @"Tutorial";
    } else if (self.levelIndex > 0) {
        self.title = [NSString stringWithFormat:@"Challenge %d", self.levelIndex];
    }
    
    _levelInstruction.text = [@"Challenge objective: " stringByAppendingString:[_currentLevel levelDescription]];

    [self setupTools];
    _currentTool = [[DHPointTool alloc] init];
    _currentTool.delegate = self;
    self.geometryViewController.currentTool = _currentTool;
    _toolInstruction.text = _currentTool.initialToolTip;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Helper functions for managing geometric objects
- (void)addGeometricObject:(id)object
{
    if ([_geometricObjectsForRedo containsObject:object]) {
        // Added from redo, do nothing
    } else {
        // New item, clear redo-list
        [_geometricObjectsForRedo removeAllObjects];
    }
    
    if ([[object class] isSubclassOfClass:[DHPoint class]]) {
        DHPoint* p = object;
        if (p.label == nil) {
            p.label = [DHGeometricObjectLabeler nextLabel];
        }
        [_geometricObjects addObject:object];
    } else {
        [_geometricObjects insertObject:object atIndex:0];
        self.levelMoves++;
        self.movesLabel.text = [NSString stringWithFormat:@"Moves: %d", self.levelMoves];
    }
    
    [_geometricObjectsForUndo addObject:object];
    
    [self.geometryView setNeedsDisplay];
    
    // Test if level matches completion objective
    if ([_currentLevel isLevelComplete:_geometricObjects] && self.levelCompletionMessage.superview == nil) {
        NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
        [result setObject:[NSNumber numberWithBool:YES] forKey:kLevelResultKeyCompleted];
        [DHLevelResults newResult:result forLevel:NSStringFromClass([_currentLevel class])];
        [self showLevelCompleteMessage];
    }
}

- (void)resetLevel
{
    [DHGeometricObjectLabeler reset];
    [_geometricObjects removeAllObjects];
    
    NSMutableArray* levelObjects = [[NSMutableArray alloc] init];
    [_currentLevel setUpLevel:levelObjects];
    for (id object in levelObjects) {
        [self addGeometricObject:object];
    }
 
    self.levelMoves = 0;
    self.movesLabel.text = [NSString stringWithFormat:@"Moves: %d", self.levelMoves];
    [_geometricObjectsForRedo removeAllObjects];
    [_geometricObjectsForUndo removeAllObjects];
    
    [self.geometryView setNeedsDisplay];
    [self.levelCompletionMessage removeFromSuperview];
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
    
    BOOL toolText = NO;
    
    if (availableTools & DHPointToolAvailable) {
        if(toolText) [_toolControl insertSegmentWithTitle:@"Point" atIndex:index++ animated:NO];
        if(!toolText) [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolPoint"] atIndex:index++ animated:NO];
        [_tools addObject:[DHPointTool class]];
    }

    if (availableTools & DHIntersectToolAvailable) {
        if(toolText) [_toolControl insertSegmentWithTitle:@"Intersect" atIndex:index++ animated:NO];
        if(!toolText) [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolIntersect"] atIndex:index++ animated:NO];
        [_tools addObject:[DHIntersectTool class]];
    }
    
    if (availableTools & DHLineToolAvailable) {
        if(toolText) [_toolControl insertSegmentWithTitle:@"Line" atIndex:index++ animated:NO];
        if(!toolText) [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolLine"] atIndex:index++ animated:NO];
        [_tools addObject:[DHLineTool class]];
    }
    
    if (availableTools & DHRayToolAvailable) {
        if(toolText) [_toolControl insertSegmentWithTitle:@"Ray" atIndex:index++ animated:NO];
        if(!toolText) [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolRay"] atIndex:index++ animated:NO];
        [_tools addObject:[DHRayTool class]];
    }
    
    if (availableTools & DHCircleToolAvailable) {
        if(toolText) [_toolControl insertSegmentWithTitle:@"Circle" atIndex:index++ animated:NO];
        if(!toolText) [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolCircle"] atIndex:index++ animated:NO];
        [_tools addObject:[DHCircleTool class]];
    }

    if (availableTools & DHTriangleToolAvailable) {
        if(toolText) [_toolControl insertSegmentWithTitle:@"Triangle" atIndex:index++ animated:NO];
        if(!toolText) [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolTriangle"] atIndex:index++ animated:NO];
        [_tools addObject:[DHTriangleTool class]];
    }
    
    if (availableTools & DHMidpointToolAvailable) {
        if(toolText) [_toolControl insertSegmentWithTitle:@"Midpoint" atIndex:index++ animated:NO];
        if(!toolText) [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolMidpoint"] atIndex:index++ animated:NO];
        [_tools addObject:[DHMidPointTool class]];
    }

    if (availableTools & DHBisectToolAvailable) {
        if(toolText) [_toolControl insertSegmentWithTitle:@"Bisect" atIndex:index++ animated:NO];
        if(!toolText) [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolBisect"] atIndex:index++ animated:NO];
        [_tools addObject:[DHBisectTool class]];
    }

    if (availableTools & DHPerpendicularToolAvailable) {
        if(toolText) [_toolControl insertSegmentWithTitle:@"Perp." atIndex:index++ animated:NO];
        if(!toolText) [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolPerpendicular"] atIndex:index++ animated:NO];
        [_tools addObject:[DHPerpendicularTool class]];
    }

    if (availableTools & DHParallelToolAvailable) {
        if(toolText) [_toolControl insertSegmentWithTitle:@"Para." atIndex:index++ animated:NO];
        if(!toolText) [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolParallel"] atIndex:index++ animated:NO];
        [_tools addObject:[DHParallelTool class]];
    }

    if (availableTools & DHTranslateToolAvailable) {
        if(toolText) [_toolControl insertSegmentWithTitle:@"Trans." atIndex:index++ animated:NO];
        if(!toolText) {
            [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolTranslateSegment"]
                                         atIndex:index++ animated:NO];
        }
        [_tools addObject:[DHTranslateSegmentTool class]];
    }
    
    if (availableTools & DHCompassToolAvailable) {
        if(toolText) [_toolControl insertSegmentWithTitle:@"Compass" atIndex:index++ animated:NO];
        if(!toolText) [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolCompass"] atIndex:index++ animated:NO];
        [_tools addObject:[DHCompassTool class]];
    }
    
    /*if (availableTools & DHMoveToolAvailable) {
        if(toolText) [_toolControl insertSegmentWithTitle:@"Move" atIndex:index++ animated:NO];
        if(!toolText) [_toolControl insertSegmentWithImage:[UIImage imageNamed:@"toolPoint"] atIndex:index++ animated:NO];
        [_tools addObject:[DHMoveTool class]];
    }*/
    
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

#pragma mark - Undo/Redo
- (void)undoMove
{
    id objectToUndo = [_geometricObjectsForUndo lastObject];
    if (!objectToUndo) {
        return;
    }
    
    [_geometricObjects removeObject:objectToUndo];
    [_geometricObjectsForUndo removeObject:objectToUndo];
    [_geometricObjectsForRedo addObject:objectToUndo];

    if ([[objectToUndo class] isSubclassOfClass:[DHPoint class]] == NO) {
        self.levelMoves--;
        self.movesLabel.text = [NSString stringWithFormat:@"Moves: %d", self.levelMoves];
    }
    
    [self.geometryView setNeedsDisplay];
}

- (void)redoMove
{
    id objectToRedo = [_geometricObjectsForRedo lastObject];
    if (!objectToRedo) {
        return;
    }
    
    [self addGeometricObject:objectToRedo];

    [_geometricObjectsForRedo removeObject:objectToRedo];
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

- (void)showLevelCompleteMessage
{
    self.levelCompletionMessageAdditional.text = @"";
    if ([_currentLevel respondsToSelector:@selector(additionalCompletionMessage)]) {
        self.levelCompletionMessageAdditional.text = [_currentLevel additionalCompletionMessage];
    }
    
    self.levelCompletionMessage.alpha = 0;
    [self.view addSubview:self.levelCompletionMessage];
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.levelCompletionMessage.alpha = 1;
                     }
                     completion:^(BOOL finished){
                     }];
}

- (IBAction)loadNextLevel:(id)sender
{
    if (self.levelArray) {
        self.levelIndex = self.levelIndex + 1;
        
        id<DHLevel> nextLevel = [[[[self.levelArray objectAtIndex:self.levelIndex] class] alloc] init];
        if (nextLevel) {
            _currentLevel = nextLevel;
            [self resetLevel];
            [self setupForLevel];
        }
    }
}

- (IBAction)hideCompletionMessage:(id)sender
{
    [self.levelCompletionMessage removeFromSuperview];
}



@end
