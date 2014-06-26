//
//  DHLevelSelectionViewController.m
//  Principia
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelSelectionViewController.h"
#import "DHGeometryViewController.h"
#import "DHLevels.h"

@interface DHLevelSelectionViewController ()

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    DHGeometryViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"GeometryView"];
    
    id<DHLevel> level = [self levelForIndexPath:indexPath];
    
    if (level) {
        vc.currentLevel = level;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (id<DHLevel>)levelForIndexPath:(NSIndexPath*)indexPath
{
    assert(indexPath.row < 3);
    NSString* levelClass = [NSString stringWithFormat:@"DHLevel%d", indexPath.row + 1];
    
    id<DHLevel> level = [[NSClassFromString(levelClass) alloc] init];;
    
    return level;
}

@end
