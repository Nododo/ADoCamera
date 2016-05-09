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

@property (nonatomic,strong) UIView                     *topBar;
@property (nonatomic,strong) UIView                     *preview;
@property (nonatomic,strong) UIView                     *bottomBar;
@property (nonatomic,weak  ) UIButton                   *takeBtn;
@property (nonatomic,weak  ) UIButton                   *cancleBtn;
@property (nonatomic,weak  ) UIButton                   *confirmBtn;
@property (nonatomic,weak  ) UIButton                   *remakeBtn;

@property (nonatomic,strong) UIImage                    *currentImage;

@property (nonatomic,strong) AVCaptureSession           *captureSession;
@property (nonatomic,strong) AVCaptureDeviceInput       *captureDeviceInput;
@property (nonatomic,strong) AVCaptureStillImageOutput  *captureStillImageOutput;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@end

@implementation ADoCameraController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self prepareCaptureSession];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customBottomBar];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.captureSession stopRunning];
}

-(void)dealloc{
    
}

- (void)takePhoto:(UIButton *)btn {
    self.takeBtn.hidden = YES;
    self.takeBtn.backgroundColor = [UIColor purpleColor];
    self.cancleBtn.hidden = YES;
    self.remakeBtn.hidden = NO;
    self.confirmBtn.hidden = NO;
    AVCaptureConnection *captureConnection=[self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            self.currentImage = [UIImage imageWithData:imageData];
            NSLog(@"%zd",imageData.length);
            [self.captureSession stopRunning];
        }
    }];
}

- (void)cancle:(UIButton *)btn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)confirm:(UIButton *)btn {
    if ([self.cameraDelegate respondsToSelector:@selector(cameraController:didFinishPickingImage:)]) {
        [self.cameraDelegate cameraController:self didFinishPickingImage:self.currentImage];
    }
    UIImageWriteToSavedPhotosAlbum(self.currentImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if ([self.cameraDelegate respondsToSelector:@selector(cameraController:didFinishSavingWithError:)]) {
        [self.cameraDelegate cameraController:self didFinishSavingWithError:error];
    }
}

- (void)remake:(UIButton *)btn {
    self.currentImage = nil;
    [self.captureSession startRunning];
    self.takeBtn.hidden = NO;
    self.cancleBtn.hidden = NO;
    self.remakeBtn.hidden = YES;
    self.confirmBtn.hidden = YES;
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
    
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.preview.layer.masksToBounds = YES;
    _captureVideoPreviewLayer.frame = self.preview.bounds;
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.preview.layer addSublayer:_captureVideoPreviewLayer];
        [self.captureSession startRunning];
    });
}

- (UIView *)topBar {
    if (!_topBar) {
        self.topBar = [[UIView alloc] init];
        [_topBar setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:_topBar];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_topBar);
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_topBar]-0-|"
                                                 options:0
                                                 metrics:nil
                                                   views:viewsDictionary]];
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_topBar(==64)]"
                                                 options:0
                                                 metrics:nil
                                                   views:viewsDictionary]];
    }
    return _topBar;
}

- (UIView *)preview {
    if (!_preview) {
        self.preview = [[UIView alloc] init];
        [_preview setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:_preview];
        
        [self topBar];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_preview, _topBar);
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_preview]-0-|"
                                                 options:0
                                                 metrics:nil
                                                   views:viewsDictionary]];
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_topBar]-0-[_preview]-64-|"
                                                 options:0
                                                 metrics:nil
                                                   views:viewsDictionary]];
        
    }
    return _preview;
}

- (UIView *)bottomBar {
    if (!_bottomBar) {
        self.bottomBar = [[UIView alloc] init];
        _bottomBar.backgroundColor = [UIColor cyanColor];
        [_bottomBar setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:_bottomBar];
        
        [self preview];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_preview, _bottomBar);
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_bottomBar]-0-|"
                                                 options:0
                                                 metrics:nil
                                                   views:viewsDictionary]];
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_preview]-0-[_bottomBar]-0-|"
                                                 options:0
                                                 metrics:nil
                                                   views:viewsDictionary]];
        
    }
    return _bottomBar;
}

- (void)customBottomBar {
    //拍照按钮
    UIButton *takeBtn = [[UIButton alloc] init];
    takeBtn.backgroundColor = [UIColor redColor];
    [takeBtn addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [takeBtn setTitle:@"拍照" forState:UIControlStateNormal];
    [takeBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bottomBar addSubview:takeBtn];
    self.takeBtn = takeBtn;
    NSDictionary *takeBtnDictionary = NSDictionaryOfVariableBindings(takeBtn);
    [self.bottomBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[takeBtn(60)]" options:0 metrics:nil views:takeBtnDictionary]];
    [self.bottomBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[takeBtn(60)]" options:0 metrics:nil views:takeBtnDictionary]];
    [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:takeBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bottomBar attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.bottomBar addConstraint:[NSLayoutConstraint constraintWithItem:takeBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.bottomBar attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    //取消按钮
    UIButton *cancleBtn = [[UIButton alloc] init];
    cancleBtn.backgroundColor = [UIColor greenColor];
    [cancleBtn addTarget:self action:@selector(cancle:) forControlEvents:UIControlEventTouchUpInside];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bottomBar addSubview:cancleBtn];
    self.cancleBtn = cancleBtn;
    NSDictionary *cancleBtnDictionary = NSDictionaryOfVariableBindings(cancleBtn);
    [self.bottomBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[cancleBtn(60)]" options:0 metrics:nil views:cancleBtnDictionary]];
    [self.bottomBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-2-[cancleBtn(60)]" options:0 metrics:nil views:cancleBtnDictionary]];
    
    //确定按钮
    UIButton *confirmBtn = [[UIButton alloc] init];
    confirmBtn.backgroundColor = [UIColor greenColor];
    [confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    confirmBtn.hidden = YES;
    [confirmBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bottomBar addSubview:confirmBtn];
    self.confirmBtn = confirmBtn;
    NSDictionary *confirmBtnDictionary = NSDictionaryOfVariableBindings(confirmBtn);
    [self.bottomBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[confirmBtn(60)]" options:0 metrics:nil views:confirmBtnDictionary]];
    [self.bottomBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[confirmBtn(60)]-0-|" options:0 metrics:nil views:confirmBtnDictionary]];
    
    //重拍按钮
    UIButton *remakeBtn = [[UIButton alloc] init];
    remakeBtn.backgroundColor = [UIColor greenColor];
    [remakeBtn addTarget:self action:@selector(remake:) forControlEvents:UIControlEventTouchUpInside];
    [remakeBtn setTitle:@"重拍" forState:UIControlStateNormal];
    remakeBtn.hidden = YES;
    [remakeBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bottomBar addSubview:remakeBtn];
    self.remakeBtn = remakeBtn;
    NSDictionary *remakeBtnDictionary = NSDictionaryOfVariableBindings(remakeBtn);
    [self.bottomBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[remakeBtn(60)]" options:0 metrics:nil views:remakeBtnDictionary]];
    [self.bottomBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[remakeBtn(60)]" options:0 metrics:nil views:remakeBtnDictionary]];
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        self.captureSession = [[AVCaptureSession alloc] init];
        [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
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
