//
//  DHLevelSelectionViewController.m
//  Euclid
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
    FillLevelArray(_levels);
    
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
    }
    
    id<DHLevel> level = [_levels objectAtIndex:indexPath.row];
    
    NSString* title = [NSString stringWithFormat:@"Level %ld", (long)(indexPath.row+1)];
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = [level subTitle];
    cell.imageView.image = nil;
    
    NSString* resultKey = [NSStringFromClass([level class]) stringByAppendingFormat:@"/%lu", (unsigned long)self.currentGameMode];
    NSDictionary* levelResult = [_levelResults objectForKey:resultKey];
    if (levelResult) {
        NSNumber* completed = [levelResult objectForKey:kLevelResultKeyCompleted];
        if (completed.boolValue) {
            cell.imageView.image = [[UIImage imageNamed:@"Checkbox"]
                                    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
    
    if (indexPath.row > 0) {
        id<DHLevel> previousLevel = [_levels objectAtIndex:indexPath.row-1];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.enabled = NO;
        cell.userInteractionEnabled = NO;
        
        NSString* previousResultKey = [NSStringFromClass([previousLevel class])
                                       stringByAppendingFormat:@"/%lu", (unsigned long)self.currentGameMode];
        NSDictionary* previousLevelResult = [_levelResults objectForKey:previousResultKey];
        if (previousLevelResult) {
            NSNumber* completedPrevious = [previousLevelResult objectForKey:kLevelResultKeyCompleted];
            if (completedPrevious.boolValue) {
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.textLabel.enabled = YES;
                cell.userInteractionEnabled = YES;
            }
        }

    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.enabled = YES;
        cell.userInteractionEnabled = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* storyboardName = @"Main";
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    DHLevelViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"GeometryView"];
    UITableViewCell* cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    id<DHLevel> level = [self levelForIndexPath:indexPath];
    
    if (level) {
        vc.currentLevel = level;
        vc.levelArray = _levels;
        vc.levelIndex = indexPath.row;
        vc.title = cell.textLabel.text;
        vc.currentGameMode = self.currentGameMode;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (id<DHLevel>)levelForIndexPath:(NSIndexPath*)indexPath
{
    id<DHLevel> level = [[[[_levels objectAtIndex:indexPath.row] class] alloc] init];

    return level;
}

#pragma mark Layout/appereance
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
