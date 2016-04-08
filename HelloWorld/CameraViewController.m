//
//  CameraViewController.m
//  HelloWorld
//
//  Created by Mike Leveton on 8/23/15.
//  Copyright (c) 2015 Mike Leveton. All rights reserved.
//


#import <MobileCoreServices/UTCoreTypes.h>
#import "CameraViewController.h"

#import "UIImage+Additions.h"
#import "CameraOverlayView.h"
#import "PhotoCropView.h"

/*To get authorization status */
@import Photos;

//#define kLocStringPhotoNotAuthorized            LWLocalizedString(@"Encounter not authorized")
#define kLocStringPhotoNotAuthorized            NSLocalizedString(@"Encounter not authorized", @"Encounter not authorized")
#define kLocStringSettings                      NSLocalizedString(@"Settings", @"Settings")
#define kLocStringCancelString                  NSLocalizedString(@"Cancel", @"Cancel")
#define kLocStringAllowPhotoAccess              NSLocalizedString(@"Go to Settings to give Encounter access", @"Go to Settings to give Encounter access")
#define kImageRadius            (8.0f)

@interface CameraViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIButton                  *photoRollButton;
@property (nonatomic, strong) UIButton                  *backBtn;
@property (nonatomic, strong) UIButton                  *captureBtn;
@property (nonatomic, strong) UIButton                  *flashBtn;
@property (nonatomic, strong) UIButton                  *switchCameraBtn;
@property (nonatomic, strong) AVCaptureSession          *session;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureDevice           *device;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer*captureVideoPreviewLayer;
@property (nonatomic, strong) UIView                    *topView;
@property (nonatomic, strong) UIView                    *bottomView;
@property (nonatomic, strong) UIView                    *imageStreamView;
@property (nonatomic, strong) UIImageView               *capturedImageView;
@property (nonatomic, strong) UIImageView               *backImageFrame;
@property (nonatomic, strong) UIImageView               *focusImageView;
@property (nonatomic, strong) UIImagePickerController   *photoRollController;
@property (nonatomic, strong) CameraOverlayView       *cardOverlay;
@property (nonatomic)         PhotoCropView             *cropView;
@property (nonatomic, assign) CGFloat                   screenWidth;
@property (nonatomic, assign) CGFloat                   screenHeight;
@property (nonatomic, assign) CGFloat                   currentImageScale;
@property (nonatomic, assign) CGFloat                   trackerScale;
@property (nonatomic, assign) CGFloat                   cardXOffset;
@property (nonatomic, assign) CGFloat                   cardYOffset;
@property (nonatomic, assign) BOOL                      imageIsSet;
@property (nonatomic, assign) BOOL                      isImageRescaled;

@property (nonatomic) CGRect cropRect;


@end

