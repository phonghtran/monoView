//
//  monoViewViewController.m
//  monoView
//
//  Created by Phong Tran on 5/8/13.
//  Copyright (c) 2013 Phong Tran. All rights reserved.
//

#import "monoViewViewController.h"


#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define RADIANS_DEGREES(rad) ((rad) * 180 / M_PI)

@interface monoViewViewController ()
{
    CMMotionManager *motionmanager;
    CMAttitude *refAttitude;
    CMAttitude *compareAttitude;
    CMDeviceMotion *motionData;
    CGRect testRect;
    int imageCounter;
}

@end

@implementation monoViewViewController

- (CMMotionManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        motionmanager = [[CMMotionManager alloc] init];
    });
    return motionmanager;
}

- (IBAction)resetRef:(id)sender {
    refAttitude = motionData.attitude;
    
   
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    [self swapImage:self];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
        if ([self.sharedManager isDeviceMotionAvailable] == YES) {
         [self.sharedManager setDeviceMotionUpdateInterval:.01];
         
         
         [self.sharedManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
             // attitude
             
             motionData = deviceMotion;
             if (refAttitude == nil) refAttitude = deviceMotion.attitude;
             
             float imageWidth = self.targetImageView.frame.size.width;
             float imageHeight = self.targetImageView.frame.size.height;
             
             // 568 x 320
             // 2048 x 1590
             // left to right is pitch -- left is pos / right is neg
             // top to bottom is roll -- up is neg / down is pos
             // x axis -- 0 to -1480 // -1024 is centerpoint
             // y axis -- 0 to -1270 // -795 is centerpoint
             
             float refRoll = RADIANS_DEGREES(refAttitude.roll);
             float refPitch = RADIANS_DEGREES(refAttitude.pitch);
             float refYaw = RADIANS_DEGREES(refAttitude.yaw);
             float currentYaw = RADIANS_DEGREES(deviceMotion.attitude.yaw);
             float currentPitch = RADIANS_DEGREES(deviceMotion.attitude.pitch);
             float currentRoll = RADIANS_DEGREES(deviceMotion.attitude.roll);
             
             if (!compareAttitude) compareAttitude = deviceMotion.attitude;
             
             float diffTrigger = 0.5;
             
             if (
                 fabs(RADIANS_DEGREES(compareAttitude.yaw) - currentYaw) > diffTrigger ||
                 fabs(RADIANS_DEGREES(compareAttitude.roll) - currentRoll) > diffTrigger
                 ){
                 float xOffset = 0;
                 float yOffset = 0;
                 
                 
                 // normalize the range with reference frame
                 float viewRange = 20;
                 
                 float xMidpoint = imageWidth  / 2 - self.view.frame.size.height / 2;
                 float yMidpoint = imageHeight / 2 - self.view.frame.size.width / 2;
                 
                 
                 // x-axis - yaw
                 
                 if (currentYaw > refYaw + viewRange) currentYaw = refYaw + viewRange;
                 if (currentYaw < refYaw - viewRange) currentYaw = refYaw - viewRange;
                 
                 float percentage = (currentYaw - refYaw) / viewRange;
                 
                 
                 xOffset = percentage * xMidpoint  - xMidpoint;
                 if (xOffset < imageWidth * -1 + self.view.frame.size.height ){
                     xOffset = imageWidth * -1 + self.view.frame.size.height;
                 }
                 
                 // y-axis - roll
                 
                 if (currentRoll > refRoll + viewRange) currentRoll = refRoll + viewRange;
                 if (currentRoll < refRoll - viewRange) currentRoll = refRoll - viewRange;
                 
                 percentage = (currentRoll - refRoll) / viewRange * -1;
                 
                 
                 yOffset = percentage * yMidpoint  - yMidpoint;
                 if (yOffset < imageHeight * -1 + self.view.frame.size.width ){
                     yOffset = imageHeight * -1 + self.view.frame.size.width;
                 }
                 
                 // debug label
                 
                 NSLog( @"original roll: %i\npitch: %i \nyaw: %i\nroll: %i  \npitch: %i  \nyaw: %i\n  \n x: %f // y: %f ",
                   (int)RADIANS_DEGREES(refAttitude.roll),
                   (int)RADIANS_DEGREES(refAttitude.pitch),
                   (int)RADIANS_DEGREES(refAttitude.yaw),
                   (int)RADIANS_DEGREES(deviceMotion.attitude.roll),
                   (int)RADIANS_DEGREES(deviceMotion.attitude.pitch),
                   (int)RADIANS_DEGREES(deviceMotion.attitude.yaw),
                   xOffset,
                   yOffset
                       );
                 
                 
                 [self.targetImageView setFrame:CGRectMake(
                                                           xOffset,
                                                           yOffset,
                                                           self.targetImageView.frame.size.width,
                                                           self.targetImageView.frame.size.height)];
                 
                 if (currentPitch > viewRange){
                     NSLog(@"go back a floor");
                 }
                 
                 if (currentPitch < viewRange * -1){
                     NSLog(@"go up a floor");
                 }
                 
                 compareAttitude = deviceMotion.attitude;
                 [self checkForInfoButtons];
                 
                 
             }
            
             
             
        }];
     }

   
    
}

