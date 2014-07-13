//
//  DHGameModeSelectionViewController.h
//  Euclid
//
//  Created by David Hallgren on 2014-07-13.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHGameModePercentCompleteView : UIView
@property (nonatomic) CGFloat percentComplete;
@end

@interface DHGameModeSelectionViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView* gameMode1View;
@property (nonatomic, weak) IBOutlet UIView* gameMode2View;
@property (nonatomic, weak) IBOutlet UIView* gameMode3View;
@property (nonatomic, weak) IBOutlet UIView* gameMode4View;

@property (nonatomic, weak) IBOutlet DHGameModePercentCompleteView* gameMode1PercentComplete;
@property (nonatomic, weak) IBOutlet DHGameModePercentCompleteView* gameMode2PercentComplete;
@property (nonatomic, weak) IBOutlet DHGameModePercentCompleteView* gameMode3PercentComplete;


@end