@implementation CameraViewController;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.clipsToBounds = NO;
    self.view.backgroundColor = [UIColor grayColor];
    
    CGRect screen = [[self view] frame];
    CGFloat currentWidth = CGRectGetWidth(screen);
    CGFloat currentHeight = CGRectGetHeight(screen);
    _screenWidth = currentWidth < currentHeight ? currentWidth : currentHeight;
    _screenHeight = currentWidth < currentHeight ? currentHeight : currentWidth;
    
    UITapGestureRecognizer *focusTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapToFocus:)];
    focusTap.numberOfTapsRequired = 1;
    if (_viewFinderHasOverlay){
        [[self cardOverlay] addGestureRecognizer:focusTap];
    }else{
        [[self capturedImageView] addGestureRecognizer:focusTap];
    }
    
    [self setupAVFoundationComponents];
    
    [self imageStreamView].alpha = 1.0f;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setButtonsEnabled:YES];
    
    if ([[self delegate] respondsToSelector:@selector(cameraDidLoadCameraIntoView:)]) {
        [[self delegate] cameraDidLoadCameraIntoView:self];
    }
    
    if (!CGRectEqualToRect(self.cropRect, CGRectZero)) {
        self.cropRect = self.cropRect;
    }
    if (!CGRectEqualToRect(self.imageCropRect, CGRectZero)) {
        self.imageCropRect = self.imageCropRect;
    }
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect screen = [[self view] frame];
    CGFloat currentWidth = CGRectGetWidth(screen);
    CGFloat currentHeight = CGRectGetHeight(screen);
    _screenWidth = currentWidth < currentHeight ? currentWidth : currentHeight;
    _screenHeight = currentWidth < currentHeight ? currentHeight : currentWidth;
    
    CGFloat controlHeight = CGRectGetHeight([[self view] frame]) * 0.25f;
    CGFloat overlayHeight = CGRectGetHeight([[self view] frame]) * 0.75f;
    CGFloat photoRollYOffset = overlayHeight + (controlHeight - 36)/2;
    
    CGRect photoButtonFrame = [[self photoRollButton] frame];
    photoButtonFrame.origin.x = 37.0f;
    photoButtonFrame.origin.y = photoRollYOffset;
    photoButtonFrame.size.width = 36.0f;
    photoButtonFrame.size.height = 36.0f;
    [[self photoRollButton] setFrame:photoButtonFrame];
    
    CGFloat captureButtonDiameter = 90.0f;
    CGFloat captureYOffset = (controlHeight - captureButtonDiameter)/2;
    
    CGRect captureFrame = [[self captureBtn] frame];
    captureFrame.origin.x = (CGRectGetWidth([[self view] frame]) - captureButtonDiameter)/2;
    captureFrame.origin.y = overlayHeight + captureYOffset;
    captureFrame.size.width = captureButtonDiameter;
    captureFrame.size.height = captureButtonDiameter;
    [[self captureBtn] setFrame:captureFrame];
    [self.view bringSubviewToFront:_captureBtn];
    
    CGFloat flashXOffset = CGRectGetWidth([[self view] frame]) - (16 + 16.76);
    
    CGRect flashButtonFrame = [[self flashBtn] frame];
    flashButtonFrame.origin.x = flashXOffset;
    flashButtonFrame.origin.y = 12.0f;
    flashButtonFrame.size.width = 16.0f;
    flashButtonFrame.size.height = 24.0f;
    [[self flashBtn] setFrame:flashButtonFrame];
    
    CGFloat switchXOffset = CGRectGetWidth([[self view] frame])  - (37 + 36);
    CGFloat switchButtonDiameter = 30.0f;
    CGFloat switchYOffset = (controlHeight - switchButtonDiameter)/2;
    
    CGRect switchCameraFrame = [[self switchCameraBtn] frame];
    switchCameraFrame.origin.x = switchXOffset;
    switchCameraFrame.origin.y = overlayHeight + switchYOffset;
    switchCameraFrame.size.width = 37.0f;
    switchCameraFrame.size.height = switchButtonDiameter;
    [[self switchCameraBtn] setFrame:switchCameraFrame];
    
    CGFloat topViewHeight = 48.0f;
    
    CGRect imageStreamFrame = [[self imageStreamView] frame];
    imageStreamFrame.origin.x = 0.0f;
    imageStreamFrame.origin.y = topViewHeight;
    imageStreamFrame.size.width = CGRectGetWidth([[self view] frame]);
    imageStreamFrame.size.height = CGRectGetHeight([[self view] frame]) - (controlHeight + topViewHeight);
    [[self imageStreamView] setFrame:imageStreamFrame];
    [[self capturedImageView] setFrame:imageStreamFrame];
    [[self captureVideoPreviewLayer] setFrame:[self imageStreamView].layer.bounds];
    [[self cardOverlay] setFrame:imageStreamFrame];
    [[self cropView] setFrame:imageStreamFrame];
    [[self cropView] setHidden:!_imageIsSet];
    
    CGFloat viewWidth = [self imageStreamView].frame.size.width;
    CGFloat viewHeight = [self imageStreamView].frame.size.height;
    CGSize viewSize = CGSizeMake(viewWidth, viewHeight);
    [[self cardOverlay] setViewSize:viewSize];
    CGFloat cardXOffset = (viewWidth - _cardSize.width)/2;
    CGFloat cardYOffset = (viewHeight - _cardSize.height)/2;
    [[self cardOverlay] setCardXOffset:cardXOffset];
    [[self cardOverlay] setCardYOffset:cardYOffset];
    
    CGRect topViewFrame = [[self topView] frame];
    topViewFrame.size.width = CGRectGetWidth([[self view] frame]);
    topViewFrame.size.height = topViewHeight;
    topViewFrame.origin.x = 0.0f;
    topViewFrame.origin.y = 0.0f;
    [[self topView] setFrame:topViewFrame];
    
    /* YOU HAVE TO INCLUDE TOPVIEW HEIGHT */
    [[self cropView] setOverlayXOffset:cardXOffset];
    [[self cropView] setOverlayYOffset:cardYOffset - topViewHeight];
    
    CGRect bottomViewFrame = [[self bottomView] frame];
    bottomViewFrame.size.width = CGRectGetWidth([[self view] frame]);
    bottomViewFrame.size.height = controlHeight;
    bottomViewFrame.origin.x = 0.0f;
    bottomViewFrame.origin.y = currentHeight * 0.75f;
    [[self bottomView] setFrame:bottomViewFrame];
    
    CGRect backBtnFrame = [[self backBtn] frame];
    backBtnFrame.origin.x = 0.0f;
    backBtnFrame.origin.y = 0.0f;
    backBtnFrame.size.width = 180.0f;
    backBtnFrame.size.height = topViewFrame.size.height;
    [[self backBtn] setFrame:backBtnFrame];
    [self.view bringSubviewToFront:_backBtn];
    
    CGRect backImageFrame = [[self backImageFrame] frame];
    backImageFrame.origin.x = 0.0f;
    backImageFrame.origin.y = 0.0f;
    backImageFrame.size.width = topViewHeight;
    backImageFrame.size.height = topViewHeight;
    [[self backImageFrame] setFrame:backImageFrame];
    [self.view bringSubviewToFront:_backImageFrame];
    
    [self captureVideoPreviewLayer].connection.videoOrientation = [self videoOrientation];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    [self captureVideoPreviewLayer].connection.videoOrientation = [self videoOrientation];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - getters

