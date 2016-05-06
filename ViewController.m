
//
//  ViewController.m
//  ADoCamera
//
//  Created by 杜维欣 on 16/5/6.
//  Copyright © 2016年 Nododo. All rights reserved.
//

#import "ViewController.h"
#import "ADoCameraController.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)openCamera:(UIButton *)sender {
    ADoCameraController *camera = [[ADoCameraController alloc] init];
    [self presentViewController:camera animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
