//
//  ADoCameraController.h
//  ADoCamera
//
//  Created by 杜维欣 on 16/5/6.
//  Copyright © 2016年 Nododo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ADoCameraController;

@protocol ADoCameraControllerDelegate <NSObject>

@required

- (void)cameraController:(ADoCameraController *)camera didFinishPickingImage:(UIImage *)image;

@optional

- (void)cameraController:(ADoCameraController *)camera didFinishSavingWithError:(NSError *)error;

@end

@interface ADoCameraController : UIViewController

@property (nonatomic,assign)id <ADoCameraControllerDelegate> cameraDelegate;

@end