- (UIButton *)photoRollButton{
    if (!_photoRollButton){
        _photoRollButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _photoRollButton.frame = CGRectZero;
        [_photoRollButton addTarget:self action:@selector(didTapPhotoRollButton:) forControlEvents:UIControlEventTouchUpInside];
        [[_photoRollButton layer] setZPosition:3.0f];
        _photoRollButton.tag = 1;
        [_photoRollButton setBackgroundImage:[UIImage imageNamed:@"CameraPhotoRollImage"] forState:UIControlStateNormal];
        if (_allowsPhotoRoll){
            [self.view addSubview:_photoRollButton];
            [self.view bringSubviewToFront:_photoRollButton];
        }
    }
    
    return _photoRollButton;
}

- (UIButton *)captureBtn{
    if (!_captureBtn){
        _captureBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_captureBtn setFrame:CGRectZero];
        [_captureBtn addTarget:self action:@selector(didTapCapturePhoto) forControlEvents:UIControlEventTouchUpInside];
        [_captureBtn setBackgroundImage:[UIImage imageNamed:@"CameraCapture"] forState:UIControlStateNormal];
        [[_captureBtn layer] setZPosition:3.0];
        [self.view addSubview:_captureBtn];
        [self.view bringSubviewToFront:_captureBtn];
    }
    
    return _captureBtn;
}

- (UIImageView *)backImageFrame{
    if (!_backImageFrame){
        _backImageFrame = [[UIImageView alloc]initWithFrame:CGRectZero];
        [_backImageFrame setImage:[UIImage imageNamed:@"CamerBackImage"]];
        [[_backImageFrame layer] setZPosition:3.0];
        [self.view addSubview:_backImageFrame];
    }
    return _backImageFrame;
}

- (UIButton *)backBtn{
    if (!_backBtn){
        _backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_backBtn setFrame:CGRectZero];
        [_backBtn addTarget:self action:@selector(didTapDismissButton:) forControlEvents:UIControlEventTouchUpInside];
        [_backBtn setTintColor:[UIColor blueColor]];
        [[_backBtn layer] setZPosition:3.0];
        //[_backBtn setBackgroundColor:[UIColor redColor]];
        [self.view addSubview:_backBtn];
        [self.view bringSubviewToFront:_backBtn];
    }
    
    return _backBtn;
}


- (UIButton *)flashBtn{
    if (!_flashBtn){
        _flashBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_flashBtn setFrame:CGRectZero];
        [_flashBtn addTarget:self action:@selector(didTapFlashButton:) forControlEvents:UIControlEventTouchUpInside];
        [_flashBtn setBackgroundImage:[UIImage imageNamed:@"CameraFlashImage"] forState:UIControlStateNormal];
        [_flashBtn setTintColor:[UIColor blueColor]];
        [[_flashBtn layer] setZPosition:3.0];
        if (_allowsFlash){
            [self.view addSubview:_flashBtn];
        }
    }
    
    return _flashBtn;
}

