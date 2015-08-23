//
//  DHLevelSelection2ViewController.m
//  Euclid
//
//  Created by David Hallgren on 2014-08-02.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelSelection2ViewController.h"
#import "DHLevelSelection2LevelCell.h"
#import "DHLevelResults.h"
#import "DHLevels.h"
#import "DHLevelViewController.h"
#import "DHSettings.h"
#import "DHTransitionToLevel.h"

@interface DHLevelSelection2HeaderView : UICollectionReusableView
@property (nonatomic, strong) UILabel* title;
@end
@implementation DHLevelSelection2HeaderView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    {
        _title = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 200, 25)];
        _title.font = [UIFont boldSystemFontOfSize:16];
        _title.textColor = [UIColor lightGrayColor];
        _title.text = @"Beginner";
        [self addSubview:_title];
        //self.backgroundColor = [UIColor redColor];
    }
    return self;
}
@end
@interface DHLevelSelection2FooterView : UICollectionReusableView
@property (nonatomic, strong) UIButton* button;
@property (nonatomic, strong) UILabel* unavailableLabel;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;
@end
@implementation DHLevelSelection2FooterView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)enableButton:(NSNotification*)notification
{
    _button.enabled = YES;
    _unavailableLabel.hidden = YES;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    _button.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    _unavailableLabel.frame = CGRectMake(0, self.bounds.size.height-20, self.bounds.size.width, 20);
}
- (void)showActivityIndicator
{
    [_button removeFromSuperview];
    [_unavailableLabel removeFromSuperview];
    UIActivityIndicatorView* ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    ai.frame = self.bounds;
    [self addSubview:ai];
    [ai startAnimating];
    _activityIndicator = ai;
}
- (void)removeActivityIndicator
{
    if (_activityIndicator) {
        [_activityIndicator removeFromSuperview];
        _activityIndicator = nil;
    }
    [self addSubview:_button];
    [self addSubview:_unavailableLabel];
}
@end


@interface DHLevelSelection2ViewController () <UINavigationControllerDelegate>

@end

@implementation DHLevelSelection2ViewController {
    NSDictionary* _levelResults;
    NSMutableArray* _levels;
    
    BOOL _iPhoneVersion;
}

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
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        _iPhoneVersion = YES;
    }
    
    _levelResults = [DHLevelResults levelResults];
    
    // Create levels array
    _levels = [[NSMutableArray alloc] init];
    FillLevelArray(_levels);
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    if (_iPhoneVersion) {
        [flowLayout setSectionInset:UIEdgeInsetsMake(5, 10, 5, 10)];
        flowLayout.minimumInteritemSpacing = 7;
        flowLayout.minimumLineSpacing = 15;
    } else {
        [flowLayout setSectionInset:UIEdgeInsetsMake(10, 20, 10, 20)];
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.minimumLineSpacing = 30;
    }
    flowLayout.headerReferenceSize = CGSizeMake(0, 32);
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    [self.collectionView registerClass:[DHLevelSelection2LevelCell class]
            forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.collectionView registerClass:[DHLevelSelection2HeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"HeaderView"];
    [self.collectionView registerClass:[DHLevelSelection2FooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:@"FooterView"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Set outself as the navigation controller's delegate so we're asked for a transitioning object
    self.navigationController.delegate = self;
    
    if (_iPhoneVersion) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:nil action:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Stop being the navigation controller's delegate
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection view delegate & data source methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        return 10;
    } else {
        return 5;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger levelIndex;
    if (indexPath.section == 0) {
        levelIndex = indexPath.item;
    } else if (indexPath.section == 1) {
        levelIndex = 10 + indexPath.item;
    } else {
        levelIndex = 20 + indexPath.item;
    }
    DHLevelSelection2LevelCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier"
                                                                           forIndexPath:indexPath];
    
    DHLevel<DHLevel>* level = [_levels objectAtIndex:levelIndex];
    NSString* title = [NSString stringWithFormat:@"Level %ld", (long)(levelIndex+1)];
    
    cell.title = title;
    cell.level = level;
    cell.tag = levelIndex;
    [cell setTouchActionWithTarget:self andAction:@selector(loadLevel:)];
    cell.levelCompleted = NO;
    
    NSString* resultKey = [NSStringFromClass([level class]) stringByAppendingFormat:@"/%lu", (unsigned long)self.currentGameMode];
    NSDictionary* levelResult = [_levelResults objectForKey:resultKey];
    if (levelResult) {
        NSNumber* completed = [levelResult objectForKey:kLevelResultKeyCompleted];
        if (completed.boolValue) {
            cell.levelCompleted = YES;
        }
    }
    
    if (!(indexPath.section == 0 && indexPath.item == 0) && [DHSettings allLevelsUnlocked] == NO) {
        id<DHLevel> previousLevel = [_levels objectAtIndex:levelIndex-1];
        
        cell.enabled = NO;
        
        NSString* previousResultKey = [NSStringFromClass([previousLevel class])
                                       stringByAppendingFormat:@"/%lu", (unsigned long)self.currentGameMode];
        NSDictionary* previousLevelResult = [_levelResults objectForKey:previousResultKey];
        if (previousLevelResult) {
            NSNumber* completedPrevious = [previousLevelResult objectForKey:kLevelResultKeyCompleted];
            if (completedPrevious.boolValue) {
                cell.enabled = YES;
            }
        }
    } else {
        cell.enabled = YES;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_iPhoneVersion) {
        return CGSizeMake(90, 90);
    }
    
    return CGSizeMake(120, 150);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        DHLevelSelection2HeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        reusableview = headerView;
        
        if (indexPath.section == 0) {
            headerView.title.text = @"Beginner";
        } else if (indexPath.section == 1) {
            headerView.title.text = @"Intermediate";
        } else {
            headerView.title.text = @"Expert";
        }
    }
    if (kind == UICollectionElementKindSectionFooter && indexPath.section == 0) {
        DHLevelSelection2FooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reusableview = footerView;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}

#pragma mark Launch level
- (void)loadLevel:(DHLevelSelection2LevelCell*)cell
{
    NSString* storyboardName = @"Main";
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    DHLevelViewController* vc = [storyboard instantiateViewControllerWithIdentifier:@"GeometryView"];
    id<DHLevel> level = cell.level;
    
    if (level) {
        vc.currentLevel = level;
        vc.levelArray = _levels;
        vc.levelIndex = cell.tag;
        vc.title = cell.title;
        vc.currentGameMode = self.currentGameMode;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark Layout/appereance
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark Transition delegate methods
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    if (fromVC == self && [toVC isKindOfClass:[DHLevelViewController class]]) {
        return [[DHTransitionToLevel alloc] init];
    }
    else {
        return nil;
    }
}

#pragma mark - Respond to product purchase
- (void)productPurchased:(NSNotification *)notification
{
    [self.collectionView reloadData];
}

@end