- (IBAction)testButton:(id)sender {
    NSLog(@"oh happy day");
}

- (void) checkForInfoButtons {
    testRect = CGRectMake(
                          self.targetImageView.frame.origin.x,
                          self.targetImageView.frame.origin.y,
                          self.view.frame.size.height,
                          self.view.frame.size.width);
    
   
   
 
//     NSLog(@"%f, %f\n %f, %f ",
//      testRect.origin.x,
//      testRect.origin.y,
//      testRect.size.width,
//      testRect.size.height
//           );
    
 
    // preferred spot of button relative to imageview frame
    // throw this into array or something
    float xPoint = self.targetImageView.frame.size.width / -2; // happens to be center
    float yPoint = self.targetImageView.frame.size.height / -2; // center
    
    float xPos;
    float yPos;
    
    
    if ((xPoint < testRect.origin.x && xPoint > testRect.origin.x - testRect.size.width ) &&
        (yPoint < testRect.origin.y && yPoint > testRect.origin.y - testRect.size.height )){
        
        xPos = fabsf(xPoint - testRect.origin.x);
        yPos = fabsf(yPoint - testRect.origin.y);
        
        [self.actionButton setFrame:CGRectMake(
                                               xPos,
                                               yPos,
                                               self.actionButton.frame.size.width,
                                               self.actionButton.frame.size.height
                                               )];
        [self.actionButton setAlpha:1];
    }  else {
        [self.actionButton setAlpha:0];
    }
  
    return;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
   }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)swapImage:(id)sender {
    NSString* path;
    
    if (++imageCounter > 2) imageCounter = 0;
    
    if (imageCounter == 0){
         path = [[NSBundle mainBundle] pathForResource:@"hagia" ofType:@"jpg"];
        
    } else if (imageCounter == 1){
         path = [[NSBundle mainBundle] pathForResource:@"church" ofType:@"jpg"];
        
    } else {
         path = [[NSBundle mainBundle] pathForResource:@"pano" ofType:@"jpg"];
    }
    
    UIImage* newImage = [[UIImage alloc] initWithContentsOfFile:path];
    
    [self.targetImageView setImage:newImage];
    
    
    float newHeight = self.view.frame.size.height * 1.25;
    float newWidth = newHeight * newImage.size.width / newImage.size.height;
    
    NSLog(@"height: %f width:%f", newHeight, newWidth);
    [self.targetImageView setFrame:CGRectMake(
                                              self.targetImageView.frame.origin.x,
                                              self.targetImageView.frame.origin.y,
                                              newWidth,
                                              newHeight
                                              )];
    
    [self resetRef:self];
}
@end