- (UIButton *)switchCameraBtn{
    if (!_switchCameraBtn){
        _switchCameraBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_switchCameraBtn setFrame:CGRectZero];
        [_switchCameraBtn setImage:[UIImage imageNamed:@"CamerRotateImage"] forState:UIControlStateNormal];
        [[_switchCameraBtn layer] setZPosition:3.0];
        [_switchCameraBtn addTarget:self action:@selector(didTapSwitchCameraButton:) forControlEvents:UIControlEventTouchUpInside];
        if (_allowsFlipCamera){
            [self.view addSubview:_switchCameraBtn];
            [self.view bringSubviewToFront:_switchCameraBtn];
        }
    }
    
    return _switchCameraBtn;
}

- (UIView *)imageStreamView{
    if (!_imageStreamView){
        _imageStreamView = [[UIView alloc]initWithFrame:CGRectZero];
        [self.view addSubview:_imageStreamView];
    }
    return _imageStreamView;
}

- (UIImageView *)capturedImageView{
    if (!_capturedImageView){
        _capturedImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _capturedImageView.backgroundColor = [UIColor clearColor];
        _capturedImageView.contentMode = UIViewContentModeScaleAspectFill;
        _capturedImageView.userInteractionEnabled = YES;
        //[self.view insertSubview:_capturedImageView aboveSubview:[self imageStreamView]];
    }
    return _capturedImageView;
}

- (AVCaptureSession *)session{
    if (!_session){
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetPhoto;
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)captureVideoPreviewLayer{
    if (!_captureVideoPreviewLayer){
        _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[self session]];
        [_captureVideoPreviewLayer setFrame:CGRectZero];
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [[self imageStreamView].layer addSublayer:_captureVideoPreviewLayer];
    }
    return _captureVideoPreviewLayer;
}

- (AVCaptureStillImageOutput *)stillImageOutput{
    if (!_stillImageOutput){
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [_stillImageOutput setOutputSettings:outputSettings];
    }
    return _stillImageOutput;
}

- (UIView *)topView{
    if (!_topView){
        _topView = [[UIView alloc]initWithFrame:CGRectZero];
        _topView.backgroundColor = [UIColor grayColor];
        [[_topView layer] setZPosition:2.0];
        [self.view addSubview:_topView];
        [self.view bringSubviewToFront:[self backBtn]];
    }
    return _topView;
}

- (UIView *)bottomView{
    if (!_bottomView){
        _bottomView = [[UIView alloc]initWithFrame:CGRectZero];
        _bottomView.backgroundColor = [UIColor grayColor];
        [[_bottomView layer] setZPosition:2.0];
        [self.view addSubview:_bottomView];
        [self.view bringSubviewToFront:[self photoRollButton]];
        [self.view bringSubviewToFront:[self switchCameraBtn]];
    }
    return _bottomView;
}

- (CameraOverlayView *)cardOverlay{
    if (!_cardOverlay){
        CGFloat viewWidth = [self imageStreamView].frame.size.width;
        CGFloat viewHeight = [self imageStreamView].frame.size.height;
        CGSize viewSize = CGSizeMake(viewWidth, viewHeight);
        CGSize cardSize = CGSizeMake(_cardSize.width, _cardSize.height);
        UIColor *color = [self colorWithHexString:@"D8D8D8" withOpacity:0.60f];
        _cardOverlay = [[CameraOverlayView alloc] initWithViewSize:viewSize cardSize:cardSize andColor:color];
        [_cardOverlay.layer setZPosition:1.0];
        [_cardOverlay setUserInteractionEnabled:YES];
        if (_viewFinderHasOverlay) {
            [[self view] addSubview:_cardOverlay];
        }
    }
    return _cardOverlay;
}

- (PhotoCropView *)cropView{
    if (!_cropView){
        _cropView  = [[PhotoCropView alloc] initWithFrame:CGRectZero];
        [_cropView setOverlaySize:_cardSize];
        [_cropView setOverlayXOffset:[[self cardOverlay] cardXOffset]];
        [_cropView setOverlayYOffset:[[self cardOverlay] cardYOffset]];
        [_cropView setDefaultImageLength:800.0f];
        [[self imageStreamView] addSubview:_cropView];
        return _cropView;
    }
    
    return _cropView;
}

- (CGSize)viewFinderSize{
    return CGSizeMake([self imageStreamView].frame.size.width, [self imageStreamView].frame.size.height);
}

