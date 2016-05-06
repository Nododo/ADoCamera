//
//  ADoCameraController.m
//  ADoCamera
//
//  Created by 杜维欣 on 16/5/6.
//  Copyright © 2016年 Nododo. All rights reserved.
//

#import "ADoCameraController.h"
#import <AVFoundation/AVFoundation.h>

@interface ADoCameraController ()

@property (nonatomic,strong)UIView *topBar;
@property (nonatomic,strong)UIView *preview;
@property (nonatomic,strong)UIView *bottomBar;

@property (nonatomic,strong) AVCaptureSession *captureSession;
@property (nonatomic,strong) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic,strong) AVCaptureStillImageOutput *captureStillImageOutput;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@end

@implementation ADoCameraController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self prepareCaptureSession];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.captureSession startRunning];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.captureSession stopRunning];
}


- (void)prepareCaptureSession {
    
    AVCaptureDevice *captureDevice=[self cameraDeviceWithPosition:AVCaptureDevicePositionBack];
    if (!captureDevice) {
        NSLog(@"添加占位图");
        return;
    }
    
    NSError *error = nil;
    
    _captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"添加占位图");
        return;
    }
    _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    NSDictionary *outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    
    [_captureStillImageOutput setOutputSettings:outputSettings];
    
    if ([self.captureSession canAddInput:_captureDeviceInput]) {
        [self.captureSession addInput:_captureDeviceInput];
    }
    
    if ([self.captureSession canAddOutput:_captureStillImageOutput]) {
        [self.captureSession addOutput:_captureStillImageOutput];
    }
    
    _captureVideoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    
    self.view.layer.masksToBounds = YES;
    
    _captureVideoPreviewLayer.frame = self.view.layer.bounds;
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_captureVideoPreviewLayer];
}

- (UIView *)topBar {
    if (!_topBar) {
        self.topBar = [[UIView alloc] init];
        _topBar.backgroundColor = [UIColor redColor];
        [self.view addSubview:_topBar];
    }
    return _topBar;
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        self.captureSession = [[AVCaptureSession alloc] init];
        [_captureSession setSessionPreset:AVCaptureSessionPresetMedium];
    }
    return _captureSession;
}

- (AVCaptureDevice *)cameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}
@end
