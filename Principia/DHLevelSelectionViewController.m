//
//  DHLevelSelectionViewController.m
//  Principia
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelSelectionViewController.h"
#import "DHLevelViewController.h"
#import "DHLevels.h"
#import "DHLevelResults.h"

@interface DHLevelSelectionViewController () {
    NSDictionary* _levelResults;
    NSMutableArray* _levels;
}

@end

@implementation DHLevelSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _levelResults = [DHLevelResults levelResults];
    
    // Create levels array
    _levels = [[NSMutableArray alloc] init];
    [_levels addObject:[[DHLevelTutorial alloc] init]];
    for (int i = 1; i < 100; ++i) {
        NSString* levelClass = [NSString stringWithFormat:@"DHLevel%d", i];
        id<DHLevel> level = [[NSClassFromString(levelClass) alloc] init];;
        if (level) {
            [_levels addObject:level];
        } else {
            break;
        }
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear results" style:UIBarButtonItemStylePlain target:self action:@selector(clearLevelResults)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _levels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        //cell.imageView.image = [UIImage imageNamed:@"Checkbox"];
    }
    
    id<DHLevel> level = [_levels objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [level title];
    cell.detailTextLabel.text = [level subTitle];
    cell.imageView.image = nil;
    
    NSDictionary* levelResult = [_levelResults objectForKey:NSStringFromClass([level class])];
    if (levelResult) {
        NSNumber* completed = [levelResult objectForKey:kLevelResultKeyCompleted];
        if (completed.boolValue) cell.imageView.image = [UIImage imageNamed:@"Checkbox"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    DHLevelViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"GeometryView"];
    
    id<DHLevel> level = [self levelForIndexPath:indexPath];
    
    if (level) {
        vc.currentLevel = level;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (id<DHLevel>)levelForIndexPath:(NSIndexPath*)indexPath
{
    id<DHLevel> level = [[[[_levels objectAtIndex:indexPath.row] class] alloc] init];

    return level;
}

- (void)clearLevelResults
{
    [DHLevelResults clearLevelResults];
    _levelResults = [DHLevelResults levelResults];
    [self.tableView reloadData];
}

#pragma mark Layout/appereance
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