- (UIImagePickerController *)photoRollController{
    if (!_photoRollController){
        _photoRollController = [[UIImagePickerController alloc] init];
        [_photoRollController setDelegate:self];
        [_photoRollController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [_photoRollController setAllowsEditing:NO];
        [_photoRollController setMediaTypes:[NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil]];
        UIColor *teal = [UIColor blueColor];
        [_photoRollController.view setTintColor:teal];
        //[[self view] addSubview:_photoRollController];
    }
    return _photoRollController;
}

- (UIImageView *)focusImageView{
    if (!_focusImageView){
        _focusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(([self imageStreamView].frame.size.width - 80.0f)/2, ([self imageStreamView].frame.size.height - 80.0f)/2, 80.0f, 80.0f)];
        [_focusImageView setImage:[UIImage imageNamed:@"tapToFocus"]];
        [_focusImageView setAlpha:0.0f];
        [[_focusImageView layer] setZPosition:3.0f];
        [[self view] addSubview:_focusImageView];
    }
    return _focusImageView;
}

#pragma mark - setters

- (void)setCardSize:(CGSize)cardSize{
    _cardSize = cardSize;
}

- (void)setAllowsPhotoRoll:(BOOL)allowsPhotoRoll{
    _allowsPhotoRoll = allowsPhotoRoll;
}

- (void)setAllowsFlash:(BOOL)allowsFlash{
    _allowsFlash = allowsFlash;
}

- (void)setAllowsFlipCamera:(BOOL)allowsFlipCamera{
    _allowsFlipCamera = allowsFlipCamera;
}

- (void)setViewFinderHasOverlay:(BOOL)viewFinderHasOverlay{
    _viewFinderHasOverlay = viewFinderHasOverlay;
}

- (void)setCameraShouldDefaultToFront:(BOOL)cameraShouldDefaultToFront{
    _cameraShouldDefaultToFront = cameraShouldDefaultToFront;
}

- (void)setupAVFoundationComponents{
    
    [self imageStreamView].alpha = 0.0f;
    
    [[self imageStreamView].layer addSublayer:[self captureVideoPreviewLayer]];
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if (devices.count == 0) {
        NSLog(@"Camera: No devices found (for example: simulator)");
        return;
    }
    
    if (_cameraShouldDefaultToFront){
        _device = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][LWCameraOrientationFrontCamera];
    }else{
        _device = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][LWCameraOrientationBackCamera];
    }
    
    if ([_device isFlashAvailable] && _device.flashActive && [_device lockForConfiguration:nil]) {
        _device.flashMode = AVCaptureFlashModeOff;
        [_device unlockForConfiguration];
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    
    if (!input) {
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            //TODO: handle error?
        }];
    }
    
    [[self session] addInput:input];
    [[self session] addOutput:[self stillImageOutput]];
    [[self session] startRunning];
    
    [self cameraIsReadyForControls];
}

- (void)setShouldResizeToViewFinder:(BOOL)shouldResizeToViewFinder{
    _shouldResizeToViewFinder = shouldResizeToViewFinder;
}

#pragma mark - actions

- (void)setButtonsEnabled:(BOOL)enabled{
    [[self captureBtn] setEnabled:enabled];
    [[self photoRollButton] setEnabled:enabled];
    [[self backBtn] setEnabled:enabled];
    [[self switchCameraBtn] setEnabled:enabled];
    [[self flashBtn] setEnabled:enabled];
}

