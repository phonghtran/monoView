//
//  monoViewViewController.h
//  monoView
//
//  Created by Phong Tran on 5/8/13.
//  Copyright (c) 2013 Phong Tran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>


@interface monoViewViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *testLabel;
@property (weak, nonatomic) IBOutlet UILabel *testLabel2;
@property (strong, nonatomic, readonly) CMMotionManager *sharedManager;
@property (weak, nonatomic) IBOutlet UIImageView *targetImageView;
@property (strong, nonatomic) IBOutlet UIView *monoViewController;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

- (IBAction)resetRef:(id)sender;
- (IBAction)swapImage:(id)sender;

@end