- (void)cameraIsReadyForControls {
    
    for (UIButton *btn in @[[self backBtn], [self flashBtn], [self switchCameraBtn], [self captureBtn]])  {
        [btn setHidden:NO];
    }
    
    // If a device doesn't have multiple cameras, fade out button ...
    if ([AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1) {
        [[self switchCameraBtn] setHidden:NO];
    }else {
        [[self switchCameraBtn] setHidden:YES];
    }
    
    [self checkForFlashCapability];
}

- (void)didTapCapturePhoto {
    
    [self setButtonsEnabled:NO];
    
    //_isCapturingImage = YES;
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                [videoConnection setVideoOrientation:_captureVideoPreviewLayer.connection.videoOrientation];
                NSLog(@"connection orientation: %ld", (long)videoConnection.videoOrientation);
                break;
            }
        }
        if (videoConnection){
            break;
        }
    }
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         if(!CMSampleBufferIsValid(imageSampleBuffer))
         {
             return;
         }
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         
         UIImage *capturedImage = [[UIImage alloc]initWithData:imageData scale:1];
         
         if (_device == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][LWCameraOrientationFrontCamera]) {
             /* front camera active so image needs to be flipped to look the same as the camera */
             
             if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait){
                 capturedImage = [UIImage imageWithCGImage:capturedImage.CGImage scale:capturedImage.scale orientation:UIImageOrientationLeftMirrored];
             }
             if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown){
                 capturedImage = [UIImage imageWithCGImage:capturedImage.CGImage scale:capturedImage.scale orientation:UIImageOrientationRightMirrored];
             }
             if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft){
                 capturedImage = [UIImage imageWithCGImage:capturedImage.CGImage scale:capturedImage.scale orientation:UIImageOrientationDownMirrored];
             }
             if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight){
                 capturedImage = [UIImage imageWithCGImage:capturedImage.CGImage scale:capturedImage.scale orientation:UIImageOrientationUpMirrored];
             }
         }
         
         _capturedImageView.image = capturedImage;
         imageData = nil;
         
         //[self photoCaptured];
         if (_shouldResizeToViewFinder){
           [self resizeImageWithImage:[self capturedImageView].image];
         }else{
             if ([[self delegate] respondsToSelector:@selector(CameraViewController:didFinishWithImage:)]) {
                 capturedImage = [capturedImage normalizedImage];
                 [[self delegate] CameraViewController:self didFinishWithImage:capturedImage];
             }
             [self cleanUp];
         }
         [self setButtonsEnabled:YES];
     }];
}

#pragma mark - actions

- (void)didTapPhotoRollButton:(id)sender{
    
    [self setButtonsEnabled:NO];
    
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                [self showPhotoRollController];
                break;
            case PHAuthorizationStatusRestricted:
                [self showAuthorizePhotos];
                break;
            case PHAuthorizationStatusDenied:
                [self showAuthorizePhotos];
                break;
            default:
                [self showAuthorizePhotos];
                break;
        }
    }];
}

- (void)showAuthorizePhotos{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:kLocStringPhotoNotAuthorized
                                message:kLocStringAllowPhotoAccess
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *settings = [UIAlertAction actionWithTitle:kLocStringSettings style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action){
                                                         NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                         [[UIApplication sharedApplication] openURL:appSettings];
                                                     }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:kLocStringCancelString style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action){
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:settings];
    [alert addAction:cancel];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setButtonsEnabled:YES];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)showPhotoRollController{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:[self photoRollController] animated:YES completion:nil];
        [self setButtonsEnabled:YES];
    });
}

- (void)didTapFlashButton:(id)sender {
    if ([_device isFlashAvailable]) {
        if (_device.flashActive) {
            if([_device lockForConfiguration:nil]) {
                _device.flashMode = AVCaptureFlashModeOff;
                [_flashBtn setBackgroundImage:[UIImage imageNamed:@"CameraFlashImage"] forState:UIControlStateNormal];
            }
        } else {
            if([_device lockForConfiguration:nil]) {
                _device.flashMode = AVCaptureFlashModeOn;
                [_flashBtn setBackgroundImage:[UIImage imageNamed:@"CameraFlashImageOn"] forState:UIControlStateNormal];
            }
        }
        [_device unlockForConfiguration];
    }
}

- (void)didTapDismissButton:(id)sender {
    
    [self closeWithCompletion:nil];
}

- (void)didTapSwitchCameraButton:(id)sender {
    
    if (_device == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][LWCameraOrientationBackCamera]) {
        
        // rear active, switch to front
        _device = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][LWCameraOrientationFrontCamera];
        
        [[self session] beginConfiguration];
        AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
        
        for (AVCaptureInput *oldInput in _session.inputs) {
            [[self session] removeInput:oldInput];
        }
        
        [[self session] addInput:newInput];
        [[self session] commitConfiguration];
    } else if (_device == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][LWCameraOrientationFrontCamera]) {
        
        // front active, switch to rear
        _device = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][LWCameraOrientationBackCamera];
        [[self session] beginConfiguration];
        
        AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
        
        for (AVCaptureInput *oldInput in _session.inputs) {
            [[self session] removeInput:oldInput];
        }
        
        [[self session] addInput:newInput];
        [[self session] commitConfiguration];
    }
    
    [self checkForFlashCapability];
}

- (void)checkForFlashCapability {
    
    if (_device.isFlashAvailable) {
        [[self flashBtn] setHidden:NO];
        
        
        if (_device.isFlashActive) {
            [[self flashBtn] setTintColor:[UIColor greenColor]];
        } else {
            [[self flashBtn] setTintColor:[UIColor redColor]];
        }
    }
    else {
        [[self flashBtn] setHidden:YES];
        [[self flashBtn] setTintColor:[UIColor grayColor]];
    }
}

#pragma mark - focus

- (void)didTapToFocus:(UITapGestureRecognizer *)sender {
    
    if (!_capturedImageView.image) {
        CGPoint aPoint = [sender locationInView:_imageStreamView];
        if (_device) {
            if([_device isFocusPointOfInterestSupported] &&
               [_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                
                // we subtract the point from the width to inverse the focal point
                // focus points of interest represents a CGPoint where
                // {0,0} corresponds to the top left of the picture area, and
                // {1,1} corresponds to the bottom right in landscape mode with the home button on the right—
                
                double pX = aPoint.x / _imageStreamView.bounds.size.width;
                double pY = aPoint.y / _imageStreamView.bounds.size.height;
                double focusX = pY;
                // x is equal to y but y is equal to inverse x ?
                double focusY = 1 - pX;
                
                if([_device isFocusPointOfInterestSupported] && [_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                    
                    if([_device lockForConfiguration:nil]) {
                        
                        [[self focusImageView] setCenter:CGPointMake(aPoint.x, aPoint.y)];
                        [[self focusImageView] setAlpha:1.0f];
                        
                        __block CGRect newRect = [[self focusImageView] frame];
                        newRect.size.height = 60;
                        newRect.size.width = 60;
                        
                        [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
                            [[self focusImageView] setFrame:newRect];
                        } completion:^(BOOL finished){
                            [[self focusImageView] setAlpha:0.0f];
                            [[self focusImageView] setFrame:CGRectMake(([self imageStreamView].frame.size.width - 80.0f)/2, ([self imageStreamView].frame.size.height - 80.0f)/2, 80.0f, 80.0f)];
                        }];
                        
                        [_device setFocusPointOfInterest:CGPointMake(focusX, focusY)];
                        [_device setFocusMode:AVCaptureFocusModeAutoFocus];
                        [_device setExposurePointOfInterest:CGPointMake(focusX, focusY)];
                        [_device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                    }
                    [_device unlockForConfiguration];
                }
            }
        }
    }
}

#pragma mark - resize image

- (void)resizeImageWithImage:(UIImage *)image {
    
   
    CGFloat captureWidth = [self cardSize].width;
    CGFloat captureHeight = [self cardSize].height;
    CGRect frame = CGRectMake(0, 0, captureHeight, captureWidth);
    CGSize size = CGSizeMake(captureHeight, captureWidth);
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 2.0);
    [image drawInRect:frame];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self cleanUp];
    
    if ([[self delegate] respondsToSelector:@selector(CameraViewController:didFinishWithImage:)]) {
        image = [image normalizedImage];
        [[self delegate] CameraViewController:self didFinishWithImage:image];
    }
}


#pragma mark - rotation

- (AVCaptureVideoOrientation)videoOrientation{
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSLog(@"reached videoOrientation with device orientation %@", [self deviceOrientation:orientation]);
    //NSLog(@"reached videoOrientation with video orientation %@", [self videoOrientation:[self captureVideoPreviewLayer].connection.videoOrientation]);
    
    //    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft){
    //        NSLog(@"REACHED LANDSCAPE LEFT");
    //    }
    //
    //    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight){
    //        NSLog(@"REACHED LANDSCAPE RIGHT");
    //    }
    //
    //    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait){
    //        NSLog(@"REACHED PORTRAIT");
    //    }
    //
    //    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown){
    //        NSLog(@"REACHED PORTRAIT UPSIDEDOWN");
    //    }
    
    
    switch (orientation)
    {
        case UIDeviceOrientationUnknown:
            return AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            //return AVCaptureVideoOrientationLandscapeLeft;
            return AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeLeft;
            //return AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationFaceUp:
            return AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationFaceDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
            break;
    }
    
}

- (NSString *)deviceOrientation:(UIDeviceOrientation)orientation{
    
    if (orientation == UIDeviceOrientationUnknown){
        return @"Device orientation unknown";
    }
    if (orientation == UIDeviceOrientationPortrait){
        return @"Device orientation portrait";
    }
    if (orientation == UIDeviceOrientationPortraitUpsideDown){
        return @"Device orientation upside down";
    }
    if (orientation == UIDeviceOrientationLandscapeLeft){
        return @"Device orientation landscape left";
    }
    if (orientation == UIDeviceOrientationLandscapeRight){
        return @"Device orientation landscape right";
    }
    if (orientation == UIDeviceOrientationFaceUp){
        return @"Device orientation faceup";
    }
    if (orientation == UIDeviceOrientationFaceDown){
        return @"Device orientation facedown";
    }
    
    return @"device orientation fell through";
}

- (NSString *)videoOrientation:(AVCaptureVideoOrientation)orientation{
    
    if (orientation == AVCaptureVideoOrientationPortrait){
        return @"video orientation portrait";
    }
    if (orientation == AVCaptureVideoOrientationPortraitUpsideDown){
        return @"video orientation upside down";
    }
    if (orientation == AVCaptureVideoOrientationLandscapeRight){
        return @"video orientation landscape right";
    }
    if (orientation == AVCaptureVideoOrientationLandscapeLeft){
        return @"video orientation landscape left";
    }
    
    return @"video orientation fell through";
}

#pragma mark - clean up

- (void)closeWithCompletion:(void (^)(void))completion {
    
    // Need alpha 0.0 before dismissing otherwise sticks out on dismissal
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (completion){
            completion();
        }
        
        //_isImageResized = NO;
        //_isSaveWaitingForResizedImage = NO;
        //_isRotateWaitingForResizedImage = NO;
        _imageIsSet = NO;
        
        [_session stopRunning];
        _session = nil;
        
        _capturedImageView.image = nil;
        [_capturedImageView removeFromSuperview];
        _capturedImageView = nil;
        
        [_imageStreamView removeFromSuperview];
        _imageStreamView = nil;
        
        _stillImageOutput = nil;
        _device = nil;
        _device = nil;
        _delegate = nil;
        self.view = nil;
        [self removeFromParentViewController];
        
        
    }];
}

- (void)cleanUp{
    
    /* prevents a weird effect when the modal is dismissing */
    [[self capturedImageView] removeFromSuperview];
}

#pragma mark - for photoCrop

- (void)didTapCropPhoto{
    
    [self setButtonsEnabled:NO];
    
    //_isSaveWaitingForResizedImage = YES;
    
    if ([[self delegate] respondsToSelector:@selector(CameraViewController:didFinishCroppingImage:transform:cropRect:)]) {
        [[self delegate] CameraViewController:self didFinishCroppingImage:self.cropView.croppedImage transform:self.cropView.rotation cropRect:self.cropView.zoomedCropRect];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *editedImage = [info valueForKey:UIImagePickerControllerEditedImage];
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage *savedImage = (editedImage) ? editedImage : originalImage;
    //UIImage *savedImage = originalImage;
    
    /*Rotates the image to be the correct orientation*/
    savedImage = [savedImage normalizedImage];
    
    [[self photoRollController] dismissViewControllerAnimated:YES completion:^{
        _imageIsSet = YES;
        [[self cropView] setImage:savedImage];
        CGFloat width = savedImage.size.width;
        CGFloat height = savedImage.size.height;
        CGFloat length = MIN(width, height);
        [self setImageCropRect:CGRectMake((width - length) / 2, (height - length) / 2, length, length)];
        [[self capturedImageView] setHidden:YES];
        [[self captureVideoPreviewLayer] setHidden:YES];
        [[self photoRollButton] setHidden:YES];
        [[self switchCameraBtn] setHidden:YES];
        [[self cardOverlay] setUserInteractionEnabled:NO];
        [[self captureBtn] removeTarget:self action:@selector(didTapCapturePhoto) forControlEvents:UIControlEventTouchUpInside];
        [[self captureBtn] addTarget:self action:@selector(didTapCropPhoto) forControlEvents:UIControlEventTouchUpInside];
        [[self view] setNeedsLayout];
    }];
    
}

- (UIColor *)colorWithHexString:(NSString *)hex withOpacity:(CGFloat)opacity {
    //added in removal of # if passed into the string
    hex = [hex stringByReplacingOccurrencesOfString:@"#" withString:@"" options:0 range:NSMakeRange(0, [hex length])];
    
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha: opacity];
}


@end